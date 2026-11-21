# COF-39 — equipment and reusable recipes

## 7 Non-functional requirements — S2 implementation results

The S1 acceptance record remains in [ACCEPTANCE.md](ACCEPTANCE.md). This entry extends it for S2 without claiming completion of later brewing stories or the named-browser release matrix.

Pinned execution environment: Node 26.4.0, npm 11.17.0, Playwright 1.58.2, bundled Chromium revision 1208 / Chrome for Testing 145.0.7632.6. Node, npm and Playwright versions were checked again during S2 verification.

| Declared command | Actual result |
| --- | --- |
| `node --test tests/unit/*.test.mjs` | PASS — 16 tests, including S1 and revision 1 regressions |
| `PLAYWRIGHT_BROWSERS_PATH=./.cache/ms-playwright ./node_modules/.bin/playwright test` | PASS — 26 scenarios (38.4 s), including S1 and revision 1 regressions |
| `npm run lint` | PASS — syntax checks for app, storage, schema, domain and configuration modules |

Unit/integration coverage includes finite decimal input, comma/point handling, nulls and bounds, exact decimal grids and direction, scale endpoints, filter rounding and totals, stable equal-time step sequence, zero and more than 30 steps, nonpositive final water increments, mass balance including negative retention, independent exchange measurements, purge alternatives and unknown purge, four-grinder isolation, manual machine bounds, stale revisions, archive preservation of saved brew snapshots, and all S1 storage/import/contrast checks.

Browser coverage includes creating a machine and four independently configured grinders, editing one without changing the other three, archiving and archive filters, dated mass-balance and exchange measurements, recipe creation/editing/duplication/archive, starter preview before creation, 15-to-20 g filter scaling, invalid grid/total/empty-step errors retaining input, text settings remaining local to their grinder, dirty-cancel confirmation, full-data search and 25-item pagination, persistent drafts after reload, conflict and failed-storage recovery, keyboard focus and dialog restoration, both themes and reduced motion. A 720 px layout verifies reflow equivalent to 200% zoom of a 1440 px viewport; native named-browser zoom remains incomplete.

Screenshots of every equipment and recipe route, espresso/filter detail and edit states, mass-balance/exchange forms, starter preview and the extended style guide were captured at 1280 px and 390 px in both themes. The screens were visually inspected. Empty helper/error rows were hidden to reduce form height, and the native control color scheme was connected to the theme tokens so the dark date-picker icon stays visible. Measurements start blank rather than inventing observations. Generated screenshots are pipeline artifacts under `test-results/s2/` and are not committed source files.

The retained 100-operation benchmark uses 10,000 draft brews and 1,000 bags on the pinned Chromium host. The complete green revision 1 run measured P95 local save **49.8 ms** and full-data filtering **0.3 ms**, both below 500 ms. Each system run prints and attaches its own measurements, which can vary slightly.

### Review revision 1 — verified

Stepped grinders now require finite ordered bounds and a positive step together. Both the editor and atomic storage validation enforce machine numeric limits, positive idle thresholds and nonnegative purge values; recipe settings are validated against their selected grinder before saving. Invalid values retain the draft. Regression tests reject incomplete scale definitions, out-of-range machine pressure and off-grid settings.

Ordinary filter creation starts with editable steps. Changing dose, ratio or earlier pours derives the last pour from the target using integer tenths; a nonpositive remainder blocks Save with “Letzte Wassermenge muss positiv sein”. Manual final-pour edits remain possible and Save rejects an inconsistent total with “Wassermengen ergeben nicht die Zielmenge”. This is the chosen interaction assumption. Scaling still updates dose and preserves the 60 / 126.7 / 133.3 g result at 20 g and 1:16.

Equipment detail retains type-specific drawings and all grinder scale fields and now renders source title, publisher, retrieval date, applicability, summary, verification status and an escaped HTTPS link. Imported sources remain unverified. Source detail screenshots at 1280 and 390 px, plus both-theme equipment and recipe screenshots, were inspected without visible overflow or unreachable controls. The named-browser matrix below remains incomplete.

### Named-browser acceptance — INCOMPLETE

Chrome 156.0.8078.48 (8078.48), Firefox 158.0.1 (15826.10.19), and Safari 27.0 (21625.1.29.18.28) retain the incomplete status recorded in S1. These named browsers have not been run through the release matrix. Bundled Chromium results do not substitute for them. Later timer, research-provider, stock-completion and full UC2–UC6 acceptance remain with their stories.

### Assumptions and implementation choices

- Optional machine parameter values are explicit upper bounds taken from the user's manual; unknown values remain null. Recipe validation applies these bounds without inventing machine capabilities.
- Exchange tests store their independent measured purge amount in `exchangePurgeG`; their mass-balance fields remain null. Neither measurement type automatically replaces a grinder's configured purge amounts.
- New filter steps carry a zero-based `sequence` matching their array order, preserving the explicit order of equal-time steps. Existing S1 steps without this extra field remain readable.
- Dirty editor drafts are saved locally after 500 ms; explicit Save validates and writes the entity through the existing atomic IndexedDB/revision command. Failed writes and stale revisions retain the draft. Archive changes the archived flag and revision while preserving IDs and historical snapshots.
- Measurement dates use a stable UTC timestamp on the selected calendar day; display remains in Europe/Zurich. Values are recorded only after the user enters them and saves.
