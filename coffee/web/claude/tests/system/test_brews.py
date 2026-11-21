"""System tests for COF-27: log an espresso shot, brews list / filter / favourite / detail."""
from datetime import datetime, timedelta, timezone

from test_smoke import Base, setUpModule, tearDownModule  # noqa: F401 (module-level browser)
from test_equipment_beans import (Seeded, make_state, machine, grinder, roaster, bean, bag, brew,
                                  iso, uid)

NEW = "#/brews/new"


def full_state(lang="de", bag_days=20, bag_remaining=None, grinder_kw=None, bean_kw=None):
    """One machine, one grinder, one roaster, one bean, one (ready by default) bag."""
    m = machine("Silvia")
    g = grinder("Eureka", **(grinder_kw or {}))
    r = roaster()
    b = bean(r["id"], **(bean_kw or {}))
    bg = bag(b["id"], bag_days, remaining=bag_remaining)
    s = make_state(lang=lang, machines=[m], grinders=[g], roasters=[r], beans=[b], bags=[bg])
    return s, m, g, b, bg


def ts(**delta):
    return (datetime.now(timezone.utc) - timedelta(**delta)).strftime("%Y-%m-%dT%H:%M:%S.000Z")


class BrewBase(Seeded):
    def form(self, page, dose=None, yield_=None, time=None, setting="5"):
        if setting is not None:
            page.fill("[data-testid=field-grinderSetting]", setting)
        if dose is not None:
            page.fill("[data-testid=field-doseG]", dose)
        if yield_ is not None:
            page.fill("[data-testid=field-yieldG]", yield_)
        if time is not None:
            page.fill("[data-testid=field-timeS]", time)

    def save_and_wait_list(self, page):
        page.click("[data-testid=save-brew]")
        page.wait_for_selector("main [data-testid=screen-brews]")

    def new_form(self, state, **kw):
        page = self.open_with(state, NEW, **kw)
        page.wait_for_selector("main [data-testid=screen-brew-new] [data-testid=brew-form]")
        return page


class TestFullFlow(BrewBase):
    def test_empty_state_to_first_shot(self):
        page = self.open("#/equipment")
        # machine, then grinder (both are required by the brew form)
        page.click("[data-testid=empty-action]")
        page.fill("[data-testid=field-name]", "Silvia")
        page.click("[data-testid=dialog-save]")
        page.wait_for_selector("[data-testid=device-card]")
        page.click("[data-testid=tab-grinders]")
        page.click("[data-testid=empty-action]")
        page.fill("[data-testid=field-name]", "Eureka")
        page.fill("[data-testid=field-retentionG]", "0.6")
        page.click("[data-testid=dialog-save]")
        page.wait_for_selector("[data-testid=device-card]")
        # roaster + bean in one dialog
        page.goto(self.url + "#/beans")
        page.wait_for_selector("main [data-testid=screen-beans]")
        page.click("[data-testid=empty-action]")
        page.fill("[data-testid=field-name]", "Hausmischung")
        page.fill("[data-testid=field-newRoaster]", "Bohnenwerk")
        page.click("[data-testid=dialog-save]")
        page.wait_for_selector("[data-testid=dialog]", state="detached")
        page.wait_for_selector("[data-testid=add-bag]")
        # bag roasted ~20 days ago, so it is ready
        page.click("[data-testid=add-bag]")
        page.fill("[data-testid=field-roastDate]", iso(20))
        page.click("[data-testid=dialog-save]")
        page.wait_for_selector("[data-testid=dialog]", state="detached")
        data = self.stored(page)
        self.assertEqual((len(data["machines"]), len(data["grinders"]), len(data["beans"]),
                          len(data["bags"])), (1, 1, 1, 1))

        page.goto(self.url + NEW)
        page.wait_for_selector("main [data-testid=screen-brew-new] [data-testid=brew-form]")
        self.assertEqual(page.locator("[data-testid=no-bag-notice]").count(), 0)
        self.form(page, dose="18", yield_="36", time="27")
        ratio = page.inner_text("[data-testid=preview-ratio]")
        self.assertIn("1:2,0", ratio)
        self.assertEqual(page.get_attribute("[data-testid=preview-timeclass]", "data-status"), "ok")
        self.assertEqual(page.locator("[data-testid=recommendation]").count(), 0)
        page.click("[data-testid=taste-sour]")
        page.wait_for_selector("[data-testid=recommendation]")
        steps = page.locator("[data-testid=recommendation-step]").count()
        self.assertTrue(1 <= steps <= 3, steps)
        self.save_and_wait_list(page)
        card = page.locator("[data-testid=brew-card]")
        card.first.wait_for()
        self.assertEqual(card.count(), 1)
        self.assertIn("18,0 g → 36,0 g · 1:2,0 · 27 s", card.locator("[data-testid=brew-summary]").inner_text())
        saved = self.stored(page)["brews"]
        self.assertEqual(len(saved), 1)
        b = saved[0]
        self.assertEqual((b["method"], b["doseG"], b["yieldG"], b["timeS"], b["taste"], b["purgeG"]),
                         ("espresso", 18, 36, 27, "sour", 0))
        self.assertEqual(page.errors, [])


