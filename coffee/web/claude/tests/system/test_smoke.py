import json
import re
import socket
import subprocess
import sys
import time
import unittest
from pathlib import Path

from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[2]

ROUTES = [
    ("#/", "today"), ("#/brews", "brews"), ("#/brews/new", "brew-new"),
    ("#/brews/abc", "brew-detail"), ("#/guided", "guided"), ("#/beans", "beans"),
    ("#/equipment", "equipment"), ("#/water", "water"), ("#/care", "care"),
    ("#/settings", "settings"), ("#/styleguide", "styleguide"),
]
NAV = ["heute", "brews", "beans", "equipment", "water", "care", "settings"]
LABELS_DE = ["Heute", "Brews", "Bohnen", "Geräte", "Wasser", "Pflege", "Einstellungen"]
LABELS_EN = ["Today", "Brews", "Beans", "Devices", "Water", "Care", "Settings"]


def free_port():
    s = socket.socket()
    s.bind(("127.0.0.1", 0))
    p = s.getsockname()[1]
    s.close()
    return p


_PW = None
_BROWSER = None


def setUpModule():
    global _PW, _BROWSER
    _PW = sync_playwright().start()
    try:
        _BROWSER = _PW.chromium.launch(headless=True)
    except Exception:
        # pinned browser build missing: fall back to any preinstalled chromium
        import glob
        import os
        cache = os.environ.get("PLAYWRIGHT_BROWSERS_PATH") or os.path.expanduser(
            "~/Library/Caches/ms-playwright")
        found = sorted(glob.glob(cache + "/chromium_headless_shell-*/*/chrome-headless-shell")
                       + glob.glob(cache + "/chromium-*/*/Chromium.app/Contents/MacOS/Chromium")
                       + glob.glob(cache + "/chromium-*/chrome-linux/chrome"))
        if not found:
            raise
        _BROWSER = _PW.chromium.launch(headless=True, executable_path=found[-1])


def tearDownModule():
    _BROWSER.close()
    _PW.stop()


