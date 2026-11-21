#!/usr/bin/env python3
"""Smoke system test for the Kaffee-Begleiter Flutter web app."""
import datetime
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
                    run_s2(browser, base, loc)
                    run_s3(browser, base, loc)
                    run_s4(browser, base, loc)
                    run_s5(browser, base, loc)
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