class TestPreview(BrewBase):
    def test_preview_updates_while_typing(self):
        s, *_ = full_state()
        page = self.new_form(s)
        self.assertEqual(page.locator("[data-testid=preview-timeclass]").count(), 0)
        self.form(page, dose="17", yield_="34")
        self.assertIn("1:2,0", page.inner_text("[data-testid=preview-ratio]"))
        self.form(page, dose="18", yield_="54", setting=None)
        self.assertIn("1:3,0", page.inner_text("[data-testid=preview-ratio]"))
        # SPEC 4.2: 27 ok; 20 fast (warn); 19 too_fast (error); 33 slow (warn); 36 too_slow (error)
        for t, status in (("27", "ok"), ("20", "warn"), ("19", "error"), ("33", "warn"), ("36", "error")):
            with self.subTest(time=t):
                page.fill("[data-testid=field-timeS]", t)
                self.assertEqual(page.get_attribute("[data-testid=preview-timeclass]", "data-status"), status)
        self.assertEqual(page.errors, [])

    def test_first_use_has_no_purge_advice(self):
        s, *_ = full_state()
        page = self.new_form(s)
        self.assertFalse(page.locator("[data-testid=purge-advice]").is_visible())


class TestValidation(BrewBase):
    def test_range_errors_block_save(self):
        s, *_ = full_state()
        page = self.new_form(s)
        self.form(page, dose="61", yield_="201", time="601")
        page.click("[data-testid=save-brew]")
        page.wait_for_selector("[data-testid=error-doseG]")
        self.assertIn("Dosis muss zwischen 1 und 60 g liegen", page.inner_text("[data-testid=error-doseG]"))
        self.assertIn("Ausbeute muss zwischen 1 und 200 g liegen", page.inner_text("[data-testid=error-yieldG]"))
        self.assertIn("Zeit muss zwischen 0 und 600 s liegen", page.inner_text("[data-testid=error-timeS]"))
        self.assertTrue(page.locator("[data-testid=brew-form]").is_visible())
        self.assertTrue(page.url.endswith(NEW))
        self.assertEqual(self.stored(page)["brews"], [])
        # fixing the values saves
        self.form(page, dose="18", yield_="36", time="27", setting=None)
        self.save_and_wait_list(page)
        self.assertEqual(len(self.stored(page)["brews"]), 1)

    def test_missing_time_and_setting_rejected(self):
        s, *_ = full_state()
        page = self.new_form(s)
        page.click("[data-testid=save-brew]")
        page.wait_for_selector("[data-testid=error-timeS]")
        self.assertIn("Zeit muss zwischen 0 und 600 s liegen", page.inner_text("[data-testid=error-timeS]"))
        self.assertEqual(self.stored(page)["brews"], [])


