"""System tests for COF-26: equipment, roasters, beans, bags, archive/delete rules."""
import json
import re
import unittest
import uuid
from datetime import date, timedelta

from test_smoke import Base, setUpModule, tearDownModule  # noqa: F401 (module-level browser)

STATE_KEYS = ["version", "machines", "grinders", "roasters", "beans", "bags", "waters", "brews", "settings"]
SETTINGS = {
    "language": "de", "theme": "system", "espressoTimeMinS": 25, "espressoTimeMaxS": 30,
    "backflushSeconds": 1500, "backflushDays": 7, "grinderCleanG": 5000, "descaleBaseDays": 90,
    "hardnessTargetPpm": 68, "filterRatio": 16, "plannedShotsPerDay": 2, "targetCoverDays": 28,
    "idlePurgeHours": 24, "bloomFactor": 2,
}


def uid():
    return str(uuid.uuid4())


def iso(days_ago):
    return (date.today() - timedelta(days=days_ago)).isoformat()


def machine(name="Silvia", type="espresso", **kw):
    return {"id": uid(), "name": name, "type": type, "lastBackflushAt": None, "lastDescaleAt": None,
            "lastDeepCleanAt": None, "shotSecondsSinceBackflush": 0, "archived": False, **kw}


def grinder(name="Mühle", type="stepped", **kw):
    return {"id": uid(), "name": name, "type": type, "settingUnit": "Stufen", "stepSize": 1,
            "rangeMin": None, "rangeMax": None, "higherIsFiner": False, "retentionG": 0.5,
            "gramsSinceClean": 0, "lastCleanAt": None, "lastUsedAt": None, "lastBeanId": None,
            "archived": False, **kw}


def roaster(name="Bohnenwerk", **kw):
    return {"id": uid(), "name": name, "url": "", "leadTimeDays": 3, **kw}


def bean(roaster_id, name="Hausmischung", level="medium", **kw):
    return {"id": uid(), "roasterId": roaster_id, "name": name, "origin": "", "roastLevel": level,
            "notes": "", "archived": False, **kw}


def bag(bean_id, days_ago, weight=250, remaining=None, **kw):
    return {"id": uid(), "beanId": bean_id, "roastDate": iso(days_ago), "weightG": weight,
            "remainingG": weight if remaining is None else remaining, "price": None,
            "openedOn": None, **kw}


def brew(machine_id, grinder_id, bag_id):
    return {"id": uid(), "createdAt": date.today().isoformat() + "T08:00:00Z", "method": "espresso",
            "machineId": machine_id, "grinderId": grinder_id, "grinderSetting": 5, "bagId": bag_id,
            "waterId": None, "doseG": 18, "yieldG": 36, "waterG": None, "timeS": 27, "tempC": None,
            "taste": None, "purgeG": 0.5, "favourite": False, "notes": ""}


def make_state(lang="de", **coll):
    state = {"version": 1, "machines": [], "grinders": [], "roasters": [], "beans": [], "bags": [],
             "waters": [], "brews": [], "settings": {**SETTINGS, "language": lang}}
    state.update(coll)
    return state


class Seeded(Base):
    def open_with(self, state, route="#/", width=1280, height=900):
        ctx = self.browser.new_context(viewport={"width": width, "height": height}, locale="de-DE")
        self.addCleanup(ctx.close)
        if state is not None:
            # seed once; later reloads keep what the app saved
            ctx.add_init_script(
                "if (!localStorage.getItem('__seeded')) { localStorage.setItem('__seeded', '1');"
                f" localStorage.setItem('coffee.v1', {json.dumps(json.dumps(state))}); }}")
        page = ctx.new_page()
        page.errors = []
        page.on("console", lambda m: page.errors.append(m.text) if m.type == "error" else None)
        page.on("pageerror", lambda e: page.errors.append(str(e)))
        page.goto(self.url + route)
        page.wait_for_selector("main [data-testid^=screen-]")
        return page

    def stored(self, page):
        return json.loads(page.evaluate("localStorage.getItem('coffee.v1')"))

    def beans_with(self, roaster_name="Bohnenwerk", n_bags=0, days=()):
        r = roaster(roaster_name)
        b = bean(r["id"])
        bags = [bag(b["id"], d) for d in days]
        return make_state(roasters=[r], beans=[b], bags=bags), r, b


