"""System tests for COF-29: care tasks, bean stock / order hints, water profiles, Heute rows,
settings, export / import / reset."""
import json
import re
from datetime import date, datetime, timedelta, timezone

from test_smoke import Base, setUpModule, tearDownModule  # noqa: F401 (module-level browser)
from test_equipment_beans import (Seeded, make_state, machine, grinder, roaster, bean, bag, brew,
                                  iso, uid, STATE_KEYS, SETTINGS)

TASK = "[data-testid=care-task]"


def ts(**delta):
    return (datetime.now(timezone.utc) - timedelta(**delta)).strftime("%Y-%m-%dT%H:%M:%S.000Z")


def water(name="Quelle", **kw):
    return {"id": uid(), "name": name, "tdsMgL": 120, "hardnessPpm": 136, "alkalinityPpm": 90,
            "ph": 7.2, "chlorineMgL": None, **kw}


def care_state(lang="de"):
    """SPEC 4.4 example: backflush 1512/1500 s, grinder 4000/5000 g, descale 30/45 days (136 ppm)."""
    m = machine("Silvia", shotSecondsSinceBackflush=1512, lastDescaleAt=ts(days=30))
    m2 = machine("Bezzera", type="filter")
    g = grinder("Eureka", gramsSinceClean=4000)
    r = roaster()
    b = bean(r["id"])
    bg = bag(b["id"], 20)
    w = water("Hartes Wasser")
    br = {**brew(m["id"], g["id"], bg["id"]), "waterId": w["id"]}
    s = make_state(lang=lang, machines=[m, m2], grinders=[g], roasters=[r], beans=[b], bags=[bg],
                   waters=[w], brews=[br])
    return s, m, m2, g, w


def bean_state(doses=(17,), bag_weight=250, bag_remaining=None, extra_bags=(), lang="de"):
    """One roaster (lead time 3 d), one medium bean, one ready bag, one brew per dose (all today)."""
    m, g, r = machine("Silvia"), grinder("Eureka"), roaster()
    b = bean(r["id"])
    bg = bag(b["id"], 20, weight=bag_weight, remaining=bag_remaining)
    bags = [bg] + [bag(b["id"], d, weight=w, remaining=rem) for d, w, rem in extra_bags]
    brews = [{**brew(m["id"], g["id"], bg["id"]), "doseG": d} for d in doses]
    return make_state(lang=lang, machines=[m], grinders=[g], roasters=[r], beans=[b], bags=bags,
                      brews=brews)


def kinds(page):
    return [(e.get_attribute("data-kind"), e.get_attribute("data-device"))
            for e in page.locator(TASK).all()]


def progress(page, kind, device):
    sel = f"{TASK}[data-kind={kind}][data-device='{device}'] [data-testid=care-progress-text]"
    return page.inner_text(sel).strip()


def toast_text(page):
    page.wait_for_selector("[data-testid=toast-success]")
    return page.locator("[data-testid=toast-success]").last.inner_text()