class TestTimer(BrewBase):
    def test_timer_start_stop_fills_time(self):
        s, *_ = full_state()
        page = self.new_form(s)
        self.assertEqual(page.inner_text("[data-testid=timer-display]").strip(), "00:00.0")
        self.assertEqual(page.get_attribute("[data-testid=timer-live]", "aria-live"), "polite")
        page.click("[data-testid=timer-toggle]")
        page.wait_for_function(
            "document.querySelector('[data-testid=timer-display]').textContent !== '00:00.0'")
        page.wait_for_timeout(1200)
        page.click("[data-testid=timer-toggle]")
        value = page.input_value("[data-testid=field-timeS]")
        self.assertRegex(value, r"^\d+[.,]\d$")
        self.assertGreaterEqual(float(value.replace(",", ".")), 1.0)
        self.assertNotEqual(page.inner_text("[data-testid=timer-display]").strip(), "00:00.0")
        self.assertEqual(page.get_attribute("[data-testid=timer-live]", "aria-live"), "polite")
        self.assertIn("Gestoppt", page.inner_text("[data-testid=timer-live]"))
        self.assertEqual(page.locator("[data-testid=preview-timeclass]").count(), 1)
        self.assertEqual(page.errors, [])


class TestRecommendation(BrewBase):
    def test_no_taste_no_panel(self):
        s, *_ = full_state()
        page = self.new_form(s)
        self.form(page, dose="18", yield_="36", time="27")
        self.assertEqual(page.locator("[data-testid=recommendation]").count(), 0)
        page.click("[data-testid=taste-bitter]")
        self.assertEqual(page.get_attribute("[data-testid=recommendation]", "data-state"), "shown")
        page.click("[data-testid=taste-bitter]")  # toggles off again
        self.assertEqual(page.locator("[data-testid=recommendation]").count(), 0)

    def test_balanced_keeps_recipe_and_favourite(self):
        s, *_ = full_state()
        page = self.new_form(s)
        self.form(page, dose="18", yield_="36", time="27")
        page.click("[data-testid=taste-balanced]")
        reco = page.locator("[data-testid=recommendation]")
        reco.wait_for()
        self.assertEqual(reco.get_attribute("data-state"), "keep")
        self.assertEqual(page.locator("[data-testid=recommendation-step]").count(), 1)
        self.assertIn("Dieses Rezept behalten", reco.inner_text())
        page.click("[data-testid=mark-favourite]")
        self.save_and_wait_list(page)
        self.assertTrue(self.stored(page)["brews"][0]["favourite"])
        self.assertEqual(page.locator("[data-testid=fav-toggle]").get_attribute("aria-pressed"), "true")

    def test_sour_too_fast_names_finer_setting(self):
        s, *_ = full_state()  # stepped grinder, stepSize 1, lower = finer
        page = self.new_form(s)
        self.form(page, dose="18", yield_="36", time="19", setting="12")
        page.click("[data-testid=taste-sour]")
        text = page.locator("[data-testid=recommendation-step]").first.inner_text()
        self.assertIn("11", text)
        self.assertIn("feiner", text)