class Base(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.port = free_port()
        cls.server = subprocess.Popen(
            [sys.executable, "-m", "http.server", str(cls.port), "--bind", "127.0.0.1"],
            cwd=ROOT, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        for _ in range(50):
            try:
                socket.create_connection(("127.0.0.1", cls.port), 0.2).close()
                break
            except OSError:
                time.sleep(0.1)
        cls.url = f"http://127.0.0.1:{cls.port}/index.html"
        cls.browser = _BROWSER

    @classmethod
    def tearDownClass(cls):
        cls.server.terminate()
        cls.server.wait()

    def open(self, route="#/", width=1280, height=900, locale="de-DE", **kw):
        ctx = self.browser.new_context(viewport={"width": width, "height": height},
                                       locale=locale, **kw)
        self.addCleanup(ctx.close)
        page = ctx.new_page()
        page.errors = []
        page.on("console", lambda m: page.errors.append(m.text) if m.type == "error" else None)
        page.on("pageerror", lambda e: page.errors.append(str(e)))
        page.goto(self.url + route)
        page.wait_for_selector("main [data-testid^=screen-]")
        return page


class TestRoutes(Base):
    def test_routes_render(self):
        for lang, text in (("de", "Bald verfügbar"), ("en", "Coming soon")):
            ctx = self.browser.new_context(viewport={"width": 1280, "height": 900})
            page = ctx.new_page()
            errors = []
            page.on("console", lambda m: errors.append(m.text) if m.type == "error" else None)
            page.on("pageerror", lambda e: errors.append(str(e)))
            page.goto(self.url)
            page.wait_for_selector("main [data-testid^=screen-]")
            if lang == "en":
                page.goto(self.url + "#/settings")
                page.wait_for_selector("[data-testid=settings-language]")
                page.select_option("[data-testid=settings-language]", "en")
                page.click("[data-testid=settings-save]")
            for route, name in ROUTES:
                with self.subTest(lang=lang, route=route):
                    page.evaluate("r => location.hash = r", route)
                    page.wait_for_selector(f"main [data-testid=screen-{name}]", timeout=3000)
                    cs = page.locator("[data-testid=coming-soon]")
                    if cs.count():
                        self.assertIn(text, cs.first.inner_text())
            self.assertEqual(errors, [])
            ctx.close()

    def test_unbuilt_default_german(self):
        page = self.open("#/water")
        cs = page.locator("[data-testid=coming-soon]")
        if cs.count():
            self.assertIn("Bald verfügbar", cs.first.inner_text())


class TestNav(Base):
    def labels(self, page):
        return [page.locator(f"[data-testid=nav-{n}]").first.inner_text().strip() for n in NAV]

    def test_desktop_sidebar(self):
        page = self.open(width=1280)
        box = page.locator("[data-testid=sidebar]").bounding_box()
        self.assertEqual(round(box["width"]), 240)
        self.assertEqual(self.labels(page), LABELS_DE)

    def test_tablet_rail(self):
        page = self.open(width=800, height=900)
        box = page.locator("[data-testid=rail]").bounding_box()
        self.assertEqual(round(box["width"]), 72)

    def test_phone_tabbar(self):
        page = self.open(width=375, height=700)
        tabbar = page.locator("[data-testid=tabbar]")
        self.assertTrue(tabbar.is_visible())
        self.assertEqual(tabbar.locator("ul.nav__list a, ul.nav__list button").count(), 5)
        self.assertLessEqual(page.evaluate("document.documentElement.scrollWidth"),
                             page.evaluate("innerWidth"))
        for el in page.locator("a, button, [role=tab]").all():
            if not el.is_visible():
                continue
            b = el.bounding_box()
            with self.subTest(el=el.evaluate("e => e.outerHTML.slice(0,80)")):
                self.assertGreaterEqual(round(b["height"]), 44)
                self.assertGreaterEqual(round(b["width"]), 44)

    def test_lf1_sidebar_fills_viewport(self):
        page = self.open("#/", width=1280, height=900)
        h = page.locator("[data-testid=sidebar]").bounding_box()["height"]
        self.assertGreaterEqual(h, 900 - 1)

    def test_lf10_focus_ring(self):
        page = self.open()
        page.keyboard.press("Tab")
        s = page.evaluate("""() => { const c = getComputedStyle(document.activeElement);
            return [c.outlineWidth, c.outlineColor, c.outlineStyle]; }""")
        self.assertEqual(s[0], "2px")
        self.assertEqual(s[1], "rgb(26, 95, 180)")
        self.assertEqual(s[2], "solid")


class TestStorage(Base):
    def test_defaults(self):
        page = self.open()
        data = json.loads(page.evaluate("localStorage.getItem('coffee.v1')"))
        self.assertEqual(data["version"], 1)
        for k in ["machines", "grinders", "roasters", "beans", "bags", "waters", "brews"]:
            self.assertEqual(data[k], [])
        s = data["settings"]
        self.assertEqual(s["language"], "de")
        self.assertEqual(s["theme"], "system")
        self.assertEqual(s["espressoTimeMinS"], 25)
        self.assertEqual(s["espressoTimeMaxS"], 30)
        self.assertEqual(s["backflushSeconds"], 1500)


class TestSettings(Base):
    def test_language_theme_apply_only_on_save(self):
        page = self.open("#/settings")
        page.select_option("[data-testid=settings-language]", "en")
        page.select_option("[data-testid=settings-theme]", "dark")
        self.assertEqual(page.locator("[data-testid=nav-brews]").first.inner_text().strip(), "Brews")
        self.assertEqual(page.locator("[data-testid=nav-heute]").first.inner_text().strip(), "Heute")
        self.assertNotEqual(page.evaluate("document.documentElement.dataset.theme"), "dark")
        stored = page.evaluate("JSON.parse(localStorage.getItem('coffee.v1')).settings")
        self.assertEqual(stored["language"], "de")
        page.click("[data-testid=settings-save]")
        page.wait_for_function("document.documentElement.dataset.theme === 'dark'")
        self.assertEqual(page.locator("[data-testid=nav-heute]").first.inner_text().strip(), "Today")

    def test_language_switch(self):
        page = self.open("#/settings")
        self.assertIn("18,0 g", page.inner_text("body"))
        page.select_option("[data-testid=settings-language]", "en")
        page.click("[data-testid=settings-save]")
        page.wait_for_function("document.body.innerText.includes('18.0 g')")
        labels = [page.locator(f"[data-testid=nav-{n}]").first.inner_text().strip() for n in NAV]
        self.assertEqual(labels, LABELS_EN)
        self.assertNotIn("18,0 g", page.inner_text("body"))

    def test_theme(self):
        page = self.open("#/settings")
        page.select_option("[data-testid=settings-theme]", "dark")
        page.click("[data-testid=settings-save]")
        page.wait_for_function("document.documentElement.dataset.theme === 'dark'")
        bg = page.evaluate("getComputedStyle(document.body).backgroundColor")
        self.assertEqual(bg, "rgb(30, 23, 19)")
        page.goto(self.url + "#/styleguide")
        page.wait_for_selector("main [data-testid=screen-styleguide]")
        card = page.locator(".card").first
        if card.count():
            st = card.evaluate("e => { const c = getComputedStyle(e); return [c.boxShadow, c.borderTopWidth]; }")
            self.assertEqual(st[0], "none")
            self.assertEqual(st[1], "1px")
        page.goto(self.url + "#/settings")
        page.wait_for_selector("[data-testid=settings-theme]")
        page.select_option("[data-testid=settings-theme]", "light")
        page.click("[data-testid=settings-save]")
        page.wait_for_function("document.documentElement.dataset.theme === 'light'")
        bg = page.evaluate("getComputedStyle(document.body).backgroundColor")
        self.assertEqual(bg, "rgb(251, 245, 236)")


class TestStyleguide(Base):
    def test_sections(self):
        page = self.open("#/styleguide")
        for n in ["buttons", "inputs", "cards", "chips", "recommendation", "timer", "toast"]:
            with self.subTest(section=n):
                self.assertGreater(page.locator(f"[data-testid=sg-{n}]").count(), 0)


if __name__ == "__main__":
    unittest.main()