class TestCare(Seeded):
    def test_progress_sorted_and_done_resets(self):
        s, m, m2, g, w = care_state()
        page = self.open_with(s, "#/care")
        page.wait_for_selector(TASK)
        # SPEC 4.4: ratios 1.008 backflush, 0.8 grinder, 0.667 descale (45 d), 0 descale (90 d)
        self.assertEqual(kinds(page), [("backflush", m["id"]), ("grinderClean", g["id"]),
                                       ("descale", m["id"]), ("descale", m2["id"])])
        self.assertEqual(progress(page, "backflush", m["id"]), "1512 / 1500 s")
        self.assertEqual(progress(page, "grinderClean", g["id"]), "4000 / 5000 g")
        self.assertEqual(progress(page, "descale", m["id"]), "30 / 45 Tage")
        self.assertEqual(progress(page, "descale", m2["id"]), "0 / 90 Tage")
        self.assertEqual(page.locator("[data-testid=care-progress]").count(), 4)
        self.assertEqual(page.locator("[data-testid=care-done]").count(), 4)
        for b in page.locator("[data-testid=care-done]").all():
            self.assertEqual(b.inner_text().strip(), "Erledigt")
        self.assertEqual(page.locator("[data-testid=care-overdue]").count(), 1)

        # backflush done: counter 0, lastBackflushAt = now, nothing else touched
        page.click(f"{TASK}[data-kind=backflush][data-device='{m['id']}'] [data-testid=care-done]")
        self.assertIn("Pflege erledigt", toast_text(page))
        data = self.stored(page)
        sm = next(x for x in data["machines"] if x["id"] == m["id"])
        self.assertEqual(sm["shotSecondsSinceBackflush"], 0)
        at = datetime.fromisoformat(sm["lastBackflushAt"].replace("Z", "+00:00"))
        self.assertLess(abs((datetime.now(timezone.utc) - at).total_seconds()), 120)
        self.assertEqual(sm["lastDescaleAt"], s["machines"][0]["lastDescaleAt"])
        self.assertEqual(data["grinders"][0]["gramsSinceClean"], 4000)
        self.assertEqual(progress(page, "backflush", m["id"]), "0 / 1500 s")
        self.assertEqual(kinds(page)[0], ("grinderClean", g["id"]))
        self.assertEqual(page.locator("[data-testid=care-overdue]").count(), 0)

        # grinder clean: grams 0, lastCleanAt set
        page.click(f"{TASK}[data-kind=grinderClean] [data-testid=care-done]")
        sg = self.stored(page)["grinders"][0]
        self.assertEqual(sg["gramsSinceClean"], 0)
        self.assertIsNotNone(sg["lastCleanAt"])
        self.assertEqual(progress(page, "grinderClean", g["id"]), "0 / 5000 g")

        # descale: only lastDescaleAt changes; seconds untouched
        page.click(f"{TASK}[data-kind=descale][data-device='{m['id']}'] [data-testid=care-done]")
        sm = next(x for x in self.stored(page)["machines"] if x["id"] == m["id"])
        self.assertNotEqual(sm["lastDescaleAt"], s["machines"][0]["lastDescaleAt"])
        at = datetime.fromisoformat(sm["lastDescaleAt"].replace("Z", "+00:00"))
        self.assertLess(abs((datetime.now(timezone.utc) - at).total_seconds()), 120)
        self.assertEqual(sm["shotSecondsSinceBackflush"], 0)
        self.assertEqual(progress(page, "descale", m["id"]), "0 / 45 Tage")
        self.assertEqual(page.errors, [])

    def test_done_on_descale_keeps_backflush_counter(self):
        s, m, *_ = care_state()
        page = self.open_with(s, "#/care")
        page.wait_for_selector(TASK)
        page.click(f"{TASK}[data-kind=descale][data-device='{m['id']}'] [data-testid=care-done]")
        sm = next(x for x in self.stored(page)["machines"] if x["id"] == m["id"])
        self.assertEqual(sm["shotSecondsSinceBackflush"], 1512)
        self.assertIsNone(sm["lastBackflushAt"])
        self.assertEqual(progress(page, "backflush", m["id"]), "1512 / 1500 s")

    def test_empty_state_single_button(self):
        page = self.open("#/care")
        es = page.locator("[data-testid=empty-state]")
        self.assertIn("Alles sauber", es.inner_text())
        self.assertEqual(es.locator("button").count(), 1)
        self.assertEqual(page.locator("main button:not([role=tab]):visible").count(), 1)
        self.assertIn("Gerät hinzufügen", es.locator("button").inner_text())
        self.assertEqual(page.locator(TASK).count(), 0)
        page.click("[data-testid=empty-action]")
        page.wait_for_selector("main [data-testid=screen-equipment]")

    def test_english(self):
        s, m, m2, g, w = care_state(lang="en")
        page = self.open_with(s, "#/care")
        page.wait_for_selector(TASK)
        self.assertEqual(progress(page, "backflush", m["id"]), "1512 / 1500 s")
        self.assertEqual(progress(page, "descale", m["id"]), "30 / 45 days")
        self.assertEqual(progress(page, "grinderClean", g["id"]), "4000 / 5000 g")
        self.assertEqual(page.locator("[data-testid=care-done]").first.inner_text().strip(), "Done")
        body = page.locator("main").inner_text()
        for text in ("Backflush", "Descale", "Clean grinder"):
            self.assertIn(text, body)
        self.assertNotIn("Erledigt", body)
        page2 = self.open_with(make_state(lang="en"), "#/care")
        self.assertIn("All clean", page2.inner_text("[data-testid=empty-state]"))
        self.assertIn("Add device", page2.inner_text("[data-testid=empty-action]"))


