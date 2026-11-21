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
`/equipment/machine/new`, `/water/new`. Navigation items have keys
`nav-today`, `nav-beans`, `nav-brews`, `nav-equipment`, `nav-more` (phone,
tablet) and `nav-water`, `nav-care`, `nav-settings` (desktop sidebar).
Layout: phone < 600 dp bottom bar (5), tablet 600-1023 dp rail (5), desktop
>= 1024 dp fixed 240 dp sidebar (7).

## Data layer note

drift/SQLite could not be installed offline in this environment, so the data
layer is a pure-Dart record store behind an interface (`lib/core/data`); a
drift implementation can replace it without touching callers.

## Status per story

- COF-45 (design system and app shell): done. Tokens, themes, components,
  responsive shell, all screens reachable (later-story screens show "Coming
  soon"), style guide, DE/EN, rule-source label, check_lines, rule assets.
- Later stories: beans, brews, filter guided mode, equipment, water, care,
  settings with export/import, today dashboard, persistence.
