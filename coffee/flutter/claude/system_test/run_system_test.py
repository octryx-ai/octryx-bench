#!/usr/bin/env python3
"""Smoke system test for the Kaffee-Begleiter Flutter web app."""
import datetime
import functools
import http.server
import os
import re
import signal
import socket
import subprocess
import sys
import threading
import time
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


BROWSER_START_MS = 60000  # a browser that does not start (e.g. during a Chrome update) fails fast, not at the end


def launch(pw):
    try:
        return pw.chromium.launch(channel="chrome", timeout=BROWSER_START_MS)
    except Exception:
        return pw.chromium.launch(timeout=BROWSER_START_MS)


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
    pat = re.compile(r"^%s(?!\w)" % re.escape(label), re.I)
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


T = {
    "en-US": dict(
        equipment="Equipment", more="More", water="Water", settings="Settings",
        machines_tab="Machines", grinders_tab="Grinders", no_grinder="No grinder yet", no_machine="No machine yet",
        no_water="No water profile yet", add_grinder="Add grinder",
        fields=["Name", "Scale minimum", "Scale maximum", "Scale step", "Dead space"], save="Save",
        sca="Outside SCA", name="Name", hardness="Hardness (required)",
    ),
    "de-DE": dict(
        equipment="Ausrüstung", more="Mehr", water="Wasser", settings="Einstellungen",
        machines_tab="Maschinen", grinders_tab="Mühlen", no_grinder="Noch keine Mühle", no_machine="Noch keine Maschine",
        no_water="Noch kein Wasserprofil", add_grinder="Mühle hinzufügen",
        fields=["Name", "Skala Minimum", "Skala Maximum", "Skala Schritt", "Totraum"], save="Speichern",
        sca="Ausserhalb SCA", name="Name", hardness="Härte (Pflicht)",
    ),
}


def find_rect(page, label, exact=False):
    """Bounding box centre of the first visible semantics node with this label."""
    return page.evaluate(
        """([label, exact]) => {
          const l = label.toLowerCase();
          const nodes = Array.from(document.querySelectorAll('flt-semantics, [aria-label]'));
          let best = null;
          for (const e of nodes) {
            const t = (e.getAttribute('aria-label') || e.textContent || '').trim().toLowerCase();
            const ok = exact ? t === l : (t === l || t.startsWith(l + ' ') || t.startsWith(l + '\\n'));
            if (!ok) continue;
            const r = e.getBoundingClientRect();
            if (r.width < 2 || r.height < 2) continue;
            const pri = e.matches('input,textarea,[role=textbox],[role=button],button') ? 0 : 1;
            if (!best || pri < best.pri) best = {x: r.x + r.width / 2, y: r.y + r.height / 2, pri};
          }
          return best;
        }""",
        [label, exact],
    )


def find_box(page, label):
    """Bounding box (x, y, w, h) of the first semantics node starting with label."""
    return page.evaluate(
        """(label) => {
          const l = label.toLowerCase();
          for (const e of document.querySelectorAll('flt-semantics, [aria-label]')) {
            const t = (e.getAttribute('aria-label') || e.textContent || '').trim().toLowerCase();
            if (!(t === l || t.startsWith(l + ' ') || t.startsWith(l + '\\n'))) continue;
            const r = e.getBoundingClientRect();
            if (r.width < 2 || r.height < 2) continue;
            return {x: r.x, y: r.y, w: r.width, h: r.height};
          }
          return null;
        }""",
        label,
    )


def focused_value(page):
    return page.evaluate(
        "() => { const a = document.activeElement; "
        "return a && /^(INPUT|TEXTAREA)$/.test(a.tagName) ? a.value : null; }"
    )


def type_into_checked(page, label, value, what):
    """Focus the text field of `label` (trying several points inside its node,
    scrolling it into view first), type value and verify the field holds it."""
    for _ in range(100):  # wait for the node; no blind click (it may hit the footer)
        if find_box(page, label):
            break
        page.wait_for_timeout(300)
    box = find_box(page, label)
    assert box, f"{what}: node {label!r} vanished"
    vp = page.viewport_size
    if box["y"] + box["h"] / 2 > vp["height"] * 0.6:
        # The fixed Save/Cancel bar covers the lower part of the screen: bring
        # the field into the upper half before clicking it.
        page.mouse.move(vp["width"] / 2, vp["height"] / 3)
        page.mouse.wheel(0, box["y"] + box["h"] / 2 - vp["height"] * 0.3)
        page.wait_for_timeout(500)
        box = find_box(page, label)
        assert box, f"{what}: node {label!r} vanished after scrolling"
    seen = []
    for frac in (0.5, 0.35, 0.65, 0.8, 0.2):
        page.mouse.click(box["x"] + box["w"] / 2, box["y"] + box["h"] * frac)
        page.wait_for_timeout(300)
        page.keyboard.press("ControlOrMeta+A")
        page.keyboard.type(value)
        page.wait_for_timeout(200)
        got = focused_value(page)
        seen.append((frac, got))
        if got == value:
            return
    raise AssertionError(f"{what}: could not type {value!r} into {label!r}; box={box}, field values seen={seen}")