class TestBeanHints(Seeded):
    def card(self, page):
        c = page.locator("[data-testid=bean-card]").first
        c.wait_for()
        return c

    def test_stock_shots_cover_and_order_chip(self):
        # SPEC 4.8: 250 g bag, dose 17 -> 14 shots, cover 7 days, order 3 bags
        page = self.open_with(bean_state(), "#/beans")
        c = self.card(page)
        self.assertIn("250 g", c.locator("[data-testid=bean-stock]").inner_text())
        self.assertIn("14", c.locator("[data-testid=bean-shots]").inner_text())
        self.assertIn("7 Tage", c.locator("[data-testid=bean-cover]").inner_text())
        chip = c.locator("[data-testid=order-chip]")
        self.assertEqual(chip.count(), 1)
        self.assertEqual(chip.inner_text().strip(), "Jetzt bestellen · 3 Packungen")
        self.assertEqual(page.errors, [])

    def test_no_chip_when_stock_is_large(self):
        # 1000 g, 17 g dose: cover floor(1000/34) = 29 days, reorder point 340 g -> no hint
        page = self.open_with(bean_state(bag_weight=1000), "#/beans")
        c = self.card(page)
        self.assertIn("29 Tage", c.locator("[data-testid=bean-cover]").inner_text())
        self.assertEqual(c.locator("[data-testid=order-chip]").count(), 0)

    def test_resting_bag_counts_as_ordered(self):
        s = bean_state(extra_bags=[(2, 250, None)])  # second bag roasted 2 days ago (resting, medium)
        page = self.open_with(s, "#/beans")
        c = self.card(page)
        self.assertIn("500 g", c.locator("[data-testid=bean-stock]").inner_text())
        self.assertEqual(c.locator("[data-testid=order-chip]").count(), 0)

    def test_daily_use_zero_shows_dash_and_no_chip(self):
        s = bean_state(doses=())  # no brews: no last dose, daily use 0
        page = self.open_with(s, "#/beans")
        c = self.card(page)
        self.assertIn("250 g", c.locator("[data-testid=bean-stock]").inner_text())
        self.assertIn("–", c.locator("[data-testid=bean-cover]").inner_text())
        self.assertNotIn("Tage", c.locator("[data-testid=bean-cover]").inner_text())
        self.assertEqual(c.locator("[data-testid=order-chip]").count(), 0)
        self.assertEqual(page.errors, [])

    def test_english_order_chip(self):
        page = self.open_with(bean_state(lang="en"), "#/beans")
        c = self.card(page)
        self.assertEqual(c.locator("[data-testid=order-chip]").inner_text().strip(),
                         "Order now · 3 bags")
        self.assertIn("7 days", c.locator("[data-testid=bean-cover]").inner_text())


