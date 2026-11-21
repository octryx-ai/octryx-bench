# Kaffee-Begleiter

Flutter app (Android, iOS; Chrome for testing) that guides coffee lovers through
brewing, beans, water and care. One user, no login, fully offline. The
specification is in `SPEC.md`.

## Run and test

Use a Flutter 3.50 SDK, then from this folder:

```sh
flutter pub get
flutter run -d chrome        # or an Android emulator
flutter analyze
flutter test
dart format --set-exit-if-changed .
dart run tool/check_lines.dart
```

Web build for the system tests (bundles CanvasKit, no CDN access needed):
`flutter build web --no-web-resources-cdn`. Web uses hash URLs, so every
route below works as `http://host/#/beans`.

## Folder layout

```
lib/app/            shell (bottom bar, rail, sidebar), router, routes, root widget
lib/core/theme/     tokens.dart (all colours, sizes, radii, type, breakpoints), themes
lib/core/widgets/   AppButton, AppCard, AppField, AppChip, AppBanner, EmptyState,
                    ComingSoon, RuleSourceLabel, ...
lib/core/format/    AppFormat: dates and decimals per language
lib/core/data/      record store behind an interface (backend)
lib/core/rules/     data-driven rules with source and retrieval date (backend)
lib/features/<feature>/presentation/   screens (data/domain follow per story)
lib/l10n/           app_en.arb, app_de.arb and generated app_localizations*.dart
assets/             water, rest, care, brew rule JSON
test/               mirrors lib/
tool/               check_lines.dart
```

## Localization

German (`de`) and English (`en`), chosen from the system language; every other
language falls back to English (`localeResolutionCallback`). All German
variants (de_CH, de_DE, ...) use `dd.MM.yyyy` (16.11.2026); English uses
`d MMM yyyy` (16 Nov 2026). The decimal separator is always a point. Edit the
`.arb` files in `lib/l10n`; `flutter pub get` regenerates the Dart files
(`flutter gen-l10n`). Generated files are exempt from the line check and the
analyzer.

## Design tokens

`lib/core/theme/tokens.dart` is the only place for colour, size, spacing,
radius, type-size, breakpoint and duration values; widgets reference it.
`test/core/theme/no_literals_test.dart` scans `lib/` for violations and
`test/core/theme/contrast_test.dart` checks text contrast (>= 4.5:1) for
success, warning, error and onSurface on `surface` and `surfaceVariant` in
light and dark. Themes follow the system brightness; dark cards have a 1 dp
border instead of a shadow.

## Style guide

Route `/styleguide` (linked from Settings and More) shows every component in
every state (hover, pressed and focus are rendered statically). Tiles carry
keys such as `sg-button-hover`.

## Routes

`/` Today, `/beans`, `/brews`, `/equipment`, `/more`, `/water`, `/care`,
`/settings`, `/styleguide`, plus `/beans/detail`, `/beans/new`, `/brews/new`,
`/brews/detail`, `/filter`, `/equipment/grinder/new`,
`/equipment/machine/new`, `/water/new`; S2 adds `/equipment/grinder/edit`,
`/equipment/machine/edit`, `/water/detail` and `/water/edit` (record id as
route argument). Navigation items have keys
`nav-today`, `nav-beans`, `nav-brews`, `nav-equipment`, `nav-more` (phone,
tablet) and `nav-water`, `nav-care`, `nav-settings` (desktop sidebar).
Layout: phone < 600 dp bottom bar (5), tablet 600-1023 dp rail (5), desktop
>= 1024 dp fixed 240 dp sidebar (7).

## Equipment, water and settings (COF-46)

- Ausrüstung: tabs Mühlen and Maschinen. Grinder cards (88 dp) show the 270
  degree dial arc with scale min/max labels, dead space ("2.5 g") and the scale
  ("1–30 · 0.5"). There is no grind setting yet, so the arc shows the track only.
  Machine cards show the 56 dp ring with the portafilter icon, "93 °C · 8 s"
  and the days to backflush; without a care event the ring is full ("7 days";
  green above 2 days, amber 1-2, red 0 or less). Cards open the edit form;
  the trash button soft-deletes.
- Grinder form: name, scale min/max/step, finer direction, dead space and a
  test field "Check grind setting" that shows the error text of
  `grindSettingErrorText` (SPEC section 5) via `GrinderScale.validate`.
- Machine form: name, brew temperature, pre-infusion, pressure profile and a
  default water profile dropdown (live profiles only).
- Wasser: profile cards (hardness in the selected unit, SCA status chip), detail
  with the "Check water first" hint (R2), "n of 6 measured" and one bar per
  parameter with the marked SCA range (error colour outside, success inside,
  "not measured" for empty values). The form takes hardness in °fH, °dH or ppm
  (R1, stored as ppm, range 0-1000 ppm) and optional alkalinity, TDS, pH,
  sodium, chlorine; both `.` and `,` are accepted as decimal input.
- Einstellungen: hardness unit selector (bound to `AppData.setHardnessUnit`);
  export and import show a "Coming soon" notice.
- State is in memory (`AppData`, provided by `AppScope`); data is lost on
  restart until persistence arrives. Deleted records leave the lists but stay
  resolvable by id.
- Numbers use a decimal point in both languages (`AppFormat.plain` / `parse`);
  units g, s, °C, °fH are the same in German.
- Tests: `test/features/equipment`, `test/features/water`,
  `test/features/settings` (forms, validation, empty states in DE and EN,
  deletion, unit switch), plus format and domain tests.

## Beans, packs and rest time (COF-47)

- **Beans** (`/beans`): cards sorted by the earliest ready date of their packs.
  Each card has a gradient image area (hue `15 + fnv1a32(lowercase(name)) mod 36`),
  a bean icon, roast dots (light 1 ... dark 4), a readiness chip
  (Ready / Resting, N days left / Too old) and the remaining grams.
- **Rest time (R3)**: `readyDate = roastDate + rest days` from
  `assets/rest_rules.json` (espresso blend and all-round use the espresso rest
  time, filter the filter rest time); a pack is too old from `roastDate + 45` days.
- **Forms**: bean (name 1-60, roast level, kind, lead time, optional minimum
  stock) with the first pack (roast date as `dd.MM.yyyy` / `d MMM yyyy` or ISO,
  weight 50-5000 g); pack form; errors shown per field.
- **Detail** (`/beans/detail`): key figures, pack list, "Add pack", "Open"
  (sets `openedAt`), edit and soft delete.
- Data stays in memory (see the data layer note).

## Data layer note

drift/SQLite could not be installed offline in this environment, so the data
layer is a pure-Dart record store behind an interface (`lib/core/data`); a
drift implementation can replace it without touching callers.

## Status per story

- COF-45 (design system and app shell): done. Tokens, themes, components,
  responsive shell, all screens reachable (later-story screens show "Coming
  soon"), style guide, DE/EN, rule-source label, check_lines, rule assets.
- COF-46 (equipment, water, settings): done. Grinder and machine lists and
  forms, water list, detail and form with the SCA check, hardness unit
  setting, in-memory store, R1 and R2, DE/EN.
- Later stories: beans, brews, filter guided mode, care, export/import, today
  dashboard, persistence.