def click_label(page, label, what, exact=False):
    import time

    end = time.time() + TIMEOUT / 1000
    while time.time() < end:
        r = find_rect(page, label, exact)
        if r:
            vp = page.viewport_size
            if r["y"] > vp["height"] - 2 or r["y"] < 0:
                # Off screen in a long form: scroll the page and look again.
                page.mouse.move(vp["width"] / 2, vp["height"] / 2)
                page.mouse.wheel(0, (r["y"] - vp["height"] / 2))
                page.wait_for_timeout(400)
                continue
            page.mouse.click(r["x"], r["y"])
            page.wait_for_timeout(500)
            return
        page.wait_for_timeout(300)
    raise AssertionError(f"{what}: control {label!r} not found; saw {semantic_texts(page)[:40]}")


def type_into(page, label, value, what):
    click_label(page, label, f"{what} field")
    page.keyboard.press("ControlOrMeta+A")
    page.keyboard.type(value)
    page.wait_for_timeout(150)


def fill_fields(page, labels, values, what):
    """Fill by label; if a field cannot be located, fall back to Tab order."""
    if all(find_rect(page, l) for l in labels):
        for l, v in zip(labels, values):
            type_into(page, l, v, what)
        return
    click_label(page, labels[0], what)
    page.keyboard.press("ControlOrMeta+A")
    page.keyboard.type(values[0])
    for v in values[1:]:
        page.keyboard.press("Tab")
        page.keyboard.press("ControlOrMeta+A")
        page.keyboard.type(v)
    page.wait_for_timeout(150)


def expect_text(page, label, what, contains=False):
    if contains:
        # Cards merge several texts into one semantics node, so match inside.
        for _ in range(100):
            if any(label in t for t in semantic_texts(page)):
                return
            page.wait_for_timeout(300)
        raise AssertionError(f"{what}: {label!r} not in {semantic_texts(page)[:40]}")
    try:
        wait_labels(page, [label], what)
    except AssertionError as e:
        raise AssertionError(f"{what}: expected {label!r} not visible ({e})")


def open_water(page, t, mobile):
    if mobile:
        click_label(page, t["more"], "open More")
    click_label(page, t["water"], "open Water")