class TestWater(Seeded):
    def fill_water(self, page, name=None, tds=None, hardness=None, alk=None, ph=None, chlorine=None):
        for field, v in (("name", name), ("tdsMgL", tds), ("hardnessPpm", hardness),
                         ("alkalinityPpm", alk), ("ph", ph), ("chlorineMgL", chlorine)):
            if v is not None:
                page.fill(f"[data-testid=field-{field}]", v)

    def test_empty_state_single_button(self):
        page = self.open("#/water")
        es = page.locator("[data-testid=empty-state]")
        self.assertIn("Noch keine", es.inner_text())
        self.assertEqual(es.locator("button").count(), 1)
        self.assertEqual(page.locator("main button:not([role=tab]):visible").count(), 1)
        self.assertIn("Wasserprofil hinzufügen", es.locator("button").inner_text())
        self.assertEqual(page.locator("[data-testid=add-water]").count(), 0)

    def test_invalid_ph_blocked_then_valid_saved_with_chips(self):
        page = self.open("#/water")
        page.click("[data-testid=empty-action]")
        page.wait_for_selector("[data-testid=dialog]")
        self.fill_water(page, name="Brita", ph="15")
        page.click("[data-testid=dialog-save]")
        page.wait_for_selector("[data-testid=error-ph]")
        self.assertIn("pH-Wert muss zwischen 0 und 14 liegen", page.inner_text("[data-testid=error-ph]"))
        self.assertTrue(page.locator("[data-testid=dialog]").is_visible())
        self.assertEqual(self.stored(page)["waters"], [])
        # SPEC 4.9 example: TDS 120 ok, hardness 136 ok, alkalinity 90 warn, pH 7.2 ok
        self.fill_water(page, tds="120", hardness="136", alk="90", ph="7,2")
        page.click("[data-testid=dialog-save]")
        page.wait_for_selector("[data-testid=dialog]", state="detached")
        saved = self.stored(page)["waters"]
        self.assertEqual(len(saved), 1)
        w = saved[0]
        self.assertEqual((w["name"], w["tdsMgL"], w["hardnessPpm"], w["alkalinityPpm"], w["ph"],
                          w["chlorineMgL"]), ("Brita", 120, 136, 90, 7.2, None))
        card = page.locator("[data-testid=water-card]")
        card.first.wait_for()
        self.assertEqual(card.count(), 1)
        self.assertEqual(page.locator("[data-testid=empty-state]").count(), 0)
        self.assertTrue(page.locator("[data-testid=add-water]").is_visible())
        status = {c.get_attribute("data-field"): c.get_attribute("data-status")
                  for c in card.locator("[data-testid=water-chip]").all()}
        self.assertEqual(status, {"tdsMgL": "ok", "hardnessPpm": "ok", "alkalinityPpm": "warn",
                                  "ph": "ok", "chlorineMgL": "none"})
        for c in card.locator("[data-testid=water-chip]").all():
            self.assertTrue(c.is_visible())
        self.assertIn("Zu hoch", card.locator("[data-testid=water-chip][data-field=alkalinityPpm]").inner_text())
        self.assertEqual(card.locator("[data-testid=water-chip][data-field=chlorineMgL]").inner_text().strip(), "–")
        ranges = card.locator("[data-testid=water-range]")
        self.assertEqual(ranges.count(), 5)
        for r in ranges.all():
            self.assertTrue(r.is_visible())
        self.assertEqual(page.errors, [])

    def test_ranges_in_dialog_and_hardness_target_from_settings(self):
        s = make_state()
        s["settings"]["hardnessTargetPpm"] = 80
        s["waters"] = [water("Quelle")]
        page = self.open_with(s, "#/water")
        card = page.locator("[data-testid=water-card]").first
        card.wait_for()
        hard = card.locator("[data-field=hardnessPpm] [data-testid=water-range]").inner_text()
        self.assertIn("80", hard)
        self.assertIn("50", hard)
        self.assertIn("175", hard)
        self.assertNotIn("68", hard)
        ph = card.locator("[data-field=ph] [data-testid=water-range]").inner_text()
        self.assertIn("7", ph)
        self.assertIn("6,5", ph)
        self.assertIn("7,5", ph)
        # ranges are also beside the inputs of the dialog
        page.click("[data-testid=add-water]")
        page.wait_for_selector("[data-testid=dialog]")
        dlg_ranges = page.locator("[data-testid=dialog] [data-testid=water-range]")
        self.assertEqual(dlg_ranges.count(), 5)
        self.assertIn("80", dlg_ranges.nth(1).inner_text())

    def test_edit_updates_status(self):
        s = make_state()
        s["waters"] = [water("Quelle")]
        page = self.open_with(s, "#/water")
        page.wait_for_selector("[data-testid=water-card]")
        page.click("[data-testid=water-edit]")
        page.wait_for_selector("[data-testid=dialog]")
        self.fill_water(page, alk="50")
        page.click("[data-testid=dialog-save]")
        page.wait_for_selector("[data-testid=dialog]", state="detached")
        page.wait_for_function(
            "document.querySelector('[data-testid=water-chip][data-field=alkalinityPpm]')"
            ".dataset.status === 'ok'")
        self.assertEqual(self.stored(page)["waters"][0]["alkalinityPpm"], 50)

    def test_delete_blocked_when_used_by_brew(self):
        s, m, m2, g, w = care_state()
        s["waters"].append(water("Frei"))
        page = self.open_with(s, "#/water")
        page.wait_for_selector("[data-testid=water-card]")
        used = page.locator("[data-testid=water-card]", has_text="Hartes Wasser")
        used.locator("[data-testid=water-delete]").click()
        page.wait_for_selector("[data-testid=dialog-error]")
        self.assertIn("1 Brews verwenden", page.inner_text("[data-testid=dialog-error]"))
        self.assertEqual(page.locator("[data-testid=archive-instead]").count(), 0)
        page.click("[data-testid=dialog-cancel]")
        page.wait_for_selector("[data-testid=dialog]", state="detached")
        self.assertEqual(len(self.stored(page)["waters"]), 2)
        # an unused profile is deleted
        page.locator("[data-testid=water-card]", has_text="Frei").locator("[data-testid=water-delete]").click()
        self.assertIn("Gelöscht", toast_text(page))
        self.assertEqual([x["name"] for x in self.stored(page)["waters"]], ["Hartes Wasser"])
        self.assertEqual(page.locator("[data-testid=water-card]").count(), 1)

    def test_english(self):
        page = self.open_with(make_state(lang="en"), "#/water")
        es = page.locator("[data-testid=empty-state]")
        self.assertIn("No water profiles yet", es.inner_text())
        self.assertIn("Add water profile", es.locator("button").inner_text())
        s = make_state(lang="en")
        s["waters"] = [water("Spring")]
        page = self.open_with(s, "#/water")
        card = page.locator("[data-testid=water-card]").first
        card.wait_for()
        self.assertEqual(card.locator("[data-field=alkalinityPpm][data-testid=water-chip]").inner_text().strip(),
                         "Too high")
        self.assertEqual(card.locator("[data-field=hardnessPpm][data-testid=water-chip]").inner_text().strip(),
                         "OK")
        self.assertEqual(card.locator("[data-field=hardnessPpm] [data-testid=water-range]").inner_text().strip(),
                         "Target 68 · OK 50–175 ppm")
        self.assertIn("Alkalinity", card.inner_text())
        page.click("[data-testid=add-water]")
        page.wait_for_selector("[data-testid=dialog]")
        self.fill_water(page, name="x", ph="15")
        page.click("[data-testid=dialog-save]")
        page.wait_for_selector("[data-testid=error-ph]")
        self.assertIn("pH must be between 0 and 14", page.inner_text("[data-testid=error-ph]"))


