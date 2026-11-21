S6 extends this record in [ACCEPTANCE-S6.md](ACCEPTANCE-S6.md), section 7.

# COF-38 acceptance record

S5 extends this record in [ACCEPTANCE-S5.md](ACCEPTANCE-S5.md), section 7.

S4 extends this record in [ACCEPTANCE-S4.md](ACCEPTANCE-S4.md), section 7.

S2 extends this record in [ACCEPTANCE-S2.md](ACCEPTANCE-S2.md), section 7.

## 7 Non-functional requirements — actual implementation results

Toolchain: Node 26.4.0, npm 11.17.0. Dependencies are locked in package-lock.json. Playwright 1.58.2, bundled Chromium revision 1208, Chrome for Testing 145.0.7632.6. Chromium runs headlessly using the full Chromium executable, rather than the separately downloaded headless shell.

| Declared command | Actual result |
| --- | --- |
| `node --test tests/unit/*.test.mjs` | PASS: 9 tests |
| `PLAYWRIGHT_BROWSERS_PATH=./.cache/ms-playwright ./node_modules/.bin/playwright test` | PASS: 15 scenarios |
| `npm run lint` | PASS: JavaScript syntax checks |

The unit suite checks atomic revision serialization, unchanged caller drafts on conflict, replace rollback, required arrays and explicit nulls, UUID and reference validation, negative stock, unsupported versions, invalid names/URLs, imported source review reset, exact backup balances and snapshots, the 20,971,520 / 20,971,521 byte boundary before text decoding, and both themes' text, boundary and focus contrast. Contrast assertions use WCAG relative luminance (4.5:1 text, 3:1 boundaries/focus).

Chromium scenarios cover every navigation-map route in empty/missing-ID form, populated collection/detail/action routes, desktop and phone navigation, current destination, keyboard skip link and focus outline, dialog preview/cancel/replace, JSON download, reload durability, 500 ms idle autosave, explicit save, cross-tab conflicts, disabled storage retaining entered values and retry/export, oversized import before confirmation, light/dark/system rendering, reduced motion, 1440 px and 390 px width, and 720 px reflow corresponding to 200% zoom of a 1440 px layout. Native named-browser 200% zoom is still incomplete.

Screenshots: all 28 empty/missing routes plus 11 populated routes were captured at both 1280 px and 390 px and visually inspected. Generated screenshots are in `test-results/screens/` (pipeline artifacts, intentionally not source-controlled). Inspection found and fixed phone overflow caused by stylesheet ordering and intrinsic file-input sizing, duplicate active navigation on `/brews`, and equipment detail illustrations. Fixed phone navigation has reserved bottom space; long labels wrap.

Performance: 100 operations on the pinned Chromium/host above, collection of 10,000 draft brews with snapshots and 1,000 bags. Measured P95 local settings save including collection validation and atomic IndexedDB write: **49.6 ms**; full-data substring filtering: **0.4 ms**. Both are below 500 ms. The benchmark runs in the declared system suite and attaches its measurements; later stories must extend it to their richer snapshots and ledger workloads.

### Named-browser release matrix — INCOMPLETE

These are the actual locally installed versions, recorded from application Info.plist. They have **not** been run through the required release matrix. Bundled Chromium success does not substitute for these results. No claim is made that the installed versions are the latest stable downloads on the report date.

| Browser | Installed full version / build | Required named-browser result |
| --- | --- | --- |
| Google Chrome | 156.0.8078.48 / 8078.48 | INCOMPLETE — not executed |
| Firefox | 158.0.1 / 15826.10.19 | INCOMPLETE — not executed |
| macOS Safari | 27.0 / 21625.1.29.18.28 | INCOMPLETE — not executed |

UC1–UC6, brew/stock idempotency, running-session lock/recovery and the five-minute background timer check require the subsequent brewing/inventory stories. S1 exposes their routes with short German coming-soon notices. Research behavior is represented in the shared component catalogue; no research provider is configured in S1. Full release acceptance remains incomplete until these later-story scenarios and all three named-browser matrices are recorded.

### Implementation choices

- A framework-free German single-page shell and one IndexedDB collection object provide a small atomic persistence boundary. Every mutation reads and writes inside one read/write transaction; expected entity revisions prevent silent overwrite. BroadcastChannel refreshes idle tabs.
- Settings use a singleton UUID. Optional values are explicit nulls. Snapshot fields use explicit names such as `recipeSnapshot`, `machineSnapshot`, and `usageSnapshot`; unknown future fields survive backups unchanged.
- Imported source status becomes `stale` and reviewedAt becomes null, the existing domain vocabulary for guidance that must be reviewed again. Source text and imported names render as text, with no HTML interpretation.
- Search and page state are encoded in URLs; source-list URLs are remembered for overview links. Future story forms remain navigable placeholders rather than incomplete domain editors.

### Automatic revision 1 — independent review regression results

All seven supplied findings are covered by the declared suites. Creation routes are dispatched explicitly before entity-ID lookup. The collection theme control uses the same draft/save path as the settings form, preserves the existing singleton and every default selection, and synchronizes form controls after saving. Pending saves are serialized: newer local input remains in the draft and is written with the revision returned by the previous transaction; idle-tab refresh never replaces an active save.

Import validation checks settings UUID, timestamps, positive revision and archived boolean before building the global ID set, and rejects settings/entity ID collisions. Opening stock and receipts must be nonnegative; brew, purge and waste movements must be nonpositive. Assumption: explicitly reasoned adjustments and reversals remain signed, as required for stock corrections and undoing consumption. Rejections leave the prior collection unchanged. The import dialog renders its explicit empty-state sentence whenever there are zero bags, even if other entity counts are positive; counts and the replace/cancel actions remain available.

Actual regression result on the same pinned Node/Chromium host: **9 unit tests and 15 system scenarios passed**, syntax checks passed. The delayed-save browser regression holds a request pending, edits method and theme, releases it, and verifies the newest values survive reload at revision 3. Both viewport screenshots of the zero-bag preview and all creation routes are generated with the system suite and visually checked. The named-browser matrix above remains explicitly incomplete; these regressions do not substitute for it.

S3 extends stock, readiness, forecast and UC2 acceptance in [ACCEPTANCE-S3.md](ACCEPTANCE-S3.md), section 7.