def run_s2(browser, base, locale):
    t = T[locale]
    ctx = browser.new_context(locale=locale, viewport={"width": 390, "height": 844})
    ctx.set_default_timeout(TIMEOUT)
    page = ctx.new_page()
    page.goto(base)
    enable_semantics(page)
    wait_labels(page, LABELS[locale], f"{locale} S2 start")

    # Equipment empty states
    click_label(page, t["equipment"], "open Equipment")
    expect_text(page, t["no_grinder"], f"{locale} equipment empty grinder")
    click_label(page, t["machines_tab"], "open Machines tab", exact=True)
    expect_text(page, t["no_machine"], f"{locale} equipment empty machine")
    click_label(page, t["grinders_tab"], "back to Grinders tab", exact=True)
    print(f"[{locale}] S2 equipment empty states OK")

    # UC1: add grinder
    click_label(page, t["add_grinder"], "UC1 add grinder")
    fill_fields(page, t["fields"], ["M1", "1", "30", "0.5", "2.5"], "UC1")
    click_label(page, t["save"], "UC1 save", exact=True)
    expect_text(page, "M1", f"{locale} UC1 grinder name")
    expect_text(page, "2.5 g", f"{locale} UC1 dead space", contains=True)
    print(f"[{locale}] S2 UC1 add grinder OK")

    # Water empty state (mobile via More)
    open_water(page, t, True)
    expect_text(page, t["no_water"], f"{locale} water empty state")
    print(f"[{locale}] S2 water empty state OK")

    # UC6: add water profile (first FAB/button is the add action; try common labels)
    added = False
    for lbl in ("Add water profile", "Wasserprofil hinzufügen", "Add", "Hinzufügen"):
        if find_rect(page, lbl):
            click_label(page, lbl, "UC6 add water")
            added = True
            break
    assert added, f"{locale} UC6: no add-water-profile control found; saw {semantic_texts(page)[:40]}"
    type_into(page, t["name"], "Tap", f"{locale} UC6 name")
    type_into(page, t["hardness"], "30", f"{locale} UC6 hardness")
    click_label(page, t["save"], "UC6 save", exact=True)
    expect_text(page, "Tap", f"{locale} UC6 profile name")
    expect_text(page, t["sca"], f"{locale} UC6 SCA chip", contains=True)
    print(f"[{locale}] S2 UC6 water profile + SCA chip OK")

    # Settings: hardness unit ppm -> 300 ppm
    click_label(page, t["more"], "open More")
    click_label(page, t["settings"], "open Settings")
    click_label(page, "ppm", f"{locale} settings ppm unit")
    page.wait_for_timeout(300)
    click_label(page, t["more"], "open More")
    click_label(page, t["water"], "open Water")
    expect_text(page, "300 ppm", f"{locale} water hardness in ppm", contains=True)
    print(f"[{locale}] S2 settings ppm -> 300 ppm OK")

    # Desktop: water via sidebar
    ctx2 = browser.new_context(locale=locale, viewport={"width": 1280, "height": 800})
    ctx2.set_default_timeout(TIMEOUT)
    p2 = ctx2.new_page()
    p2.goto(base)
    enable_semantics(p2)
    open_water(p2, t, False)
    expect_text(p2, t["no_water"], f"{locale} desktop water empty state")
    print(f"[{locale}] S2 desktop sidebar water OK")
    ctx2.close()
    ctx.close()


T3 = {
    "en-US": dict(
        beans="Beans", empty="No beans yet", add="Add bean", name="Name", roaster="Roaster",
        roast_date="Roast date", weight="Weight", min_stock="Minimum stock (optional)", save="Save", ready="Ready",
        packs="Packs", add_pack="Add pack",
    ),
    "de-DE": dict(
        beans="Bohnen", empty="Noch keine Bohnen", add="Bohne hinzufügen", name="Name", roaster="Röster",
        roast_date="Röstdatum", weight="Gewicht", min_stock="Mindestbestand (optional)", save="Speichern", ready="Bereit",
        packs="Packungen", add_pack="Packung hinzufügen",
    ),
}


def run_s3(browser, base, locale):
    t = T3[locale]
    ctx = browser.new_context(locale=locale, viewport={"width": 390, "height": 844})
    ctx.set_default_timeout(TIMEOUT)
    page = ctx.new_page()
    page.goto(base)
    enable_semantics(page)
    wait_labels(page, LABELS[locale], f"{locale} S3 start")

    # UC2: empty state
    click_label(page, t["beans"], "S3 open Beans tab")
    expect_text(page, t["empty"], f"{locale} S3 beans empty state")
    print(f"[{locale}] S3 beans empty state OK")

    # Add bean (roast level keeps its default, medium)
    click_label(page, t["add"], "S3 add bean")
    roast = (datetime.date.today() - datetime.timedelta(days=12)).isoformat()
    expect_text(page, t["roast_date"], f"{locale} S3 bean form roast date field")
    type_into(page, t["name"], "Bohne 1", f"{locale} S3 name")
    type_into(page, t["roaster"], "Roest", f"{locale} S3 roaster")
    type_into_checked(page, t["roast_date"], roast, f"{locale} S3 roast date")
    type_into_checked(page, t["weight"], "250", f"{locale} S3 weight")
    click_label(page, t["save"], "S3 save bean", exact=True)
    expect_text(page, "Bohne 1", f"{locale} S3 bean name in list", contains=True)
    expect_text(page, t["ready"], f"{locale} S3 ready chip", contains=True)
    print(f"[{locale}] S3 UC2 add bean -> Ready chip OK")

    # Detail: pack list and add-pack button
    click_label(page, "Bohne 1", "S3 open bean card")
    expect_text(page, t["packs"], f"{locale} S3 detail pack list", contains=True)
    expect_text(page, t["add_pack"], f"{locale} S3 add pack button", contains=True)
    print(f"[{locale}] S3 bean detail with pack list OK")
    ctx.close()


