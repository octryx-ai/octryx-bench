System test (smoke): `python3 system_test/run_system_test.py`. Needs Python Playwright (chromium) and Flutter.
Builds `build/web` if missing or older than `lib/` (`flutter build web`), serves it on 127.0.0.1 (free port),
then checks en-US and de-DE: no console errors, 5 bottom-nav entries at 390x844, 7 sidebar entries at 1280x800
(incl. Water, Care/Pflege), no horizontal scroll. Env: `WEB_DIR` overrides the served directory, `NO_BUILD=1` skips building.

S2 scenarios (en-US and de-DE, one browser): equipment empty states (no grinder / no machine), UC1 add grinder
(M1, 1, 30, 0.5, 2.5 -> "M1" and "2.5 g"), water empty state (mobile via More, desktop via sidebar), UC6 water profile
(Tap, hardness 30 -> "Outside SCA" chip), then Settings hardness unit ppm -> "300 ppm". Controls are located via the
Flutter semantics tree and clicked by position; form fields fall back to Tab order. Labels live in the `T` dict.
