# Changelog

All notable changes to this project are documented here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

OE-77 S3: first grinder in the onboarding.

- Page 3 uses the grinder form's fields and checks (name, scale minimum and
  maximum, scale step, dead space); each error is a line under its field.
- Weiter saves the grinder and goes to page 4; Später creates nothing and goes
  to page 4. Back to a saved page 3 shows "Angelegt: M1" / "Created: M1" and
  creates nothing new (at most one grinder per run).
- A grinder saved before Skip stays in the session; no default machine or water
  profile is created.
- Tests: `onboarding_grinder_page_test.dart` (validation, saving, Später, Created
  text, Ausrüstung listing, no defaults); the Playwright walk saves M1 on page 3
  and checks it under Ausrüstung.

OE-76 S2: onboarding info pages, progress and navigation.

- Page 1 Willkommen (160 dp header, enabled Weiter, no Zurück) and page 2 with
  exactly the three functions (DE and EN), each page with its progress text
  "k von 4" / "k of 4" and filled dots (2 of 4 = half, 4 of 4 = all).
- Zurück from page 2 on; Weiter from page 2 to page 3; Überspringen on page 2
  sets the flag and shows Heute.
- Tests: per-page widget tests (texts, progress, buttons) in
  `onboarding_info_pages_test.dart`; the Playwright walk checks the progress
  labels "Step 2 of 4" and "Step 4 of 4" and the page changes.

OE-75 S1: onboarding flag and routing.

- `onboardingDone` (shared_preferences): missing or `false` starts the
  onboarding at `/onboarding` (page 1 "Willkommen"), `true` or a read error
  starts Heute (`OnboardingGate`, `SharedPreferencesFlagStore`).
- "Überspringen" on page 1 writes the flag without confirmation and shows
  Heute; a failed write keeps the page and shows the retry banner.
- Full-screen onboarding without bottom bar, rail or sidebar, centred column
  of at most 480 dp; system back does not exit the app.
- Tests: unit tests of the flag logic (new, done, skipped, read and write
  errors), widget tests for routing and the page, Playwright checks for skip
  and reload.

COF-50 S6: stock, care, Heute, export/import.

- Stock (R4/R5) and gap warning (R6): `StockCalculator`, `GapCalculator`,
  stock bar, order and gap banners on the bean detail.
- Care (R8): `CareCalculator`, `CareEvent`, Pflege screen, machine ring from
  the real backflush task.
- Heute: warnings, ready-now cards, last brew, FAB.
- Export/import (schemaVersion 1) with merge by `updatedAt`, skipped
  references, all-or-nothing import; browser download/file chooser, paste
  dialog and clipboard fallback; "Delete all data"; sources list.
- Fix: `AppBanner` puts its action below the text so it cannot overflow.
- System tests: care (UC7) and export/import (UC9).

COF-49 S5 backend: filter coffee.

- R10: `FilterRecipeCalculator` and `FilterRecipe` (bloom, three pours, ratio
  clamped to 14-18 and snapped to 0.5, rules from `brew_rules.json`).
- R11: `FilterAdvisor` (water, rest, drawdown time, taste) sharing the clamped
  dial move `GrindMover` with `EspressoAdvisor`.
- R3: `FilterPackSuggester` (filter rest time, blends only as fallback).
- `AppData`: `filterRecipes`, `filterAdvisor`, `filterPackSuggestions()`,
  `recommendFor` dispatches by method; `addBrew` takes `waterTotalG`, `bloomG`,
  `pours`, `drawdownS`; `BrewValidation.validateDrawdown`, `BrewMethod.isFilter`,
  `RestCalculator.readiness(method:)`; new mixin `AppDataFilter`.

COF-49 S5 frontend: guided filter.

- `/filter`: setup (method, grinder, grind, pack, water, dose, ratio slider),
  focus mode (72 sp timer, 48 sp pour target, one primary button, no
  navigation), finish (drawdown, taste, rating) saving a filter brew.
