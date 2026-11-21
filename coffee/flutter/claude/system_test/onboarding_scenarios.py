"""Onboarding (OE-75 S1) and S6 system scenarios for run_system_test.py.

The app scenarios of run_system_test.py start on Heute: they get a browser
wrapper that sets the onboarding flag (`with_flag_preset`). The scenarios here
use the plain browser, so the onboarding shows on fresh storage.
"""

from run_system_test import (
    LABELS,
    SIDEBAR_EXTRA,
    TIMEOUT,
    T,
    click_label,
    count_label,
    enable_semantics,
    find_box,
    focused_value,
    no_hscroll,
    semantic_texts,
    wait_labels,
)

FLAG_KEY = "flutter.onboardingDone"
SKIP_FLAG_JS = (
    f"if (localStorage.getItem('{FLAG_KEY}') === null) "
    f"localStorage.setItem('{FLAG_KEY}', 'true');"
)

ONBOARDING = {
    "en-US": dict(
        welcome="Welcome",
        skip="Skip",
        next="Next",
        back="Back",
        features="What the app does",
        later="Later",
        grinder="Your grinder",
        finish="All set",
        lets_go="Let's go",
        step2="Step 2 of 4",
        step4="Step 4 of 4",
    ),
    "de-DE": dict(
        welcome="Willkommen",
        skip="Überspringen",
        next="Weiter",
        back="Zurück",
        features="Das kann die App",
        later="Später",
        grinder="Deine Mühle",
        finish="Alles bereit",
        lets_go="Los geht’s",
        step2="Schritt 2 von 4",
        step4="Schritt 4 von 4",
    ),
}


class _FlagPresetBrowser:
    """Browser wrapper whose contexts start with the onboarding flag set."""

    def __init__(self, browser):
        self._browser = browser

    def new_context(self, **kwargs):
        ctx = self._browser.new_context(**kwargs)
        ctx.add_init_script(SKIP_FLAG_JS)
        return ctx

    def __getattr__(self, name):
        return getattr(self._browser, name)


def with_flag_preset(browser):
    """Wraps [browser] so its contexts skip the onboarding (flag set to true)."""
    return _FlagPresetBrowser(browser)


def watch_errors(page, errors):
    page.on("console", lambda m: errors.append(m.text) if m.type == "error" else None)
    page.on("pageerror", lambda e: errors.append(str(e)))


def assert_hidden(page, labels, what):
    texts = semantic_texts(page)
    present = [lbl for lbl in labels if count_label(texts, lbl) > 0]
    assert not present, f"{what}: must not be visible: {present}; saw {texts[:40]}"


def wait_contains(page, text, what):
    """Wait until some semantics text contains [text]; the onboarding page
    merges its title and body into one node, as cards do (see expect_text)."""
    for _ in range(100):
        if any(text in t for t in semantic_texts(page)):
            return
        page.wait_for_timeout(300)
    raise AssertionError(f"{what}: {text!r} not in {semantic_texts(page)[:40]}")


def assert_no_text(page, text, what):
    texts = semantic_texts(page)
    assert not any(text in t for t in texts), (
        f"{what}: {text!r} must not be visible; saw {texts[:40]}"
    )


def check_phone(browser, base, locale, errors):
    """Phone: onboarding first, Skip -> Heute with flag stored, reload keeps Heute."""
    t = ONBOARDING[locale]
    nav = LABELS[locale]
    what = f"{locale} onboarding"
    ctx = browser.new_context(locale=locale, viewport={"width": 390, "height": 844})
    ctx.set_default_timeout(TIMEOUT)
    page = ctx.new_page()
    watch_errors(page, errors)
    page.goto(base)
    enable_semantics(page)
    wait_contains(page, t["welcome"], f"{what} start")
    assert_hidden(page, nav, f"{what} start")
    no_hscroll(page, f"{what} 390x844")
    print(f"[{locale}] onboarding shown first, no navigation, 390x844 no h-scroll OK")
    click_label(page, t["next"], f"{what} Next", exact=True)
    wait_contains(page, t["features"], f"{what} page 2")
    wait_contains(page, t["step2"], f"{what} progress 2 of 4")
    click_label(page, t["back"], f"{what} Back", exact=True)
    wait_contains(page, t["welcome"], f"{what} page 1 again")
    print(f"[{locale}] Weiter -> page 2 and Zurück -> page 1 OK")
    click_label(page, t["next"], f"{what} Weiter to page 2", exact=True)
    click_label(page, t["next"], f"{what} Weiter to page 3", exact=True)
    wait_contains(page, t["grinder"], f"{what} page 3")
    click_label(page, t["later"], f"{what} Später", exact=True)
    wait_contains(page, t["finish"], f"{what} page 4")
    wait_contains(page, t["step4"], f"{what} progress 4 of 4")
    click_label(page, t["back"], f"{what} Zurück from page 4", exact=True)
    wait_contains(page, t["grinder"], f"{what} page 3 again")
    print(f"[{locale}] pages 2 to 4 reachable: Später -> page 4, Zurück -> page 3 OK")

    click_label(page, t["skip"], f"{what} skip")
    wait_labels(page, nav, f"{what} after skip")
    assert_no_text(page, t["welcome"], f"{what} after skip")
    check_flag_stored(page, what)
    print(f"[{locale}] skip -> Heute shown, {FLAG_KEY}=true OK")

    page.reload()
    enable_semantics(page)
    wait_labels(page, nav, f"{what} after reload")
    assert_no_text(page, t["welcome"], f"{what} after reload")
    print(f"[{locale}] reload -> Heute shown, onboarding not shown again OK")
    assert not errors, f"{what}: console errors: {errors[:5]}"
    ctx.close()