T4 = {
    "en-US": dict(
        brew="Brew", empty="No brews yet", log="Log a brew", machine_name="Machine 1",
        machine_fields=["Name", "Brew temperature", "Pre-infusion"], add_machine="Add machine",
        grind="Grind setting", dose="Dose", yield_="Yield", shot="Shot time (s)",
        rec="Recommendation",
    ),
    "de-DE": dict(
        brew="Brühen", empty="Noch keine Brühungen", log="Brühung erfassen", machine_name="Maschine 1",
        machine_fields=["Name", "Brühtemperatur", "Preinfusion"], add_machine="Maschine hinzufügen",
        grind="Mahlgrad", dose="Dosis", yield_="Ausbeute", shot="Shot-Zeit (s)",
        rec="Empfehlung",
    ),
}


def click_containing(page, text, what):
    """Click the smallest visible semantics node whose text contains `text`."""
    for _ in range(60):
        r = page.evaluate(
            """(text) => {
              let best = null;
              for (const e of document.querySelectorAll('flt-semantics, [aria-label]')) {
                const t = (e.getAttribute('aria-label') || e.textContent || '');
                if (!t.includes(text)) continue;
                const r = e.getBoundingClientRect();
                if (r.width < 2 || r.height < 2 || r.y < 0 || r.y > window.innerHeight - 2) continue;
                const a = r.width * r.height;
                if (!best || a < best.a) best = {x: r.x + r.width / 2, y: r.y + r.height / 2, a};
              }
              return best;
            }""",
            text,
        )
        if r:
            page.mouse.click(r["x"], r["y"])
            page.wait_for_timeout(500)
            return
        page.wait_for_timeout(300)
    raise AssertionError(f"{what}: no visible node containing {text!r}; saw {semantic_texts(page)[:40]}")


def expect_scrolling(page, text, what):
    """Like expect_text(contains=True) but scrolls down while looking."""
    for i in range(40):
        if any(text in t for t in semantic_texts(page)):
            return
        if i >= 5:
            vp = page.viewport_size
            page.mouse.move(vp["width"] / 2, vp["height"] / 2)
            page.mouse.wheel(0, vp["height"] / 2)
        page.wait_for_timeout(300)
    raise AssertionError(f"{what}: {text!r} not in {semantic_texts(page)[:40]}")


def run_s4(browser, base, locale):
    t, t3, t4 = T[locale], T3[locale], T4[locale]
    ctx = browser.new_context(locale=locale, viewport={"width": 390, "height": 844})
    ctx.set_default_timeout(TIMEOUT)
    page = ctx.new_page()
    page.goto(base)
    enable_semantics(page)
    wait_labels(page, LABELS[locale], f"{locale} S4 start")

    # Grinder M1 (as in S2)
    click_label(page, t["equipment"], f"{locale} S4 open Equipment")
    click_label(page, t["add_grinder"], f"{locale} S4 add grinder")
    fill_fields(page, t["fields"], ["M1", "1", "30", "0.5", "2.5"], f"{locale} S4 grinder")
    click_label(page, t["save"], f"{locale} S4 save grinder", exact=True)
    expect_text(page, "M1", f"{locale} S4 grinder in list")

    # Machine (temperature and pre-infusion have no defaults, so type them)
    click_label(page, t["machines_tab"], f"{locale} S4 open Machines tab", exact=True)
    expect_text(page, t["no_machine"], f"{locale} S4 machine empty state")
    click_label(page, t4["add_machine"], f"{locale} S4 add machine")
    name_l, temp_l, pre_l = t4["machine_fields"]
    type_into(page, name_l, t4["machine_name"], f"{locale} S4 machine name")
    type_into_checked(page, temp_l, "93", f"{locale} S4 machine temperature")
    type_into_checked(page, pre_l, "0", f"{locale} S4 machine pre-infusion")
    click_label(page, t["save"], f"{locale} S4 save machine", exact=True)
    expect_text(page, t4["machine_name"], f"{locale} S4 machine in list", contains=True)
    print(f"[{locale}] S4 grinder + machine OK")

    # Bean with pack (as in S3)
    click_label(page, t3["beans"], f"{locale} S4 open Beans tab")
    click_label(page, t3["add"], f"{locale} S4 add bean")
    roast = (datetime.date.today() - datetime.timedelta(days=12)).isoformat()
    expect_text(page, t3["roast_date"], f"{locale} S4 bean form roast date field")
    type_into(page, t3["name"], "Bohne 1", f"{locale} S4 bean name")
    type_into(page, t3["roaster"], "Roest", f"{locale} S4 roaster")
    type_into_checked(page, t3["roast_date"], roast, f"{locale} S4 roast date")
    type_into_checked(page, t3["weight"], "250", f"{locale} S4 weight")
    click_label(page, t3["save"], f"{locale} S4 save bean", exact=True)
    expect_text(page, "Bohne 1", f"{locale} S4 bean in list", contains=True)
    print(f"[{locale}] S4 bean + pack OK")

    # Brews: empty state, log espresso 18 g -> 36 g in 27 s
    click_label(page, t4["brew"], f"{locale} S4 open Brew tab")
    expect_text(page, t4["empty"], f"{locale} S4 brews empty state")
    click_label(page, t4["log"], f"{locale} S4 log a brew")
    expect_text(page, t4["grind"], f"{locale} S4 brew form grind field")
    # Single machine, grinder and pack are pre-selected by the form.
    expect_text(page, t4["machine_name"], f"{locale} S4 machine preselected", contains=True)
    expect_text(page, "M1", f"{locale} S4 grinder preselected", contains=True)
    expect_text(page, "Bohne 1", f"{locale} S4 pack preselected", contains=True)
    type_into_checked(page, t4["grind"], "12", f"{locale} S4 grind setting")
    type_into_checked(page, t4["dose"], "18", f"{locale} S4 dose")
    type_into_checked(page, t4["yield_"], "36", f"{locale} S4 yield")
    type_into_checked(page, t4["shot"], "27", f"{locale} S4 shot time")
    click_label(page, t["save"], f"{locale} S4 save brew", exact=True)
    expect_text(page, "27 s", f"{locale} S4 list shows shot time", contains=True)
    print(f"[{locale}] S4 UC3 brew saved -> list shows 27 s OK")

    # Detail with recommendation card
    click_containing(page, "27 s", f"{locale} S4 open brew card")
    expect_scrolling(page, t4["rec"], f"{locale} S4 detail recommendation card")
    print(f"[{locale}] S4 brew detail with recommendation card OK")
    ctx.close()


