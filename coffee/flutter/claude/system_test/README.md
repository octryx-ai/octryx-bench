System test (smoke): `python3 system_test/run_system_test.py`. Needs Python Playwright (chromium) and Flutter.
Builds `build/web` if missing or older than `lib/` (`flutter build web`), serves it on 127.0.0.1 (free port),
then checks en-US and de-DE: no console errors, 5 bottom-nav entries at 390x844, 7 sidebar entries at 1280x800
(incl. Water, Care/Pflege), no horizontal scroll. Env: `WEB_DIR` overrides the served directory, `NO_BUILD=1` skips building.

S2 scenarios (en-US and de-DE, one browser): equipment empty states (no grinder / no machine), UC1 add grinder
(M1, 1, 30, 0.5, 2.5 -> "M1" and "2.5 g"), water empty state (mobile via More, desktop via sidebar), UC6 water profile
(Tap, hardness 30 -> "Outside SCA" chip), then Settings hardness unit ppm -> "300 ppm". Controls are located via the
Flutter semantics tree and clicked by position; form fields fall back to Tab order. Labels live in the `T` dict.

S3 scenario (`run_s3`, 390x844, both locales, fresh context): Beans tab empty state ("No beans yet"/"Noch keine Bohnen"),
add bean "Bohne 1" (roaster, roast date = today - 12 days typed as ISO yyyy-MM-dd after select-all, weight 250, default
roast level) -> list shows the name and the "Ready"/"Bereit" chip; tapping the card opens the detail with the pack list
and the "Add pack"/"Packung hinzufügen" button. Labels live in `T3` and come from the `app_*.arb` field keys.

S4 scenario (`run_s4`, 390x844, both locales, one fresh page, because data lives in memory): add grinder M1, machine
"Maschine 1"/"Machine 1" (temperature 93, pre-infusion 0 typed), bean "Bohne 1" with 250 g pack, then Brew tab empty
state, "Log a brew"/"Brühung erfassen" form (machine, grinder, pack are pre-selected; grind 12, dose 18, yield 36, shot
time 27 typed into the field, no live timer) -> list shows "27 s"; tapping the card opens the detail with the
"Recommendation"/"Empfehlung" card (sentence not asserted). Labels live in `T4`, from the `app_*.arb` brew keys.
