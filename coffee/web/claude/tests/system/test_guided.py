"""System tests for COF-28: guided filter brew (#/guided, focus mode) and the Heute card."""
import re

from test_smoke import Base, setUpModule, tearDownModule  # noqa: F401 (module-level browser)
from test_equipment_beans import (Seeded, make_state, machine, grinder, roaster, bean, bag, brew,
                                  iso, uid)

GUIDED = "#/guided"


def filter_brew(m, g, bg, dose=25, water=400, **kw):
    b = brew(m["id"], g["id"], bg["id"])
    b.update({"method": "filter", "doseG": dose, "yieldG": None, "waterG": water, "timeS": 150, **kw})
    return b


def gstate(lang="de", brews=(), extra_bags=(), with_bag=True, bag_days=20):
    m = machine("Silvia")
    g = grinder("Eureka")
    r = roaster()
    b = bean(r["id"])
    bags = [bag(b["id"], bag_days)] if with_bag else []
    bags += [bag(b["id"], d) for d in extra_bags]
    s = make_state(lang=lang, machines=[m], grinders=[g], roasters=[r], beans=[b], bags=bags, brews=list(brews))
    return s, m, g, b, bags


class GuidedBase(Seeded):
    def open_guided(self, state, **kw):
        return self.open_with(state, GUIDED, **kw)

    def start(self, page, dose=None):
        """pre-step -> dose step -> first stage."""
        page.wait_for_selector("main [data-testid=screen-guided] [data-testid=guided-pre]")
        page.click("[data-testid=guided-start]")
        page.wait_for_selector("[data-testid=guided-dose]")
        if dose is not None:
            page.fill("[data-testid=guided-dose]", dose)
        page.click("[data-testid=guided-next]")
        page.wait_for_selector("[data-testid=guided-number]")

    def label(self, page):
        return page.inner_text("[data-testid=guided-label]").strip()

    def advance_to_done(self, page):
        for _ in range(3):
            page.click("[data-testid=guided-next]")
        page.wait_for_function(
            "document.querySelector('[data-testid=guided-label]').textContent.includes('Zeit eintragen')"
            " || document.querySelector('[data-testid=guided-label]').textContent.includes('enter time')")


class TestEntry(GuidedBase):
    def test_start_filter_card_opens_guided(self):
        s, *_ = gstate()
        page = self.open_with(s, "#/")
        page.click("[data-testid=start-filter]")
        page.wait_for_selector("main [data-testid=screen-guided]")
        self.assertTrue(page.url.endswith(GUIDED), page.url)
        self.assertEqual(page.errors, [])

    def test_start_card_text(self):
        s, *_ = gstate()
        page = self.open_with(s, "#/")
        self.assertIn("Filterkaffee starten", page.inner_text("[data-testid=start-filter]"))


class TestPreStep(GuidedBase):
    def test_pickers_and_resting_bag_disabled(self):
        s, m, g, b, bags = gstate(extra_bags=[0])  # roasted today: still resting
        page = self.open_guided(s)
        page.wait_for_selector("main [data-testid=guided-pre]")
        for tid in ("field-machineId", "field-grinderId", "field-bagId"):
            self.assertTrue(page.locator(f"[data-testid={tid}]").is_visible(), tid)
        self.assertEqual(page.locator("[data-testid=field-bagId] option").count(), 2)
        disabled = page.locator("[data-testid=field-bagId] option[disabled]")
        self.assertEqual(disabled.count(), 1)
        self.assertEqual(page.input_value("[data-testid=field-bagId]"), bags[0]["id"])
        self.assertTrue(page.locator("[data-testid=guided-start]").is_enabled())

    def test_dose_defaults_to_30(self):
        s, *_ = gstate()
        page = self.open_guided(s)
        page.click("[data-testid=guided-start]")
        page.wait_for_selector("[data-testid=guided-dose]")
        self.assertEqual(page.input_value("[data-testid=guided-dose]"), "30")

    def test_dose_defaults_to_last_filter_dose(self):
        m = machine("Silvia"); g = grinder("Eureka"); r = roaster(); b = bean(r["id"]); bg = bag(b["id"], 20)
        s = make_state(machines=[m], grinders=[g], roasters=[r], beans=[b], bags=[bg],
                       brews=[filter_brew(m, g, bg, dose=25, water=400)])
        page = self.open_guided(s)
        page.click("[data-testid=guided-start]")
        page.wait_for_selector("[data-testid=guided-dose]")
        self.assertEqual(page.input_value("[data-testid=guided-dose]"), "25")

    def test_no_bag_notice(self):
        s, *_ = gstate(with_bag=False)
        page = self.open_guided(s)
        page.wait_for_selector("main [data-testid=guided-pre]")
        self.assertTrue(page.locator("[data-testid=no-bag-notice]").is_visible())
        self.assertTrue(page.locator("[data-testid=guided-start]").is_disabled())