T5 = {
    "en-US": dict(
        start_filter="Start filter", total="Total water: 320 g", start="Start", next="Next",
        pour="Pour to {n} g", drawdown="Drawdown time (s)", sour="Sour", today="Today", back="Back",
    ),
    "de-DE": dict(
        start_filter="Filter starten", total="Wasser gesamt: 320 g", start="Start", next="Weiter",
        pour="Giesse bis {n} g", drawdown="Abfluss-Zeit (s)", sour="Sauer", today="Heute", back="Zurück",
    ),
}


def run_s5(browser, base, locale):
    t, t3, t4, t5 = T[locale], T3[locale], T4[locale], T5[locale]
    ctx = browser.new_context(locale=locale, viewport={"width": 390, "height": 844})
    ctx.set_default_timeout(TIMEOUT)
    page = ctx.new_page()
    page.goto(base)
    enable_semantics(page)
    wait_labels(page, LABELS[locale], f"{locale} S5 start")

    # Grinder M1 and bean with 250 g pack, roasted 12 days ago (as in S4)
    click_label(page, t["equipment"], f"{locale} S5 open Equipment")
    click_label(page, t["add_grinder"], f"{locale} S5 add grinder")
    fill_fields(page, t["fields"], ["M1", "1", "30", "0.5", "2.5"], f"{locale} S5 grinder")
    click_label(page, t["save"], f"{locale} S5 save grinder", exact=True)
    expect_text(page, "M1", f"{locale} S5 grinder in list")
    click_label(page, t3["beans"], f"{locale} S5 open Beans tab")
    click_label(page, t3["add"], f"{locale} S5 add bean")
    roast = (datetime.date.today() - datetime.timedelta(days=12)).isoformat()
    expect_text(page, t3["roast_date"], f"{locale} S5 bean form roast date field")
    type_into(page, t3["name"], "Bohne 1", f"{locale} S5 bean name")
    type_into(page, t3["roaster"], "Roest", f"{locale} S5 roaster")
    type_into_checked(page, t3["roast_date"], roast, f"{locale} S5 roast date")
    type_into_checked(page, t3["weight"], "250", f"{locale} S5 weight")
    click_label(page, t3["save"], f"{locale} S5 save bean", exact=True)
    expect_text(page, "Bohne 1", f"{locale} S5 bean in list", contains=True)
    print(f"[{locale}] S5 grinder + bean + pack OK")

    # Brews -> Start filter: setup page (grinder and pack are pre-selected)
    click_label(page, t4["brew"], f"{locale} S5 open Brew tab")
    click_label(page, t5["start_filter"], f"{locale} S5 start filter", exact=True)
    expect_text(page, t4["dose"], f"{locale} S5 setup dose field")
    expect_text(page, "M1", f"{locale} S5 grinder preselected", contains=True)
    expect_text(page, "Bohne 1", f"{locale} S5 pack preselected", contains=True)
    type_into_checked(page, t4["dose"], "20", f"{locale} S5 dose")
    expect_text(page, t5["total"], f"{locale} S5 total water line (1:16)", contains=True)
    click_label(page, t5["start"], f"{locale} S5 press Start", exact=True)

    # Focus mode: bloom 40 g, then 120, 220, 320 g
    targets = ["40", "120", "220", "320"]
    for i, n in enumerate(targets):
        expect_text(page, t5["pour"].format(n=n), f"{locale} S5 focus step {i + 1} target", contains=True)
        if i == 0:
            nav = [x for x in semantic_texts(page) if x.strip().lower().startswith(t5["today"].lower())]
            assert not nav, f"{locale} S5 focus mode still shows bottom navigation: {nav}"
        click_label(page, t5["next"], f"{locale} S5 focus Next after {n} g", exact=True)
    print(f"[{locale}] S5 focus mode 40/120/220/320 g OK")

    # Finish page: drawdown 200 s, taste sour, save -> detail with recommendation
    expect_text(page, t5["drawdown"], f"{locale} S5 finish drawdown field")
    type_into_checked(page, t5["drawdown"], "200", f"{locale} S5 drawdown")
    click_label(page, t5["sour"], f"{locale} S5 taste sour")
    click_label(page, t["save"], f"{locale} S5 save brew", exact=True)
    expect_scrolling(page, t4["rec"], f"{locale} S5 detail recommendation card")
    print(f"[{locale}] S5 finish -> detail with recommendation OK")

    # Back to the list: the V60 brew shows 200 s
    if find_rect(page, t5["back"], exact=True):
        click_label(page, t5["back"], f"{locale} S5 back to list", exact=True)
    else:
        page.go_back()
    expect_text(page, "200 s", f"{locale} S5 list shows drawdown time", contains=True)
    print(f"[{locale}] S5 UC5 list shows 200 s OK")
    ctx.close()


