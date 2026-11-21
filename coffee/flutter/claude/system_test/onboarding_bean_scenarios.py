"""OE-78 (Onboarding S4) system scenarios: grinder on page 3, bean on page 4.

Called from onboarding_scenarios.run_onboarding. Uses the plain browser (fresh
storage), so the onboarding shows first, as in the other onboarding checks.
"""

from onboarding_scenarios import (
    ONBOARDING,
    assert_no_text,
    check_flag_stored,
    type_into_field,
    wait_contains,
    watch_errors,
)
from run_system_test import (
    LABELS,
    T3,
    TIMEOUT,
    T,
    click_label,
    enable_semantics,
    semantic_texts,
    wait_labels,
)

BEAN = {
    "en-US": dict(
        created="Created: Bohne 1",
        no_pack="No pack yet",
        add_pack="Add a pack",
        ready_now="Ready now",
        ready_none="Nothing is ready to drink right now.",
        roast="Medium",
        kind="All-round",
    ),
    "de-DE": dict(
        created="Angelegt: Bohne 1",
        no_pack="Ohne Packung",
        add_pack="Packung hinzufügen",
        ready_now="Jetzt trinkbereit",
        ready_none="Gerade ist nichts trinkbereit.",
        roast="Mittel",
        kind="Allround",
    ),
}


def fill_bean_page(page, locale, what):
    """Page 4: bean Bohne 1 (roaster, roast level, kind; no pack), then save."""
    t3 = T3[locale]
    b = BEAN[locale]
    type_into_field(page, t3["name"], "Bohne 1", f"{what} bean name")
    type_into_field(page, t3["roaster"], "Roest", f"{what} bean roaster")
    click_label(page, b["roast"], f"{what} roast level", exact=True)
    click_label(page, b["kind"], f"{what} kind", exact=True)
    click_label(page, ONBOARDING[locale]["next"], f"{what} save bean", exact=True)
    wait_contains(page, b["created"], f"{what} bean created on page 4")


def bean_in_no_pack(texts, b):
    """True when a 'Bohne 1' card shows the add-pack hint and the ready group is
    empty. The ready group only prints its empty message when no bean is ready,
    so a bean listed under 'Jetzt trinkbereit' makes this False."""
    card = any("Bohne 1" in t and b["add_pack"] in t for t in texts)
    ready_empty = any(b["ready_none"] in t for t in texts)
    return card and ready_empty


def check_no_pack(page, locale, what):
    """Heute: Bohne 1 under 'Ohne Packung' with the add-pack hint, not under
    'Jetzt trinkbereit'."""
    b = BEAN[locale]
    wait_contains(page, b["no_pack"], f"{what} region Ohne Packung")
    wait_contains(page, b["add_pack"], f"{what} hint add pack")
    for _ in range(100):
        texts = semantic_texts(page)
        if bean_in_no_pack(texts, b):
            return
        page.wait_for_timeout(300)
    raise AssertionError(
        f"{what}: 'Bohne 1' not under {b['no_pack']!r} (or under "
        f"{b['ready_now']!r}); saw {texts[:40]}"
    )


def check_equipment_and_beans(page, locale, what):
    """Ausrüstung lists M1 with dead space; Bohnenliste lists Bohne 1 without a chip."""
    tr = T[locale]
    t3 = T3[locale]
    click_label(page, tr["equipment"], f"{what} open Equipment", exact=True)
    wait_contains(page, "M1", f"{what} grinder M1 listed")
    wait_contains(page, "2.5 g", f"{what} dead space 2.5 g listed")
    click_label(page, t3["beans"], f"{what} open Beans", exact=True)
    wait_contains(page, "Bohne 1", f"{what} bean listed")
    chips = [t for t in semantic_texts(page) if "Bohne 1" in t and t3["ready"] in t]
    assert not chips, f"{what}: 'Bohne 1' shows a ready chip: {chips}"


def finish_with_grinder_and_bean(page, locale, what):
    """Page 1 to 4 with grinder M1 on page 3 and bean on page 4, then Los geht's."""
    t = ONBOARDING[locale]
    tr = T[locale]
    wait_contains(page, t["welcome"], f"{what} start")
    click_label(page, t["next"], f"{what} Weiter 1", exact=True)
    click_label(page, t["next"], f"{what} Weiter 2", exact=True)
    wait_contains(page, t["grinder"], f"{what} page 3")
    values = ["M1", "1", "30", "0.5", "2.5"]
    for i, label in enumerate(tr["fields"]):
        type_into_field(page, label, values[i], what)
    click_label(page, t["next"], f"{what} save grinder", exact=True)
    wait_contains(page, t["finish"], f"{what} page 4")
    fill_bean_page(page, locale, what)
    click_label(page, t["lets_go"], f"{what} Los geht's", exact=True)
    wait_labels(page, LABELS[locale], f"{what} Heute after finish")
    assert_no_text(page, t["finish"], f"{what} page 4 gone")
    check_flag_stored(page, what)


def check_reload(page, locale, what):
    """Reload: the onboarding is not shown again (the flag is stored). Beans and
    grinders live in memory only, so after a reload Heute is shown without them."""
    t = ONBOARDING[locale]
    page.reload()
    enable_semantics(page)
    wait_labels(page, LABELS[locale], f"{what} after reload")
    assert_no_text(page, t["welcome"], f"{what} after reload")
    assert_no_text(page, t["finish"], f"{what} after reload")


def check_finish_grinder_and_bean(browser, base, locale, errors):
    """OE-78: 'Abschliessen mit Mühle und Bohne' and 'Reload zeigt es nicht erneut'."""
    what = f"{locale} Abschliessen mit Mühle und Bohne"
    ctx = browser.new_context(locale=locale, viewport={"width": 390, "height": 844})
    ctx.set_default_timeout(TIMEOUT)
    page = ctx.new_page()
    watch_errors(page, errors)
    page.goto(base)
    enable_semantics(page)
    finish_with_grinder_and_bean(page, locale, what)
    check_no_pack(page, locale, what)
    check_equipment_and_beans(page, locale, what)
    print(f"[{locale}] OE-78 grinder M1 + bean Bohne 1 finished, Heute OK")
    check_reload(page, locale, f"{locale} Reload zeigt es nicht erneut")
    print(f"[{locale}] OE-78 reload: onboarding not shown again, Heute shown OK")
    assert not errors, f"{what}: console errors: {errors[:5]}"
    ctx.close()
