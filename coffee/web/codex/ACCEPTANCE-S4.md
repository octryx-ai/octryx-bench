# COF-41 — brewing acceptance record

## 7 Non-functional requirements — S4 results

This extends [S1](ACCEPTANCE.md), [S2](ACCEPTANCE-S2.md) and [S3](ACCEPTANCE-S3.md). Toolchain: Node 26.4.0, npm 11.17.0, Playwright 1.58.2. Browser: locally installed bundled Chromium revision 1208 / Chrome for Testing 145.0.7632.6. Node, npm, OS and Playwright versions were checked again during S4.

| Declared command | Actual result |
| --- | --- |
| `node --test tests/unit/*.test.mjs` | PASS — 41 tests, including review revision 1 regressions |
| `PLAYWRIGHT_BROWSERS_PATH=./.cache/ms-playwright ./node_modules/.bin/playwright test` | PASS — 52 scenarios, 1.3 min, including review revision 1 regressions |
| `npm run lint` | PASS — all ten application modules |

UC3 and UC4 browser tests cover espresso setup, full stock allocation, pause/resume/stop, actual yield and taste, completion, immutable equipment snapshots, repeat, filter first-pour start, 45/95/100 g instructions and 45/140/240 g cumulative targets, pending overdue acknowledgement, actual water, manual entry, correction reason and reversal/replacement history. A five-minute simulated background interval produces 05:00; offline continuation and resume produce 05:10. Reload persists the session and offers “Unterbrochener Bezug” / “Fortsetzen” / “Abbrechen”. Cross-tab tests verify a transactional single-active-brew lock with an action link, retained local review on revision conflict, and idle history refresh through broadcasts. History tests use 30 records, 25-item pages, full-data search, Zurich calendar dates, method filters, archive-off defaults and preserved return pagination.

Unit/integration tests verify the exact 10:00:00 / pause 10–15 / stop 35 = 30 s timer example; independent grinder idle/switch purge max=3 g and unknown suggestions; no early filter acknowledgement or skipped steps; concurrent lock acquisition; atomic validation and stock failure; prior confirmed use followed by completion without double debit (250−17−2=231 g); original idempotent outcomes; changed-payload conflicts; reversal/replacement revisions; unconfirmed abort zero debit versus confirmed 17 g waste; unchanged other grinders; snapshot preservation after renamed/archived equipment and changed recipes. Interrupted timers, open pauses, snapshots, operation signatures/results, completed tastes and stock balances survive schemaVersion=1 JSON backup/replace roundtrips. Generic entity writes cannot bypass completion/revision commands.

All new screen types were captured and visually inspected at 1280 and 390 px: Today, setup, espresso focus, filter focus, interrupted session, abort dialog, review, detail, edit, empty and populated history. Both light and dark screenshot runs use reduced motion. The shared style guide includes timer, pending/overdue steps, unknown purge, disabled Start, interruption, lock conflict, consumption confirmation and correction states. No story stylesheet or visual color/size literals were added. The existing token contrast tests remain green. Keyboard focus checks verify the 3 px shared outline; shared labels and controls retain 44 px targets. Screenshot artifacts are in `test-results/s4/` and are not source files. The passing S4 storage-failure test additionally checks retained actuals, retry/export and 720 px reflow (200% equivalent width).

The 100-operation CI fixture now contains S4 timer, operation, null correction and coffee snapshot fields on 10,000 draft brews, with 1,000 bags. The final full run measured save P95 **75.3 ms** and filter P95 **0.4 ms**, below 500 ms.

### Review revision 1

- Unstarted filter timers reject Stop without changing data. Manual filter completion preserves null startedAt, stoppedAt and unknown duration; a deliberately entered manual duration remains supported without creating timer timestamps. Only first pour starts the filter clock.
- Consumption and completion require an existing selected coffee ID even for legacy/imported snapshots. Missing identity and bags belonging to another coffee reject atomically, preserving stock, grinder, taste and brew state.
- Start rejects a draft with previously confirmed consumption using CONFLICT. This is the chosen simplest interaction: complete that draft manually instead of reallocating already spent beans. Completing after the rejected Start keeps 250−17−2=231 g and exactly the original two movements.
- The first pending filter step now shows “Nächster Schritt überfällig” after its target, remains pending until acknowledged and clears the warning when the next target is still ahead.
- Any active history filter, including archive-only selection, renders the shared drawn “Keine Treffer” empty state with “Filter zurücksetzen”. Reset restores the genuinely empty collection's “Noch keine Bezüge” state.

New unit/integration and browser regression tests cover all five findings. Corrected overdue and filtered-empty screens were captured and visually inspected at 1280 and 390 px (light/dark respectively), under `test-results/s4/review1-*.png`. The complete suite also regenerates the existing S4 screen/theme captures.

### Named-browser acceptance — INCOMPLETE

Chrome 156.0.8078.48, Firefox 158.0.1 (15826.10.19), and Safari 27.0 (21625.1.29.18.28) were not run in this environment. Their named-browser and native 200% zoom results remain **INCOMPLETE**. Bundled Chromium and equivalent-width reflow do not substitute for those results. Later-story UC5–UC6 remain outside S4.

### Assumptions and compatibility

- An interrupted, unpaused timer continues from its saved timestamps; only an explicit pause removes elapsed time. Filter acquires the active-session lock at Start and begins timing on “Erster Aufguss”.
- With no known previous grinder use, no idle condition is inferred. Any applicable unknown purge remains unknown until the user enters actual grams. Proposals never debit stock.
- Manual entry permits an unknown duration, represented by explicit null. History falls back to creation time when a manually entered brew has no startedAt.
- A repeat preserves its prior equipment, water, setting and recipe snapshots. Availability and stock are checked again before starting; a missing or frozen allocation must be resolved explicitly.
- Local form drafts save after 500 ms idle; transactional brew state, pauses, operation outcomes and immutable consumption remain in IndexedDB. Optional S4 extension fields preserve compatibility with older schemaVersion=1 backups.