T6 = {
    "en-US": dict(
        care="Care", due="Due", in7="In 7 days", done="Done", settings="Settings",
        export="Export data", import_="Import data", paste="Paste JSON", confirm="Import",
        delete_all="Delete all data", delete="Delete", empty="No beans yet",
    ),
    "de-DE": dict(
        care="Pflege", due="Fällig", in7="In 7 Tagen", done="Erledigt", settings="Einstellungen",
        export="Daten exportieren", import_="Daten importieren", paste="JSON einfügen",
        confirm="Importieren", delete_all="Alle Daten löschen", delete="Löschen",
        empty="Noch keine Bohnen",
    ),
}


def add_machine(page, locale, t, t4, what):
    click_label(page, t["equipment"], f"{what} open Equipment")
    click_label(page, t["machines_tab"], f"{what} open Machines tab", exact=True)
    click_label(page, t4["add_machine"], f"{what} add machine")
    name_l, temp_l, pre_l = t4["machine_fields"]
    type_into(page, name_l, t4["machine_name"], f"{what} machine name")
    type_into_checked(page, temp_l, "93", f"{what} machine temperature")
    type_into_checked(page, pre_l, "0", f"{what} machine pre-infusion")
    click_label(page, t["save"], f"{what} save machine", exact=True)
    expect_text(page, t4["machine_name"], f"{what} machine in list", contains=True)


def add_bean(page, locale, t3, what):
    click_label(page, t3["beans"], f"{what} open Beans tab")
    click_label(page, t3["add"], f"{what} add bean")
    roast = (datetime.date.today() - datetime.timedelta(days=12)).isoformat()
    type_into(page, t3["name"], "Bohne 1", f"{what} bean name")
    type_into(page, t3["roaster"], "Roest", f"{what} roaster")
    type_into_checked(page, t3["roast_date"], roast, f"{what} roast date")
    type_into_checked(page, t3["weight"], "250", f"{what} weight")
    click_label(page, t3["save"], f"{what} save bean", exact=True)
    expect_text(page, "Bohne 1", f"{what} bean in list", contains=True)