class TestFlow(GuidedBase):
    def test_stage_labels_timer_and_target(self):
        s, *_ = gstate()
        page = self.open_guided(s)
        self.start(page, "30")
        self.assertEqual(self.label(page), "Bloom 60 g")
        self.assertEqual(page.get_attribute("[data-testid=guided-number]", "data-target"), "60")
        self.assertIn("480", page.inner_text("[data-testid=guided-target]"))
        self.assertTrue(page.locator("[data-testid=guided-timer]").is_visible())
        t1 = page.locator("[data-testid=guided-timer] .guided__time").inner_text()
        page.wait_for_timeout(1300)
        t2 = page.locator("[data-testid=guided-timer] .guided__time").inner_text()
        self.assertNotEqual(t1, t2)
        self.assertRegex(t2, r"^\d\d:\d\d\.\d$")
        page.click("[data-testid=guided-next]")
        self.assertEqual(self.label(page), "Gieße bis 270 g")
        self.assertEqual(page.get_attribute("[data-testid=guided-number]", "data-target"), "270")
        self.assertIn("480", page.inner_text("[data-testid=guided-target]"))
        page.click("[data-testid=guided-next]")
        self.assertEqual(self.label(page), "Gieße bis 480 g")
        page.click("[data-testid=guided-next]")
        self.assertEqual(self.label(page), "Fertig – Zeit eintragen")
        self.assertEqual(page.inner_text("[data-testid=guided-next]").strip(), "Fertig")
        self.assertEqual(page.errors, [])

    def test_save_then_taste_entry(self):
        s, m, g, b, bags = gstate()
        page = self.open_guided(s)
        self.start(page, "30")
        page.wait_for_timeout(1200)
        self.advance_to_done(page)
        page.click("[data-testid=guided-next]")
        page.wait_for_selector("main [data-testid=brew-form]")
        self.assertIn("#/brews/new", page.url)
        saved = self.stored(page)
        self.assertEqual(len(saved["brews"]), 1)
        br = saved["brews"][0]
        self.assertEqual((br["method"], br["doseG"], br["waterG"], br["yieldG"]), ("filter", 30, 480, None))
        self.assertIsInstance(br["timeS"], (int, float))
        self.assertGreater(br["timeS"], 0)
        self.assertLess(saved["bags"][0]["remainingG"], 250)
        # taste chips are there; choose one and save
        for k in ("sour", "balanced"):
            self.assertTrue(page.locator(f"[data-testid=taste-{k}]").is_visible(), k)
        page.click("[data-testid=taste-sour]")
        page.click("[data-testid=save-brew]")
        page.wait_for_function("!location.hash.includes('/brews/new')")
        self.assertEqual(self.stored(page)["brews"][0]["taste"], "sour")
        self.assertEqual(len(self.stored(page)["brews"]), 1)
        page.evaluate("location.hash = '#/brews'")
        page.wait_for_selector("main [data-testid=screen-brews]")
        card = page.locator("[data-testid=brew-card]")
        card.first.wait_for()
        self.assertEqual(card.count(), 1)
        summary = card.locator("[data-testid=brew-summary]").inner_text()
        self.assertTrue(summary.startswith("30,0 g → 480 g · 1:16,0 · "), summary)
        self.assertRegex(summary, r" · \d\d:\d\d$")
        self.assertEqual(page.errors, [])