class TestPurgeAndStock(BrewBase):
    def test_same_bean_idle_over_24h_purges_retention(self):
        s, m, g, b, bg = full_state(grinder_kw={"retentionG": 0.6})
        g["lastUsedAt"] = ts(hours=30)
        g["lastBeanId"] = b["id"]
        page = self.new_form(s)
        self.form(page, dose="18", yield_="36", time="27")
        box = page.locator("[data-testid=purge-advice]")
        box.wait_for(state="visible")
        self.assertIn("Vorher 0,6 g mahlen und verwerfen", box.inner_text())
        self.assertIn("18,6", box.inner_text())
        self.save_and_wait_list(page)
        data = self.stored(page)
        self.assertAlmostEqual(data["brews"][0]["purgeG"], 0.6)
        self.assertAlmostEqual(data["bags"][0]["remainingG"], 250 - 18.6, places=2)
        self.assertEqual(data["grinders"][0]["lastBeanId"], b["id"])
        self.assertNotEqual(data["grinders"][0]["lastUsedAt"], g["lastUsedAt"])

    def test_bean_change_doubles_purge(self):
        s, m, g, b, bg = full_state(grinder_kw={"retentionG": 0.6})
        g["lastUsedAt"] = ts(hours=2)
        g["lastBeanId"] = uid()
        page = self.new_form(s)
        self.form(page, dose="18", yield_="36", time="27")
        box = page.locator("[data-testid=purge-advice]")
        box.wait_for(state="visible")
        self.assertIn("Vorher 1,2 g mahlen und verwerfen", box.inner_text())
        self.save_and_wait_list(page)
        data = self.stored(page)
        self.assertAlmostEqual(data["brews"][0]["purgeG"], 1.2)
        self.assertAlmostEqual(data["bags"][0]["remainingG"], 250 - 19.2, places=2)

    def test_recent_use_same_bean_no_purge(self):
        s, m, g, b, bg = full_state(grinder_kw={"retentionG": 0.6})
        g["lastUsedAt"] = ts(hours=5)
        g["lastBeanId"] = b["id"]
        page = self.new_form(s)
        self.form(page, dose="18", yield_="36", time="27")
        self.assertFalse(page.locator("[data-testid=purge-advice]").is_visible())
        self.save_and_wait_list(page)
        data = self.stored(page)
        self.assertEqual(data["brews"][0]["purgeG"], 0)
        self.assertAlmostEqual(data["bags"][0]["remainingG"], 232, places=2)

    def test_low_bag_warns_zeroes_and_still_saves(self):
        s, *_ = full_state(bag_remaining=10)
        page = self.new_form(s)
        self.form(page, dose="18", yield_="36", time="27")
        page.click("[data-testid=save-brew]")
        page.wait_for_selector("main [data-testid=screen-brews]")
        toast = page.locator("[data-testid=toast-warn]")
        toast.wait_for()
        self.assertIn("Packung hat nur noch", toast.inner_text())
        data = self.stored(page)
        self.assertEqual(len(data["brews"]), 1)
        self.assertEqual(data["bags"][0]["remainingG"], 0)
        self.assertEqual(page.errors, [])


class TestBagPicker(BrewBase):
    def test_resting_bag_disabled_with_date(self):
        s, m, g, b, ready = full_state(bag_days=20)
        resting = bag(b["id"], 2)  # medium roast needs 7 days (SPEC 4.7)
        s["bags"].append(resting)
        page = self.new_form(s)
        opts = page.locator("[data-testid=field-bagId] option")
        self.assertEqual(opts.count(), 2)
        self.assertEqual(opts.evaluate_all("o => o.map(x => x.disabled)"), [False, True])
        self.assertEqual(opts.evaluate_all("o => o.map(x => x.value)"), [ready["id"], resting["id"]])
        self.assertRegex(opts.nth(1).inner_text(), r"Bereit am \d{1,2}\.\d{1,2}\.")
        self.assertEqual(page.input_value("[data-testid=field-bagId]"), ready["id"])

    def test_only_resting_bag_cannot_be_saved(self):
        s, *_ = full_state(bag_days=2)
        page = self.new_form(s)
        self.assertTrue(page.locator("[data-testid=field-bagId] option").first.is_disabled()
                        or page.locator("[data-testid=field-bagId] option:disabled").count() >= 1)
        self.form(page, dose="18", yield_="36", time="27")
        page.click("[data-testid=save-brew]")
        page.wait_for_selector("[data-testid=error-bagId]")
        self.assertEqual(self.stored(page)["brews"], [])
        self.assertTrue(page.url.endswith(NEW))

    def test_no_bag_notice_with_link(self):
        s = make_state(machines=[machine()], grinders=[grinder()])
        page = self.new_form(s)
        notice = page.locator("[data-testid=no-bag-notice]")
        self.assertIn("Lege zuerst eine Bohnen-Packung an", notice.inner_text())
        self.assertTrue(page.locator("[data-testid=save-brew]").is_disabled())
        page.click("[data-testid=no-bag-link]")
        page.wait_for_selector("main [data-testid=screen-beans]")