def open_more_entry(page, t, label, what):
    click_label(page, t["more"], f"{what} open More")
    click_label(page, label, f"{what} open {label}")


def run_s6_care(browser, base, locale):
    """UC7: a machine without care event is due; Done -> In 7 days."""
    t, t3, t4, t6 = T[locale], T3[locale], T4[locale], T6[locale]
    what = f"{locale} S6 care"
    ctx = browser.new_context(locale=locale, viewport={"width": 390, "height": 844})
    ctx.set_default_timeout(TIMEOUT)
    page = ctx.new_page()
    page.goto(base)
    enable_semantics(page)
    wait_labels(page, LABELS[locale], f"{what} start")
    add_machine(page, locale, t, t4, what)
    open_more_entry(page, t, t6["care"], what)
    expect_text(page, t6["due"], f"{what} backflush due", contains=True)
    if find_rect(page, t6["done"], exact=True):
        click_label(page, t6["done"], f"{what} press Done", exact=True)
    else:
        # The button shares one semantics node with its card: click the card's
        # lower right corner, where the button sits (first card = backflush).
        box = find_box(page, "Backflush" if locale == "en-US" else "Backflush")
        assert box, f"{what}: backflush card not found"
        page.mouse.click(box["x"] + box["w"] / 2, box["y"] + box["h"] - 28)
        page.wait_for_timeout(500)
    expect_text(page, t6["in7"], f"{what} backflush in 7 days", contains=True)
    print(f"[{locale}] S6 UC7 care: Due -> Done -> In 7 days OK")
    ctx.close()


# UC8 (gap banner "No ready coffee from 21.11.2026 to 24.11.2026" at 2026-11-16 with
# 90 g and 18 g/day) needs a fixed clock and brew history; the browser runs on the real
# clock, so it is covered by test/features/inventory (unit and widget tests) instead.


def run_s6_transfer(browser, base, locale):
    """UC9: export (download), delete all data, import -> the bean is back."""
    import json as _json

    t, t3, t6 = T[locale], T3[locale], T6[locale]
    what = f"{locale} S6 transfer"
    ctx = browser.new_context(
        locale=locale, viewport={"width": 390, "height": 844}, accept_downloads=True
    )
    ctx.set_default_timeout(TIMEOUT)
    page = ctx.new_page()
    page.goto(base)
    enable_semantics(page)
    wait_labels(page, LABELS[locale], f"{what} start")
    # A grinder and a machine are not needed: a bean with a pack is enough.
    add_bean(page, locale, t3, what)

    open_more_entry(page, t, t6["settings"], what)
    expect_text(page, t6["export"], f"{what} export button", contains=True)
    r = find_rect(page, t6["export"])
    assert r, f"{what}: export button not found"
    with page.expect_download() as info:
        page.mouse.click(r["x"], r["y"])
    download = info.value
    assert re.fullmatch(
        r"coffee-export-\d{4}-\d{2}-\d{2}\.json", download.suggested_filename
    ), f"{what}: unexpected file name {download.suggested_filename!r}"
    path = download.path()
    text = open(path, encoding="utf-8").read()
    data = _json.loads(text)
    assert data["schemaVersion"] == 1, f"{what}: schemaVersion {data['schemaVersion']}"
    assert any(b["name"] == "Bohne 1" for b in data["beans"]), f"{what}: bean missing in export"
    print(f"[{locale}] S6 export download {download.suggested_filename} OK")

    page.wait_for_timeout(1000)  # the export message shifts the layout
    for attempt in range(4):
        # Retry: the click can land on a node that moved while the page settled.
        click_label(page, t6["delete_all"], f"{what} delete all")
        page.wait_for_timeout(700)
        if find_rect(page, t6["delete"], exact=True):
            break
    click_label(page, t6["delete"], f"{what} confirm delete", exact=True)
    page.wait_for_timeout(500)

    # Import: browser file chooser first, paste dialog as fallback.
    imported = False
    r = find_rect(page, t6["import_"])
    if r:
        try:
            with page.expect_file_chooser(timeout=5000) as fc:
                page.mouse.click(r["x"], r["y"])
            fc.value.set_files(path)
            imported = True
        except Exception:
            imported = False
    if not imported:
        click_label(page, t6["paste"], f"{what} open paste dialog")
        click_label(page, "JSON", f"{what} focus JSON field")
        page.keyboard.insert_text(text)
        page.wait_for_timeout(300)
        click_label(page, t6["confirm"], f"{what} confirm import", exact=True)
    page.wait_for_timeout(500)

    click_label(page, t3["beans"], f"{what} open Beans after import")
    expect_text(page, "Bohne 1", f"{what} bean restored", contains=True)
    print(f"[{locale}] S6 UC9 export -> delete all -> import OK")
    ctx.close()