class TestToday(Seeded):
    def today_state(self):
        """Due backflush, bean to order (250 g, dose 17), bean with a resting bag, one brew."""
        s, m, m2, g, w = care_state()
        s["machines"] = [m]  # only Silvia; descale not due (30/45)
        s["waters"], s["brews"][0]["waterId"] = [], None
        s["machines"][0]["lastDescaleAt"] = None
        s["brews"][0]["doseG"] = 17
        r = s["roasters"][0]
        resting_bean = bean(r["id"], name="Neuling")
        s["beans"].append(resting_bean)
        s["bags"].append(bag(resting_bean["id"], 2))  # medium espresso: ready in 5 days
        return s

    def test_rows_with_due_order_and_resting(self):
        s = self.today_state()
        page = self.open_with(s, "#/")
        page.wait_for_selector("[data-testid=today-due]")
        due = page.locator("[data-testid=today-due]")
        self.assertEqual(due.locator("h2").inner_text().strip(), "Fällig")
        chips = due.locator("[data-testid=due-chip]")
        self.assertEqual(chips.count(), 1)
        self.assertEqual(chips.first.get_attribute("data-kind"), "backflush")
        self.assertIn("Rückspülen", chips.first.inner_text())
        self.assertIn("Silvia", chips.first.inner_text())

        beans = page.locator("[data-testid=today-beans]")
        self.assertTrue(beans.is_visible())
        self.assertEqual(beans.locator("h2").inner_text().strip(), "Bohnen")
        order = beans.locator("[data-testid=today-order]")
        self.assertEqual(order.count(), 1)
        self.assertIn("Hausmischung", order.inner_text())
        self.assertIn("Jetzt bestellen · 3 Packungen", order.inner_text())
        resting = beans.locator("[data-testid=today-resting]")
        self.assertEqual(resting.count(), 1)
        ready = date.today() + timedelta(days=5)
        txt = resting.inner_text()
        self.assertIn("Neuling", txt)
        self.assertTrue(f"Bereit am {ready.day}.{ready.month}." in txt
                        or f"Bereit am {ready.day:02d}.{ready.month:02d}." in txt, txt)

        last = page.locator("[data-testid=today-last-brews]")
        self.assertTrue(last.is_visible())
        self.assertEqual(last.locator("[data-testid=today-brew-card]").count(), 1)
        self.assertEqual(page.locator("[data-testid=today-empty]").count(), 0)
        self.assertEqual(page.errors, [])

    def test_due_chip_links_to_care(self):
        page = self.open_with(self.today_state(), "#/")
        page.click("[data-testid=due-chip]")
        page.wait_for_selector("main [data-testid=screen-care]")

    def test_empty_rows_hidden_with_heading(self):
        # one brew from a big bag: nothing due, nothing to order, nothing resting
        s = bean_state(doses=(18,), bag_weight=1000)
        page = self.open_with(s, "#/")
        page.wait_for_selector("[data-testid=today-last-brews]")
        self.assertFalse(page.locator("[data-testid=today-due]").is_visible())
        self.assertFalse(page.locator("[data-testid=today-beans]").is_visible())
        main = page.locator("main").inner_text()
        self.assertNotIn("Fällig", main)
        self.assertNotIn("Jetzt bestellen", main)
        self.assertEqual(page.locator("[data-testid=today-empty]").count(), 0)

        # only a resting bag: Bohnen row shown, Fällig and last brews hidden
        r = roaster()
        b = bean(r["id"])
        s2 = make_state(roasters=[r], beans=[b], bags=[bag(b["id"], 1)])
        page = self.open_with(s2, "#/")
        page.wait_for_selector("[data-testid=today-beans]")
        self.assertTrue(page.locator("[data-testid=today-resting]").is_visible())
        self.assertFalse(page.locator("[data-testid=today-due]").is_visible())
        self.assertFalse(page.locator("[data-testid=today-last-brews]").is_visible())
        self.assertEqual(page.locator("[data-testid=today-empty]").count(), 0)

    def test_all_empty_text(self):
        for state in (None, make_state(machines=[machine()], grinders=[grinder()])):
            page = self.open_with(state, "#/")
            page.wait_for_selector("[data-testid=today-empty]")
            self.assertEqual(page.inner_text("[data-testid=today-empty]").strip(),
                             "Noch kein Brew – starte mit deinem ersten Shot.")
            for tid in ("today-due", "today-beans", "today-last-brews"):
                self.assertFalse(page.locator(f"[data-testid={tid}]").is_visible())

    def test_english_rows(self):
        s = self.today_state()
        s["settings"]["language"] = "en"
        page = self.open_with(s, "#/")
        page.wait_for_selector("[data-testid=today-due]")
        self.assertEqual(page.locator("[data-testid=today-due] h2").inner_text().strip(), "Due")
        self.assertEqual(page.locator("[data-testid=today-beans] h2").inner_text().strip(), "Beans")
        self.assertIn("Order now · 3 bags", page.inner_text("[data-testid=today-order]"))
        self.assertIn("Ready", page.inner_text("[data-testid=today-resting]"))
        page2 = self.open_with(make_state(lang="en"), "#/")
        self.assertEqual(page2.inner_text("[data-testid=today-empty]").strip(),
                         "No brew yet – start with your first shot.")


