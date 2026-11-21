#!/usr/bin/env python3
"""Smoke system test for the Kaffee-Begleiter Flutter web app."""
import functools
import http.server
import os
import re
import socket
import subprocess
import sys
import threading
from pathlib import Path

from playwright.sync_api import sync_playwright

APP = Path(__file__).resolve().parent.parent
WEB = Path(os.environ.get("WEB_DIR", APP / "build" / "web"))
TIMEOUT = 30000

LABELS = {
    "en-US": ["Today", "Beans", "Brew", "Equipment", "More"],
    "de-DE": ["Heute", "Bohnen", "Brühen", "Ausrüstung", "Mehr"],
}
SIDEBAR_EXTRA = {
    "en-US": ["Water", "Care", "Settings"],
    "de-DE": ["Wasser", "Pflege", "Einstellungen"],
}


def newest_mtime(path):
    latest = 0.0
    for p in path.rglob("*"):
        if p.is_file():
            latest = max(latest, p.stat().st_mtime)
    return latest


def ensure_build():
    index = WEB / "index.html"
    if os.environ.get("NO_BUILD") or "WEB_DIR" in os.environ:
        assert index.exists(), f"{index} missing"
        return
    if index.exists() and index.stat().st_mtime >= newest_mtime(APP / "lib"):
        return
    print("building web app ...", flush=True)
    subprocess.run(["flutter", "build", "web"], cwd=APP, check=True)
    assert index.exists(), "flutter build web produced no index.html"


class Quiet(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *a):
        pass


def serve():
    s = socket.socket()
    s.bind(("127.0.0.1", 0))
    port = s.getsockname()[1]
    s.close()
    handler = functools.partial(Quiet, directory=str(WEB))
    srv = http.server.ThreadingHTTPServer(("127.0.0.1", port), handler)
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    return srv, port


def launch(pw):
    try:
        return pw.chromium.launch(channel="chrome")
    except Exception:
        return pw.chromium.launch()


def enable_semantics(page):
    page.wait_for_selector("flt-glass-pane", state="attached", timeout=TIMEOUT)
    page.evaluate(
        """() => { const p = document.querySelector('flt-semantics-placeholder');
                   if (p) p.click(); }"""
    )
    try:
        page.wait_for_selector("flt-semantics", state="attached", timeout=TIMEOUT)
    except Exception:
        page.keyboard.press("Tab")
        page.wait_for_selector("flt-semantics", state="attached", timeout=TIMEOUT)


def semantic_texts(page):
    """Return all semantics labels (aria-label or text content) in the DOM."""
    return page.evaluate(
        """() => Array.from(document.querySelectorAll('flt-semantics, [aria-label]'))
              .map(e => (e.getAttribute('aria-label') || e.textContent || '').trim())
              .filter(t => t.length > 0)"""
    )


def count_label(texts, label):
    pat = re.compile(r"^%s\b" % re.escape(label), re.I)
    return sum(1 for t in texts if pat.match(t))


def wait_labels(page, labels, what):
    import time

    end = time.time() + TIMEOUT / 1000
    missing = labels
    while time.time() < end:
        texts = semantic_texts(page)
        missing = [l for l in labels if count_label(texts, l) == 0]
        if not missing:
            return texts
        page.wait_for_timeout(300)
    raise AssertionError(f"{what}: labels not found: {missing}; saw {semantic_texts(page)[:40]}")


def no_hscroll(page, what):
    sw, iw = page.evaluate(
        "() => [document.documentElement.scrollWidth, window.innerWidth]"
    )
    assert sw <= iw, f"{what}: horizontal scroll ({sw} > {iw})"


def run_locale(browser, base, locale):
    errors = []
    ctx = browser.new_context(
        locale=locale, viewport={"width": 390, "height": 844}
    )
    ctx.set_default_timeout(TIMEOUT)
    page = ctx.new_page()
    page.on(
        "console",
        lambda m: errors.append(m.text) if m.type == "error" else None,
    )
    page.on("pageerror", lambda e: errors.append(str(e)))

    labels = LABELS[locale]
    # Mobile
    page.goto(base)
    enable_semantics(page)
    wait_labels(page, labels, f"{locale} mobile nav")
    title = page.title()
    assert title, "empty page title"
    no_hscroll(page, f"{locale} 390x844")
    print(f"[{locale}] mobile: 5 nav destinations OK, title={title!r}")

    # Desktop
    page.set_viewport_size({"width": 1280, "height": 800})
    page.wait_for_timeout(1000)
    enable_semantics(page)
    texts = wait_labels(
        page, labels[:4] + SIDEBAR_EXTRA[locale], f"{locale} sidebar"
    )
    distinct = {
        l for l in labels[:4] + SIDEBAR_EXTRA[locale] if count_label(texts, l) > 0
    }
    assert len(distinct) >= 7, f"{locale}: only {sorted(distinct)} visible in sidebar"
    no_hscroll(page, f"{locale} 1280x800")
    print(f"[{locale}] desktop: sidebar entries {sorted(distinct)} OK")

    assert not errors, f"{locale}: console errors: {errors[:5]}"
    ctx.close()


def main():
    ensure_build()
    srv, port = serve()
    base = f"http://127.0.0.1:{port}/"
    try:
        with sync_playwright() as pw:
            browser = launch(pw)
            try:
                for loc in ("en-US", "de-DE"):
                    run_locale(browser, base, loc)
            finally:
                browser.close()
    finally:
        srv.shutdown()
    print("SYSTEM TEST PASSED")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"SYSTEM TEST FAILED: {e}", file=sys.stderr)
        sys.exit(1)
