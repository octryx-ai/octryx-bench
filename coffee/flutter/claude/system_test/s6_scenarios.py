"""S6 system scenarios (UC7 care, UC9 export, delete all and import) for
run_system_test.py; the flag preset comes from the app browser passed in."""

import datetime
import json as _json
import re

from run_system_test import (
    LABELS,
    T3,
    T4,
    TIMEOUT,
    T,
    click_label,
    enable_semantics,
    expect_text,
    find_box,
    find_rect,
    type_into,
    type_into_checked,
    wait_labels,
)

T6 = {
    "en-US": dict(
        care="Care",
        due="Due",
        in7="In 7 days",
        done="Done",
        settings="Settings",
        export="Export data",
        import_="Import data",
        paste="Paste JSON",
        confirm="Import",
        delete_all="Delete all data",
        delete="Delete",
        empty="No beans yet",
    ),
    "de-DE": dict(
        care="Pflege",
        due="Fällig",
        in7="In 7 Tagen",
        done="Erledigt",
        settings="Einstellungen",
        export="Daten exportieren",
        import_="Daten importieren",
        paste="JSON einfügen",
        confirm="Importieren",
        delete_all="Alle Daten löschen",
        delete="Löschen",
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
    t, t4, t6 = T[locale], T4[locale], T6[locale]
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
    assert any(b["name"] == "Bohne 1" for b in data["beans"]), (
        f"{what}: bean missing in export"
    )
    print(f"[{locale}] S6 export download {download.suggested_filename} OK")

    _delete_and_import(page, locale, t3, t6, what, path, text)
    ctx.close()


def _delete_and_import(page, locale, t3, t6, what, path, text):
    page.wait_for_timeout(1000)  # the export message shifts the layout
    for _attempt in range(4):
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