def seeded_full(brews=1, lang="de"):
    m, g, r = machine("Silvia"), grinder("Eureka"), roaster()
    b = bean(r["id"])
    bg = bag(b["id"], 20, weight=1000)
    s = make_state(lang=lang, machines=[m], grinders=[g], roasters=[r], beans=[b], bags=[bg],
                   waters=[water()],
                   brews=[brew(m["id"], g["id"], bg["id"]) for _ in range(brews)])
    return s


class TestSettings(Seeded):
    def save(self, page):
        page.click("[data-testid=settings-save]")

    def test_save_changes_storage_and_toasts(self):
        page = self.open_with(None, "#/settings")
        page.fill("[data-testid=settings-espressoTimeMaxS]", "40")
        self.save(page)
        self.assertIn("Einstellungen gespeichert", toast_text(page))
        s = self.stored(page)["settings"]
        self.assertEqual(s["espressoTimeMaxS"], 40)
        self.assertEqual(s["espressoTimeMinS"], 25)
        self.assertEqual(s["backflushSeconds"], 1500)
        self.assertEqual(page.locator("[data-testid=settings-save]").inner_text().strip(), "Speichern")
        # survives a reload
        page.reload()
        page.wait_for_selector("[data-testid=settings-espressoTimeMaxS]")
        self.assertEqual(page.input_value("[data-testid=settings-espressoTimeMaxS]"), "40")
        self.assertEqual(page.errors, [])

    def test_all_rule_fields_present_with_defaults(self):
        page = self.open_with(None, "#/settings")
        for name, value in (("espressoTimeMinS", "25"), ("espressoTimeMaxS", "30"),
                            ("backflushSeconds", "1500"), ("backflushDays", "7"),
                            ("grinderCleanG", "5000"), ("descaleBaseDays", "90"),
                            ("hardnessTargetPpm", "68"), ("filterRatio", "16"),
                            ("plannedShotsPerDay", "2"), ("targetCoverDays", "28"),
                            ("idlePurgeHours", "24"), ("bloomFactor", "2")):
            with self.subTest(field=name):
                self.assertEqual(page.input_value(f"[data-testid=settings-{name}]"), value)

    def test_invalid_values_show_errors_and_are_not_saved(self):
        page = self.open_with(None, "#/settings")
        page.fill("[data-testid=settings-espressoTimeMaxS]", "0")
        page.fill("[data-testid=settings-hardnessTargetPpm]", "abc")
        self.save(page)
        page.wait_for_selector("[data-testid=error-espressoTimeMaxS]")
        self.assertTrue(page.locator("[data-testid=error-hardnessTargetPpm]").is_visible())
        self.assertIn("Maximum", page.inner_text("[data-testid=error-espressoTimeMaxS]"))
        self.assertEqual(page.locator("[data-testid=toast-success]").count(), 0)
        s = self.stored(page)["settings"]
        self.assertEqual((s["espressoTimeMaxS"], s["hardnessTargetPpm"]), (30, 68))
        # min must stay below max
        page.fill("[data-testid=settings-espressoTimeMaxS]", "30")
        page.fill("[data-testid=settings-hardnessTargetPpm]", "68")
        page.fill("[data-testid=settings-espressoTimeMinS]", "35")
        self.save(page)
        page.wait_for_selector("[data-testid=error-espressoTimeMinS]")
        self.assertEqual(self.stored(page)["settings"]["espressoTimeMinS"], 25)
        # fixing everything saves
        page.fill("[data-testid=settings-espressoTimeMinS]", "20")
        page.fill("[data-testid=settings-hardnessTargetPpm]", "80")
        self.save(page)
        self.assertIn("Einstellungen gespeichert", toast_text(page))
        s = self.stored(page)["settings"]
        self.assertEqual((s["espressoTimeMinS"], s["hardnessTargetPpm"]), (20, 80))

    def test_changed_default_feeds_time_class(self):
        s = seeded_full()
        page = self.open_with(s, "#/brews/new")
        page.wait_for_selector("main [data-testid=brew-form]")

        def klass():
            page.fill("[data-testid=field-grinderSetting]", "5")
            page.fill("[data-testid=field-doseG]", "18")
            page.fill("[data-testid=field-yieldG]", "36")
            page.fill("[data-testid=field-timeS]", "35")
            page.wait_for_selector("[data-testid=preview-timeclass]")
            return page.get_attribute("[data-testid=preview-timeclass]", "data-status")

        self.assertEqual(klass(), "warn")  # SPEC 4.2: 35 s > 30 s max is slow
        page.evaluate("location.hash = '#/settings'")
        page.wait_for_selector("main [data-testid=screen-settings]")
        page.fill("[data-testid=settings-espressoTimeMaxS]", "40")
        self.save(page)
        toast_text(page)
        page.evaluate("location.hash = '#/brews/new'")
        page.wait_for_selector("main [data-testid=brew-form]")
        self.assertEqual(klass(), "ok")

    def test_english_settings(self):
        page = self.open_with(make_state(lang="en"), "#/settings")
        self.assertEqual(page.locator("[data-testid=settings-save]").inner_text().strip(), "Save")
        page.fill("[data-testid=settings-espressoTimeMaxS]", "0")
        self.save(page)
        page.wait_for_selector("[data-testid=error-espressoTimeMaxS]")
        page.fill("[data-testid=settings-espressoTimeMaxS]", "35")
        self.save(page)
        self.assertIn("Settings saved", toast_text(page))