SCENARIOS = (run_locale, run_s2, run_s3, run_s4, run_s5, run_s6_care, run_s6_transfer)
LOCALES = ("en-US", "de-DE")
SHARE_ENV = "SYSTEM_TEST_SHARE"  # "<index>/<count>": this process runs every count-th scenario from index


def workers():
    """How many scenarios run at once: SYSTEM_TEST_WORKERS, else one per three cores, at most 4.

    Every scenario opens its own browser context (its own storage), so they do not see each other's data. Each
    share runs in a fresh process of this script with its own server, Playwright and browser: Playwright drivers
    started from threads, or from multiprocessing workers, could hang at exit (Python 3.9)."""
    wanted = os.environ.get("SYSTEM_TEST_WORKERS", "")
    if wanted.isdigit() and int(wanted) >= 1:
        return int(wanted)
    return max(1, min(4, (os.cpu_count() or 1) // 3))


def run_share(jobs):
    """This process's scenarios on one browser, one after the other; the failures as (scenario, message)."""
    failures = []
    srv, port = serve()
    base = f"http://127.0.0.1:{port}/"
    try:
        with sync_playwright() as pw:
            browser = launch(pw)
            try:
                for scenario, loc in jobs:
                    started = time.monotonic()
                    try:
                        scenario(browser, base, loc)
                    except Exception as e:  # every scenario of the share runs; all failures are reported
                        failures.append(f"{loc} {scenario.__name__}: {str(e).splitlines()[0][:500]}")
                    print(f"[{loc}] {scenario.__name__} took {time.monotonic() - started:.1f} s", flush=True)
                if os.environ.get(SHARE_ENV):
                    leave(failures)
            finally:
                browser.close()
    finally:
        srv.shutdown()
    return failures


def leave(failures):
    """A share's end: its results written, the process leaves at once. With several shares at once a share's
    browser and Playwright shutdown could hang after its last scenario (19.11.2026, Python 3.9, Playwright 1.60);
    the driver ends with this process and takes its browser along."""
    for failure in failures:
        print(f"FAILED {failure}", file=sys.stderr)
    sys.stdout.flush()
    sys.stderr.flush()
    os._exit(1 if failures else 0)


def main():
    jobs = [(scenario, loc) for loc in LOCALES for scenario in SCENARIOS]
    share = os.environ.get(SHARE_ENV, "")
    if share:
        index, count = (int(part) for part in share.split("/"))
        run_share(jobs[index::count])  # leaves the process with the share's exit code (see leave)
    ensure_build()
    count = min(workers(), len(jobs))
    if count == 1:
        failures = run_share(jobs)
    else:
        import tempfile

        # Each share writes to its own file, never a pipe: Chrome and the Playwright driver write to the same
        # stderr, and a pipe nobody reads yet fills up and stops the share (19.11.2026, hung runs).
        logs = [tempfile.TemporaryFile(mode="w+") for _ in range(count)]
        children = [subprocess.Popen([sys.executable, "-u", __file__], env={**os.environ, SHARE_ENV: f"{i}/{count}"},
                                     stdout=logs[i], stderr=subprocess.STDOUT, text=True,
                                     start_new_session=True)  # its driver and browser in its own group
                    for i in range(count)]
        failures = []
        for child, log in zip(children, logs):
            child.wait()
            try:
                os.killpg(child.pid, signal.SIGKILL)  # what the share left behind: its driver and browser
            except ProcessLookupError:
                pass
            log.seek(0)
            output = log.read()
            log.close()
            print(output, end="")
            failures += [line[len("FAILED "):] for line in output.splitlines() if line.startswith("FAILED ")]
            if child.returncode and not failures:
                failures.append(f"a share ended with exit code {child.returncode}")
    if failures:
        raise AssertionError(f"{len(failures)} of {len(jobs)} scenarios failed; first: {failures[0]}")
    print(f"SYSTEM TEST PASSED ({len(jobs)} scenarios, {count} at once)")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"SYSTEM TEST FAILED: {e}", file=sys.stderr)
        sys.exit(1)