class TestSeedShape(unittest.TestCase):
    def test_seed_shape_is_valid(self):
        r = roaster()
        b = bean(r["id"])
        s = make_state(machines=[machine()], grinders=[grinder()], roasters=[r], beans=[b],
                       bags=[bag(b["id"], 3)])
        self.assertEqual(list(s.keys()), STATE_KEYS)
        self.assertEqual(s["version"], 1)
        self.assertEqual(set(s["settings"]), set(SETTINGS))
        self.assertEqual(s["beans"][0]["roasterId"], s["roasters"][0]["id"])
        self.assertEqual(s["bags"][0]["beanId"], s["beans"][0]["id"])
        for g in s["grinders"]:
            self.assertTrue(0 <= g["retentionG"] <= 5)
        for bg in s["bags"]:
            self.assertTrue(0 <= bg["remainingG"] <= bg["weightG"])


class TestSeededRoundTrip(Seeded):
    def test_seeded_state_survives_load(self):
        r = roaster()
        b = bean(r["id"])
        seed = make_state(machines=[machine()], grinders=[grinder()], roasters=[r], beans=[b],
                          bags=[bag(b["id"], 3)])
        page = self.open_with(seed, "#/equipment")
        data = self.stored(page)
        self.assertEqual(set(STATE_KEYS), set(data))
        self.assertEqual(data["version"], 1)
        for k in ["machines", "grinders", "roasters", "beans", "bags"]:
            self.assertEqual(len(data[k]), 1, k)
        self.assertEqual(page.errors, [])


class TestEquipment(Seeded):
    def test_empty_state_single_button(self):
        page = self.open("#/equipment")
        es = page.locator("[data-testid=empty-state]")
        self.assertIn("Noch keine Geräte", es.inner_text())
        self.assertEqual(es.locator("button").count(), 1)
        self.assertEqual(page.locator("main button:not([role=tab]):visible").count(), 1)
        self.assertEqual(page.locator("[data-testid=add-device]").count(), 0)
        self.assertIn("Gerät hinzufügen", es.locator("button").inner_text())

    def test_add_grinder_stepless_defaults(self):
        page = self.open("#/equipment")
        page.click("[data-testid=empty-action]")  # machines tab by default
        page.click("[data-testid=dialog-cancel]")
        # a machine first, so the tabs appear
        page.click("[data-testid=empty-action]")
        page.fill("[data-testid=field-name]", "Silvia")
        page.click("[data-testid=dialog-save]")
        page.wait_for_selector("[data-testid=device-card]")
        page.click("[data-testid=tab-grinders]")
        page.click("[data-testid=empty-action]")
        dlg = page.locator("[data-testid=dialog]")
        opts = dlg.locator("[data-testid=field-grinderType] option")
        self.assertEqual(opts.count(), 4)
        self.assertEqual(sorted(opts.evaluate_all("o => o.map(x => x.value)")),
                         sorted(["stepped", "stepless", "numbered", "hand"]))
        self.assertFalse(page.locator("[data-testid=field-rangeMin]").is_visible())
        page.select_option("[data-testid=field-grinderType]", "stepless")
        self.assertTrue(page.locator("[data-testid=field-rangeMin]").is_visible())
        self.assertEqual(page.input_value("[data-testid=field-rangeMin]"), "0")
        self.assertEqual(page.input_value("[data-testid=field-rangeMax]"), "10")
        self.assertEqual(page.input_value("[data-testid=field-stepSize]"), "0,5")
        self.assertEqual(page.input_value("[data-testid=field-retentionG]").replace(",", "."), "0.5")
        page.fill("[data-testid=field-name]", "Niche Zero")
        page.click("[data-testid=dialog-save]")
        card = page.locator("[data-testid=device-card]")
        card.first.wait_for()
        self.assertEqual(card.count(), 1)
        self.assertIn("Niche Zero", card.inner_text())
        self.assertIn("0,5 g", page.locator("[data-testid=device-retention]").inner_text())
        g = self.stored(page)["grinders"][0]
        self.assertEqual((g["type"], g["rangeMin"], g["rangeMax"], g["stepSize"], g["retentionG"]),
                         ("stepless", 0, 10, 0.5, 0.5))
        self.assertEqual(page.errors, [])

    def test_add_machine_and_tabs(self):
        page = self.open("#/equipment")
        page.click("[data-testid=empty-action]")
        page.fill("[data-testid=field-name]", "Gaggia")
        page.select_option("[data-testid=field-type]", "filter")
        page.click("[data-testid=dialog-save]")
        card = page.locator("[data-testid=device-card]")
        card.first.wait_for()
        self.assertIn("Gaggia", card.inner_text())
        self.assertEqual(self.stored(page)["machines"][0]["type"], "filter")
        self.assertEqual(page.locator("[data-testid=tab-machines]").inner_text().strip(), "Maschinen")
        self.assertEqual(page.locator("[data-testid=tab-grinders]").inner_text().strip(), "Mühlen")
        page.click("[data-testid=tab-grinders]")
        self.assertIn("Noch keine Geräte", page.locator("[data-testid=empty-state]").inner_text())

    def test_eleventh_grinder_refused(self):
        seed = make_state(grinders=[grinder(f"Mühle {i:02d}") for i in range(10)])
        page = self.open_with(seed, "#/equipment")
        page.click("[data-testid=tab-grinders]")
        self.assertEqual(page.locator("[data-testid=device-card]").count(), 10)
        page.click("[data-testid=add-device]")
        page.fill("[data-testid=field-name]", "Elfte")
        page.click("[data-testid=dialog-save]")
        err = page.locator("[data-testid=dialog-error]")
        err.wait_for(state="visible")
        self.assertIn("Höchstens 10 Mühlen", err.inner_text())
        self.assertTrue(page.locator("[data-testid=dialog]").is_visible())
        self.assertEqual(len(self.stored(page)["grinders"]), 10)

    def test_delete_blocked_archive_restore(self):
        m = machine("Silvia")
        g = grinder("Eureka")
        r = roaster()
        b = bean(r["id"])
        bg = bag(b["id"], 10)
        seed = make_state(machines=[m], grinders=[g], roasters=[r], beans=[b], bags=[bg],
                          brews=[brew(m["id"], g["id"], bg["id"])])
        page = self.open_with(seed, "#/equipment")
        page.click("[data-testid=card-menu]")
        page.click("[data-testid=menu-delete]")
        dlg = page.locator("[data-testid=dialog]")
        dlg.wait_for()
        self.assertIn("1 Brews verwenden dieses Gerät", dlg.inner_text())
        self.assertEqual(len(self.stored(page)["machines"]), 1)
        page.get_by_role("button", name="Archivieren").click()
        page.wait_for_selector("[data-testid=dialog]", state="detached")
        self.assertEqual(page.locator("[data-testid=device-card]").count(), 0)
        self.assertTrue(self.stored(page)["machines"][0]["archived"])
        page.check("[data-testid=show-archived]")
        card = page.locator("[data-testid=device-card]")
        card.first.wait_for()
        self.assertIn("Silvia", card.inner_text())
        page.click("[data-testid=card-menu]")
        page.get_by_test_id("menu-restore").click()
        page.uncheck("[data-testid=show-archived]")
        page.wait_for_selector("[data-testid=device-card]")
        self.assertFalse(self.stored(page)["machines"][0]["archived"])
        self.assertEqual(page.errors, [])

    def test_english_empty_states(self):
        page = self.open_with(make_state(lang="en"), "#/equipment")
        self.assertIn("No devices yet", page.locator("[data-testid=empty-state]").inner_text())
        self.assertIn("Add device", page.locator("[data-testid=empty-action]").inner_text())
        page.goto(self.url + "#/beans")
        page.wait_for_selector("main [data-testid=screen-beans]")
        es = page.locator("[data-testid=empty-state]")
        self.assertIn("No beans yet", es.inner_text())
        self.assertEqual(es.locator("button").count(), 1)
        self.assertIn("Add bean", es.inner_text())