- `StepFeedback`: haptic and alert sound on Android/iOS, 300 ms flash on web.
- Brew list, detail tiles and recommendation wording handle filter brews
  (drawdown time, water, bloom, pours); "Next try" reopens `/filter` prefilled.
- `FormPage` takes `saveLabel` and a nullable `onSave`; `focus_tokens.dart`;
  `SubPage` placeholder removed.

COF-48 S4: espresso brews, shot timer and dial-in advice.

- UI: brew list (lazy, newest first, 88 dp cards), brew form with grind
  stepper, shot timer, purge hint (R7), stock and range errors, brew detail with
  the recommendation card (R9) and "Next try"; DE and EN texts.
- `AppDropdown` follows a changed value; `AppChoiceChips` accepts no selection.
- Tests: brew list, form, detail, timer and a 1000-brew frame-time test.

Backend:

### Added
- Domain model: `Brew`, `BrewPour`, `BrewMethod`, `Taste`, `BrewValidation`,
  `BrewException`, `PurgeAdvice`, `Recommendation`.
- R9: `EspressoAdvisor` (water, rest, then grind by shot time and taste, with
  scale clamping and rule sources from `assets/brew_rules.json`).
- `BrewsRepository` and `AppData` brew API (`addBrew` with stock deduction of
  dose plus purge, `deleteBrew`, `purgeAdvice`, `shotsOfMachine`,
  `recommendFor`); `AppData` accepts `brewRules`, `careRules`, `brewStore`.

COF-47 S3: beans, packs and rest time.

- UI: bean list with gradient cards, roast dots and readiness chips; bean and
  pack forms with validation; bean detail with pack list, "Add pack" and "Open".
- Fix: `FocusRing` passes its constraints through, so full-width buttons really
  fill their width.

Backend:

### Added
- Domain model: `Bean`, `Pack`, `RoastLevel`, `BeanKind`, `RestMethod`.
- R3: `RestCalculator` (resting and stale dates from
  `assets/rest_rules.json`, calendar-day math), `PackReadiness`,
  `BeanSummaries` (list sorted by earliest ready date).
- `BeanGradient` (FNV-1a based hue for the Bohnenkarte), `BeanValidation`.
- `AppData`: beans, packs, `openPack`, `beanSummaries` (via `BeansRepository`).

COF-46 S2: equipment and water.

### Added
- Domain model: `Grinder`, `Machine`, `WaterProfile` (JSON, `copyWith`).
- R1: `GrinderScale.validate` (range and step, floating-point safe).
- R2: `WaterChecker` assessing six parameters against the SCA ranges from
  `assets/water_rules.json`; `HardnessUnit` (fH, dH, ppm; hardness stored as
  ppm, display rounded half-up to one decimal).
- `AppData` (in-memory state with soft delete) and `AppScope`.

## [0.1.0] - 2026-11-16

COF-45 S1: design system and app foundation.

### Added
- Design tokens (colors, typography, spacing, radii, shadows; light and dark).
- Reusable components and a style guide screen.
- App shell and navigation: bottom bar (phone), rail (tablet), 240 dp sidebar
  (desktop).
- Localization (German de-CH format and English, fallback English).
- Data base: `BaseRecord` (UUIDv4, UTC `createdAt`/`updatedAt`/`deletedAt`),
  `RecordStore` interface with in-memory implementation, `Clock` abstraction,
  soft delete (`updatedAt == deletedAt`). Pure Dart; SQLite/drift backing is a
  follow-up (packages not installable offline).
- Rule-asset loader (`RuleEntry`, `RuleSet`, `RuleAssetLoader`) and assets
  `water_rules.json`, `rest_rules.json`, `care_rules.json`, `brew_rules.json`
  with source and retrieval date per entry (`none` for unsourced defaults).
- `tool/check_lines.dart`: enforces 300 lines (lib) and 500 lines (test).