def listing_state(lang="de"):
    m = machine("Silvia")
    ga, gb = grinder("Mühle A"), grinder("Mühle B")
    r = roaster()
    b1, b2 = bean(r["id"], "Alpha"), bean(r["id"], "Beta")
    bg1, bg2 = bag(b1["id"], 20), bag(b2["id"], 20)
    one = {**brew(m["id"], ga["id"], bg1["id"]), "createdAt": ts(days=1)}
    two = {**brew(m["id"], gb["id"], bg2["id"]), "createdAt": ts(days=2), "method": "filter",
           "yieldG": None, "waterG": 288, "timeS": 150, "favourite": True}
    three = {**brew(m["id"], gb["id"], bg1["id"]), "createdAt": ts(days=3), "doseG": 17,
             "yieldG": 34, "timeS": 33}
    # stored out of order on purpose
    s = make_state(lang=lang, machines=[m], grinders=[ga, gb], roasters=[r], beans=[b1, b2],
                   bags=[bg1, bg2], brews=[three, one, two])
    return s, dict(one=one, two=two, three=three, ga=ga, gb=gb, b1=b1, b2=b2)


class TestBrewList(BrewBase):
    def ids(self, page):
        return page.locator("[data-testid=brew-card]").evaluate_all("c => c.map(x => x.dataset.id)")

    def test_newest_first_and_card_content(self):
        s, d = listing_state()
        page = self.open_with(s, "#/brews")
        page.wait_for_selector("[data-testid=brew-card]")
        self.assertEqual(self.ids(page), [d["one"]["id"], d["two"]["id"], d["three"]["id"]])
        first = page.locator("[data-testid=brew-card]").first
        self.assertIn("18,0 g → 36,0 g · 1:2,0 · 27 s", first.locator("[data-testid=brew-summary]").inner_text())
        self.assertEqual(first.locator("[data-testid=brew-bar]").get_attribute("data-status"), "ok")
        third = page.locator("[data-testid=brew-card]").nth(2)
        self.assertIn("17,0 g → 34,0 g · 1:2,0 · 33 s", third.locator("[data-testid=brew-summary]").inner_text())
        self.assertEqual(third.locator("[data-testid=brew-bar]").get_attribute("data-status"), "warn")
        self.assertEqual(page.errors, [])

    def test_filters(self):
        s, d = listing_state()
        page = self.open_with(s, "#/brews")
        page.wait_for_selector("[data-testid=brew-card]")
        cases = [
            ("filter-method", "filter", [d["two"]["id"]]),
            ("filter-method", "espresso", [d["one"]["id"], d["three"]["id"]]),
            ("filter-method", "", [d["one"]["id"], d["two"]["id"], d["three"]["id"]]),
            ("filter-grinder", d["ga"]["id"], [d["one"]["id"]]),
            ("filter-grinder", d["gb"]["id"], [d["two"]["id"], d["three"]["id"]]),
            ("filter-grinder", "", [d["one"]["id"], d["two"]["id"], d["three"]["id"]]),
            ("filter-bean", d["b2"]["id"], [d["two"]["id"]]),
            ("filter-bean", d["b1"]["id"], [d["one"]["id"], d["three"]["id"]]),
        ]
        for testid, value, expected in cases:
            with self.subTest(filter=testid, value=value):
                page.select_option(f"[data-testid={testid}]", value)
                self.assertEqual(self.ids(page), expected)
        page.select_option("[data-testid=filter-bean]", "")
        page.click("[data-testid=filter-fav]")
        self.assertEqual(self.ids(page), [d["two"]["id"]])
        self.assertEqual(page.get_attribute("[data-testid=filter-fav]", "aria-pressed"), "true")

    def test_favourite_toggle_persists(self):
        s, d = listing_state()
        page = self.open_with(s, "#/brews")
        page.wait_for_selector("[data-testid=brew-card]")
        star = page.locator(f"[data-testid=brew-card][data-id='{d['one']['id']}'] [data-testid=fav-toggle]")
        self.assertEqual(star.get_attribute("aria-pressed"), "false")
        star.click()
        self.assertEqual(star.get_attribute("aria-pressed"), "true")
        self.assertTrue([b for b in self.stored(page)["brews"] if b["id"] == d["one"]["id"]][0]["favourite"])
        self.assertTrue(page.url.endswith("#/brews"))  # star does not open the detail
        page.reload()
        page.wait_for_selector("[data-testid=brew-card]")
        star = page.locator(f"[data-testid=brew-card][data-id='{d['one']['id']}'] [data-testid=fav-toggle]")
        self.assertEqual(star.get_attribute("aria-pressed"), "true")
        page.click("[data-testid=filter-fav]")
        self.assertEqual(self.ids(page), [d["one"]["id"], d["two"]["id"]])

    def test_card_opens_detail(self):
        s, d = listing_state()
        page = self.open_with(s, "#/brews")
        page.wait_for_selector("[data-testid=brew-card]")
        page.click(f"[data-testid=brew-card][data-id='{d['one']['id']}'] a")
        page.wait_for_selector("main [data-testid=screen-brew-detail]")
        self.assertTrue(page.url.endswith("#/brews/" + d["one"]["id"]))
        self.assertIn("18,0 g → 36,0 g · 1:2,0 · 27 s", page.inner_text("[data-testid=detail-summary]"))
        self.assertIn("Alpha", page.inner_text("[data-testid=detail-bean]"))
        self.assertIn("Vorher 0,5 g mahlen und verwerfen", page.inner_text("[data-testid=detail-purge]"))
        page.click("[data-testid=fav-toggle]")
        self.assertEqual(page.get_attribute("[data-testid=fav-toggle]", "aria-pressed"), "true")
        self.assertTrue([b for b in self.stored(page)["brews"] if b["id"] == d["one"]["id"]][0]["favourite"])
        self.assertEqual(page.errors, [])

    def test_empty_state_single_button(self):
        page = self.open("#/brews")
        es = page.locator("[data-testid=empty-state]")
        self.assertIn("Noch keine Brews", es.inner_text())
        self.assertEqual(es.locator("button").count(), 1)
        self.assertEqual(page.locator("main button:not([role=tab]):visible").count(), 1)
        self.assertIn("Ersten Brew erfassen", page.inner_text("[data-testid=empty-action]"))
        page.click("[data-testid=empty-action]")
        page.wait_for_selector("main [data-testid=screen-brew-new]")