class TestRoasters(Seeded):
    def test_roaster_dialog_validation_and_edit(self):
        seed, r, b = self.beans_with("Bohnenwerk")
        page = self.open_with(seed, "#/beans")
        page.click("[data-testid=add-roaster]")
        self.assertEqual(page.input_value("[data-testid=field-leadTimeDays]"), "3")
        page.click("[data-testid=dialog-save]")
        self.assertIn("Name: 1–60 Zeichen", page.inner_text("[data-testid=error-name]"))
        page.fill("[data-testid=field-name]", "Kaffeekunst")
        page.fill("[data-testid=field-url]", "ftp://x")
        page.click("[data-testid=dialog-save]")
        self.assertIn("http", page.inner_text("[data-testid=error-url]"))
        self.assertTrue(page.locator("[data-testid=dialog]").is_visible())
        page.fill("[data-testid=field-url]", "https://x.de")
        page.click("[data-testid=dialog-save]")
        page.wait_for_selector("[data-testid=dialog]", state="detached")
        self.assertIn("Röstereien", page.inner_text("main"))
        rows = page.locator("[data-testid=roaster-row]")
        self.assertEqual(rows.count(), 2)
        saved = [x for x in self.stored(page)["roasters"] if x["name"] == "Kaffeekunst"][0]
        self.assertEqual((saved["url"], saved["leadTimeDays"]), ("https://x.de", 3))
        # edit
        row = rows.filter(has_text="Kaffeekunst")
        row.locator("[data-testid=roaster-edit]").click()
        self.assertEqual(page.input_value("[data-testid=field-name]"), "Kaffeekunst")
        page.fill("[data-testid=field-name]", "Kaffeekunst Berlin")
        page.fill("[data-testid=field-leadTimeDays]", "5")
        page.click("[data-testid=dialog-save]")
        page.wait_for_selector("[data-testid=dialog]", state="detached")
        self.assertEqual(rows.filter(has_text="Kaffeekunst Berlin").count(), 1)
        saved = [x for x in self.stored(page)["roasters"] if x["name"] == "Kaffeekunst Berlin"][0]
        self.assertEqual(saved["leadTimeDays"], 5)
        self.assertEqual(page.errors, [])