class TestData(Seeded):
    def upload(self, page, content):
        data = content if isinstance(content, str) else json.dumps(content)
        page.set_input_files("[data-testid=import-file]", files=[{
            "name": "backup.json", "mimeType": "application/json", "buffer": data.encode()}])

    def test_export_file(self):
        s = seeded_full(brews=2)
        page = self.open_with(s, "#/settings")
        with page.expect_download() as dl:
            page.click("[data-testid=export-data]")
        d = dl.value
        today_local = date.today().isoformat()
        today_utc = datetime.now(timezone.utc).date().isoformat()
        self.assertRegex(d.suggested_filename, r"^coffee-export-\d{4}-\d{2}-\d{2}\.json$")
        self.assertIn(d.suggested_filename,
                      {f"coffee-export-{today_local}.json", f"coffee-export-{today_utc}.json"})
        with open(d.path(), encoding="utf-8") as fh:
            data = json.load(fh)
        self.assertEqual(data["version"], 1)
        self.assertEqual(set(data), set(STATE_KEYS))
        self.assertEqual([b["id"] for b in data["brews"]], [b["id"] for b in s["brews"]])
        self.assertEqual(len(data["machines"]), 1)
        self.assertEqual(len(data["waters"]), 1)
        self.assertEqual(data["settings"], s["settings"])
        self.assertIn("Export gespeichert", toast_text(page))

    def test_import_confirm_replaces_data(self):
        a = seeded_full(brews=1)
        b = seeded_full(brews=3)
        page = self.open_with(a, "#/settings")
        self.upload(page, b)
        page.wait_for_selector("[data-testid=confirm-dialog]")
        self.assertTrue(page.locator("[data-testid=confirm-ok]").is_visible())
        # nothing replaced before the confirmation
        self.assertEqual([x["id"] for x in self.stored(page)["brews"]], [x["id"] for x in a["brews"]])
        page.click("[data-testid=confirm-ok]")
        self.assertIn("Daten importiert", toast_text(page))
        data = self.stored(page)
        self.assertEqual([x["id"] for x in data["brews"]], [x["id"] for x in b["brews"]])
        self.assertEqual(data["machines"][0]["id"], b["machines"][0]["id"])
        self.assertEqual(page.locator("[data-testid=confirm-dialog]").count(), 0)
        self.assertEqual(page.errors, [])

    def test_import_cancel_keeps_data(self):
        a = seeded_full(brews=1)
        page = self.open_with(a, "#/settings")
        self.upload(page, seeded_full(brews=3))
        page.wait_for_selector("[data-testid=confirm-dialog]")
        page.click("[data-testid=confirm-cancel]")
        page.wait_for_selector("[data-testid=confirm-dialog]", state="detached")
        self.assertEqual([x["id"] for x in self.stored(page)["brews"]], [x["id"] for x in a["brews"]])
        self.assertEqual(self.stored(page)["machines"][0]["id"], a["machines"][0]["id"])

    def test_import_invalid_file(self):
        a = seeded_full(brews=1)
        page = self.open_with(a, "#/settings")
        bad_version = {**seeded_full(brews=2), "version": 2}
        missing = {k: v for k, v in seeded_full(brews=2).items() if k != "brews"}
        for label, content in (("not json", "{nope"), ("array", "[1, 2]"),
                               ("version 2", bad_version), ("missing brews", missing)):
            with self.subTest(case=label):
                self.upload(page, content)
                page.wait_for_selector("[data-testid=import-error]", state="visible")
                self.assertIn("Ungültige Datei", page.inner_text("[data-testid=import-error]"))
                self.assertEqual(page.locator("[data-testid=confirm-dialog]").count(), 0)
                self.assertEqual([x["id"] for x in self.stored(page)["brews"]],
                                 [x["id"] for x in a["brews"]])

    def test_reset_needs_confirmation(self):
        s = seeded_full(brews=2)
        s["settings"]["espressoTimeMaxS"] = 40
        page = self.open_with(s, "#/settings")
        page.click("[data-testid=reset-data]")
        page.wait_for_selector("[data-testid=confirm-dialog]")
        page.click("[data-testid=confirm-cancel]")
        page.wait_for_selector("[data-testid=confirm-dialog]", state="detached")
        data = self.stored(page)
        self.assertEqual(len(data["brews"]), 2)
        self.assertEqual(data["settings"]["espressoTimeMaxS"], 40)

        page.click("[data-testid=reset-data]")
        page.wait_for_selector("[data-testid=confirm-dialog]")
        page.click("[data-testid=confirm-ok]")
        self.assertIn("Alle Daten zurückgesetzt", toast_text(page))
        data = self.stored(page)
        for k in ["machines", "grinders", "roasters", "beans", "bags", "waters", "brews"]:
            self.assertEqual(data[k], [], k)
        self.assertEqual(data["version"], 1)
        self.assertEqual(data["settings"], SETTINGS)
        self.assertEqual(page.errors, [])

    def test_english_data_buttons(self):
        page = self.open_with(seeded_full(lang="en"), "#/settings")
        self.assertEqual(page.locator("[data-testid=export-data]").inner_text().strip(), "Export data")
        self.upload(page, "{nope")
        page.wait_for_selector("[data-testid=import-error]", state="visible")
        self.assertIn("Invalid file", page.inner_text("[data-testid=import-error]"))
        self.assertRegex(re.sub(r"\s+", " ", page.locator("[data-testid=import-data]").inner_text()),
                         "Import data")


if __name__ == "__main__":
    import unittest
    unittest.main()