class TestEnglish(BrewBase):
    def test_form_labels_and_numbers(self):
        s, *_ = full_state(lang="en")
        page = self.new_form(s)
        self.assertEqual(page.inner_text("[data-testid=save-brew]").strip(), "Save")
        self.assertEqual(page.inner_text("[data-testid=cancel-brew]").strip(), "Cancel")
        self.form(page, dose="18", yield_="36", time="27")
        self.assertIn("18.0", page.inner_text("[data-testid=preview-ratio]"))
        self.assertIn("1:2.0", page.inner_text("[data-testid=preview-ratio]"))
        page.fill("[data-testid=field-doseG]", "61")
        page.click("[data-testid=save-brew]")
        page.wait_for_selector("[data-testid=error-doseG]")
        self.assertIn("Dose must be between 1 and 60 g", page.inner_text("[data-testid=error-doseG]"))

    def test_list_summary_in_english(self):
        s, d = listing_state(lang="en")
        page = self.open_with(s, "#/brews")
        page.wait_for_selector("[data-testid=brew-card]")
        self.assertIn("18.0 g → 36.0 g · 1:2.0 · 27 s",
                      page.locator("[data-testid=brew-summary]").first.inner_text())
        self.assertIn("Favourites", page.inner_text("[data-testid=filter-fav]"))


if __name__ == "__main__":
    import unittest
    unittest.main()
