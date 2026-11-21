# Changelog

All notable changes to this project are documented here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