def check_flag_stored(page, what):
    flag = page.evaluate(f"() => localStorage.getItem('{FLAG_KEY}')")
    if flag is None:
        keys = page.evaluate(
            "() => Object.keys(localStorage)"
            ".filter(k => k.toLowerCase().includes('onboarding'))"
        )
        raise AssertionError(
            f"{what}: localStorage has no '{FLAG_KEY}' after skip; "
            f"keys containing 'onboarding': {keys}"
        )
    assert flag == "true", f"{what}: {FLAG_KEY} is {flag!r}, expected 'true'"


def check_desktop(browser, base, locale, errors):
    """Desktop: full-screen onboarding on fresh storage, no sidebar entries."""
    t = ONBOARDING[locale]
    nav = LABELS[locale]
    what = f"{locale} onboarding"
    ctx = browser.new_context(locale=locale, viewport={"width": 1280, "height": 800})
    ctx.set_default_timeout(TIMEOUT)
    page = ctx.new_page()
    watch_errors(page, errors)
    page.goto(base)
    enable_semantics(page)
    wait_contains(page, t["welcome"], f"{what} desktop start")
    assert_hidden(page, nav + SIDEBAR_EXTRA[locale], f"{what} desktop")
    no_hscroll(page, f"{what} 1280x800")
    print(f"[{locale}] desktop 1280x800: onboarding full screen, no sidebar entries OK")
    assert not errors, f"{what}: console errors: {errors[:5]}"
    ctx.close()


def type_into_field(page, label, value, what):
    """Types [value] into the input under the field label [label].

    AppField draws its label as its own text node above the input, so the label
    node is not the input: the click goes into the box below the label, and the
    focused value is checked before the step passes.
    """
    vp = page.viewport_size
    for _ in range(100):  # wait for the label node
        if find_box(page, label):
            break
        page.wait_for_timeout(300)
    box = find_box(page, label)
    assert box, f"{what}: field label {label!r} not found"
    if box["y"] > vp["height"] * 0.6:
        # The fixed Save/Cancel bar covers the lower part: bring the label up.
        page.mouse.move(vp["width"] / 2, vp["height"] / 3)
        page.mouse.wheel(0, box["y"] - vp["height"] * 0.3)
        page.wait_for_timeout(500)
        box = find_box(page, label)
        assert box, f"{what}: field label {label!r} vanished after scrolling"
    seen = []
    for dy in (32, 24, 40, 50, 16):
        page.mouse.click(vp["width"] / 2, box["y"] + box["h"] + dy)
        page.wait_for_timeout(300)
        page.keyboard.press("ControlOrMeta+A")
        page.keyboard.type(value)
        page.wait_for_timeout(200)
        got = focused_value(page)
        seen.append((dy, got))
        if got == value:
            return
    raise AssertionError(
        f"{what}: could not type {value!r} into {label!r}; "
        f"label box={box}, field values seen={seen}"
    )


def check_grinder_visible(browser, base, locale, errors):
    """OE-77: a grinder saved on page 3 is listed under Ausrüstung after Los geht's."""
    t = ONBOARDING[locale]
    tr = T[locale]
    what = f"{locale} onboarding grinder"
    ctx = browser.new_context(locale=locale, viewport={"width": 390, "height": 844})
    ctx.set_default_timeout(TIMEOUT)
    page = ctx.new_page()
    watch_errors(page, errors)
    page.goto(base)
    enable_semantics(page)
    wait_contains(page, t["welcome"], f"{what} start")
    click_label(page, t["next"], f"{what} Weiter 1", exact=True)
    click_label(page, t["next"], f"{what} Weiter 2", exact=True)
    wait_contains(page, t["grinder"], f"{what} page 3")
    values = ["M1", "1", "30", "0.5", "2.5"]
    for i, label in enumerate(tr["fields"]):
        type_into_field(page, label, values[i], what)
    click_label(page, t["next"], f"{what} save", exact=True)
    wait_contains(page, t["finish"], f"{what} page 4")
    click_label(page, t["lets_go"], f"{what} Los geht's", exact=True)
    wait_labels(page, LABELS[locale], f"{what} shell after finish")
    click_label(page, tr["equipment"], f"{what} open Equipment", exact=True)
    wait_contains(page, "M1", f"{what} grinder listed")
    wait_contains(page, "2.5 g", f"{what} dead space shown")
    print(f"[{locale}] OE-77 grinder M1 saved on page 3, listed under Ausrüstung OK")
    assert not errors, f"{what}: console errors: {errors[:5]}"
    ctx.close()


def run_onboarding(browser, base, locale):
    """Runs the onboarding checks for [locale] on fresh storage (no preset)."""
    errors = []
    check_phone(browser, base, locale, errors)
    check_desktop(browser, base, locale, errors)
    check_grinder_visible(browser, base, locale, errors)
