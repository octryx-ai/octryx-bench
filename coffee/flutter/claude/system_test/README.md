System test (smoke): `python3 system_test/run_system_test.py`. Needs Python Playwright (chromium) and Flutter.
Builds `build/web` if missing or older than `lib/` (`flutter build web`), serves it on 127.0.0.1 (free port),
then checks en-US and de-DE: no console errors, 5 bottom-nav entries at 390x844, 7 sidebar entries at 1280x800
(incl. Water, Care/Pflege), no horizontal scroll. Env: `WEB_DIR` overrides the served directory, `NO_BUILD=1` skips building.
