"""Onboarding (OE-75 S1) and S6 system scenarios for run_system_test.py.

The app scenarios of run_system_test.py start on Heute: they get a browser
wrapper that sets the onboarding flag (`with_flag_preset`). The scenarios here
use the plain browser, so the onboarding shows on fresh storage.
"""

from run_system_test import (
    LABELS,
    SIDEBAR_EXTRA,
    TIMEOUT,
    click_label,
    count_label,
    enable_semantics,
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
    click_label(page, t["back"], f"{what} Back", exact=True)
    wait_contains(page, t["welcome"], f"{what} page 1 again")
    print(f"[{locale}] Weiter -> page 2 and Zurück -> page 1 OK")
    click_label(page, t["next"], f"{what} Weiter to page 2", exact=True)
    click_label(page, t["next"], f"{what} Weiter to page 3", exact=True)
    wait_contains(page, t["grinder"], f"{what} page 3")
    click_label(page, t["later"], f"{what} Später", exact=True)
    wait_contains(page, t["finish"], f"{what} page 4")
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


def run_onboarding(browser, base, locale):
    """Runs the onboarding checks for [locale] on fresh storage (no preset)."""
    errors = []
    check_phone(browser, base, locale, errors)
    check_desktop(browser, base, locale, errors)