class TestFocusMode(GuidedBase):
    def test_desktop_focus_layout_and_cancel(self):
        s, *_ = gstate()
        page = self.open_guided(s, width=1280, height=800)
        self.start(page, "30")
        for tid in ("sidebar", "rail", "tabbar"):
            loc = page.locator(f"[data-testid={tid}]")
            self.assertTrue(loc.count() == 0 or not loc.first.is_visible(), tid)
        self.assertEqual(page.locator("main .btn--primary").count(), 1)
        self.assertEqual(page.locator("main [data-testid=guided-next]").count(), 1)
        box = page.locator("[data-testid=guided-number]").bounding_box()
        self.assertTrue(176 <= box["height"] <= 224, box)
        cb = page.locator("[data-testid=guided-cancel]").bounding_box()
        self.assertIn("Abbrechen", page.inner_text("[data-testid=guided-cancel]"))
        self.assertTrue(cb["x"] < 200 and cb["y"] < 150, cb)
        page.click("[data-testid=guided-cancel]")
        page.wait_for_selector("main [data-testid=screen-today]")
        self.assertTrue(page.url.endswith("#/"), page.url)

    def test_phone_number_height(self):
        s, *_ = gstate()
        page = self.open_guided(s, width=390, height=800)
        self.start(page, "30")
        box = page.locator("[data-testid=guided-number]").bounding_box()
        self.assertTrue(0.22 * 800 <= box["height"] <= 0.28 * 800, box)
        self.assertEqual(page.locator("main .btn--primary").count(), 1)


class TestBrewFormLink(GuidedBase):
    def test_filter_method_shows_guided_link(self):
        s, *_ = gstate()
        page = self.open_with(s, "#/brews/new")
        page.wait_for_selector("main [data-testid=brew-form]")
        page.click("[data-testid=method-filter]")
        link = page.locator("[data-testid=link-guided]")
        self.assertTrue(link.is_visible())
        link.click()
        page.wait_for_selector("main [data-testid=screen-guided]")
        self.assertTrue(page.url.endswith(GUIDED), page.url)

    def test_espresso_hides_link(self):
        s, *_ = gstate()
        page = self.open_with(s, "#/brews/new")
        page.wait_for_selector("main [data-testid=brew-form]")
        self.assertFalse(page.locator("[data-testid=link-guided]").is_visible())


class TestEnglish(GuidedBase):
    def test_english_labels(self):
        s, *_ = gstate(lang="en")
        page = self.open_guided(s)
        self.start(page, "30")
        self.assertEqual(self.label(page), "Bloom 60 g")
        page.click("[data-testid=guided-next]")
        self.assertEqual(self.label(page), "Pour to 270 g")
        page.click("[data-testid=guided-next]")
        self.assertEqual(self.label(page), "Pour to 480 g")
        page.click("[data-testid=guided-next]")
        self.assertEqual(self.label(page), "Done – enter time")


class TestToday(GuidedBase):
    def test_empty_text(self):
        s, *_ = gstate()
        page = self.open_with(s, "#/")
        self.assertIn("Noch kein Brew – starte mit deinem ersten Shot.", page.inner_text("[data-testid=today-empty]"))
        self.assertEqual(page.locator("[data-testid=today-brew-card]").count(), 0)
        self.assertTrue(page.locator("[data-testid=today-new-brew]").is_visible())

    def test_last_brew_card(self):
        m = machine("Silvia"); g = grinder("Eureka"); r = roaster(); b = bean(r["id"]); bg = bag(b["id"], 20)
        s = make_state(machines=[m], grinders=[g], roasters=[r], beans=[b], bags=[bg],
                       brews=[brew(m["id"], g["id"], bg["id"])])
        page = self.open_with(s, "#/")
        page.wait_for_selector("[data-testid=today-brew-card]")
        self.assertEqual(page.locator("[data-testid=today-brew-card]").count(), 1)
        self.assertEqual(page.locator("[data-testid=today-empty]").count(), 0)