class TestBeansAndBags(Seeded):
    def test_bag_ordering_oldest_first_and_rest_chips(self):
        # medium roast, espresso table (SPEC 4.7): resting < 7 d, ready 7..21 d, past_peak > 21 d
        seed, r, b = self.beans_with(days=[2, 30, 10])
        page = self.open_with(seed, "#/beans")
        page.click("[data-testid=bean-expand]")
        rows = page.locator("[data-testid=bag-row]")
        self.assertEqual(rows.count(), 3)
        self.assertEqual(rows.evaluate_all(
            "r => r.map(x => x.querySelector('[data-testid=rest-chip]').dataset.status)"),
            ["past_peak", "ready", "resting"])
        ready_on = date.today() - timedelta(days=2) + timedelta(days=7)
        text = rows.nth(2).locator("[data-testid=rest-chip]").inner_text()
        self.assertRegex(text, r"Bereit am \d{1,2}\.\d{1,2}\.")
        self.assertIn(f"{ready_on.day}.{ready_on.month}.", text)
        self.assertIn("bereit", rows.nth(1).locator("[data-testid=rest-chip]").inner_text())
        self.assertIn("Peak", rows.nth(0).locator("[data-testid=rest-chip]").inner_text())
        self.assertEqual(page.errors, [])

    def test_bag_form_validation(self):
        seed, r, b = self.beans_with(days=[10])
        page = self.open_with(seed, "#/beans")
        page.click("[data-testid=add-bag]")
        future = (date.today() + timedelta(days=3)).isoformat()
        page.fill("[data-testid=field-roastDate]", future)
        page.click("[data-testid=dialog-save]")
        self.assertIn("Röstdatum darf nicht in der Zukunft liegen",
                      page.inner_text("[data-testid=error-roastDate]"))
        page.fill("[data-testid=field-roastDate]", iso(1))
        page.fill("[data-testid=field-weightG]", "250")
        page.fill("[data-testid=field-remainingG]", "300")
        page.click("[data-testid=dialog-save]")
        self.assertIn("Restmenge darf das Packungsgewicht nicht überschreiten",
                      page.inner_text("[data-testid=error-remainingG]"))
        self.assertEqual(len(self.stored(page)["bags"]), 1)
        page.fill("[data-testid=field-remainingG]", "200")
        page.click("[data-testid=dialog-save]")
        page.wait_for_selector("[data-testid=dialog]", state="detached")
        self.assertEqual(len(self.stored(page)["bags"]), 2)

    def test_bean_name_too_long(self):
        seed, r, b = self.beans_with()
        page = self.open_with(seed, "#/beans")
        page.click("[data-testid=add-bean]")
        page.fill("[data-testid=field-name]", "x" * 61)
        page.click("[data-testid=dialog-save]")
        self.assertIn("Name: 1–60 Zeichen", page.inner_text("[data-testid=error-name]"))
        self.assertEqual(len(self.stored(page)["beans"]), 1)

    def test_hue_shared_by_roaster(self):
        name = "Bohnenwerk"
        r = roaster(name)
        other = roaster("Andere Rösterei")
        b1 = bean(r["id"], "Alpha")
        b2 = bean(r["id"], "Beta", level="dark")
        b3 = bean(other["id"], "Gamma")
        seed = make_state(roasters=[r, other], beans=[b1, b2, b3])
        page = self.open_with(seed, "#/beans")
        hue = lambda n: page.locator("[data-testid=bean-card]").filter(has_text=n).locator(
            "[data-testid=bean-anchor]").evaluate("e => e.style.getPropertyValue('--h').trim()")
        expected = lambda s: str(15 + sum(ord(c) for c in s) % 45)
        self.assertEqual(hue("Alpha"), hue("Beta"))
        self.assertEqual(hue("Alpha"), expected(name))
        self.assertEqual(hue("Gamma"), expected("Andere Rösterei"))


if __name__ == "__main__":
    unittest.main()
