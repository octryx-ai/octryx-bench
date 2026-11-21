# COF-40 — inventory acceptance record

## 7 Non-functional requirements — S3 results

This extends [S1](ACCEPTANCE.md) and [S2](ACCEPTANCE-S2.md). Toolchain: Node 26.4.0, npm 11.17.0, Playwright 1.58.2; bundled Chromium revision 1208 / Chrome for Testing 145.0.7632.6. Node, npm, Playwright and OS versions were checked during this story.

| Declared command | Actual result |
| --- | --- |
| `node --test tests/unit/*.test.mjs` | PASS — 27 tests, including review revision 1 regressions |
| `PLAYWRIGHT_BROWSERS_PATH=./.cache/ms-playwright ./node_modules/.bin/playwright test` | PASS — 36 scenarios, 50.6 s, including review revision 1 regressions |
| `npm run lint` | PASS — all seven application modules |

Unit/integration coverage includes calendar-day readiness and precedence (01.11 + 10 days = 11.11; filter 06.11; override 15.11), leap years and Zurich midnight/DST boundaries, unknown roast and thaw confirmation, opened-first ordering, exact tenths and conservation, 250−17−2=231 and total 481 g, 10+9 g split and 0/241 g residuals, insufficient 18 g returning no partial allocation, independent bags, revision conflicts, immutable correction history, idempotent results after intervening writes and backup restore, changed-content conflicts, concurrent consumption, atomic overdraft and invalid bag/batch rollback. Forecast tests cover 28 complete local days, the seven-day minimum/manual fallback, 560/28=20 g/day, frozen exclusion, 360/440 g thresholds, 15/3-day coverage, batch overrides excluded from future delivery estimates, and a receipt clearing reorder while preserving the readiness gap. Existing S1/S2 import, revision, contrast and recipe tests remain green.

UC2 browser coverage creates two roasters, two distinct roast batches and three individual bags (two of one batch), retains independent dates, confirms actual dose/purge consumption, corrects stock with a mandatory reason, and displays the immutable journal. Other scenarios verify full-data search, roaster/readiness filters, pagination, draft reload and dirty cancel, invalid HTTPS input, failed storage with retained values/retry/export, explicit resting override, frozen selection exclusion and confirmed thaw readiness. Start is blocked without full allocation; a successful Start creates only a prepared brew draft and leaves stock unchanged. Actual use is booked through “Verbrauch bestätigen”. Brewing timers remain for the next story.

Every new route was captured and visually inspected at 1280 and 390 px in both themes: beans, coffee detail/create/edit, bag create/edit, batch edit, journal, roaster list/detail/create/edit, stock selection and style guide. No page-wide horizontal overflow was observed. Shared controls retain 44 px targets and 3 px focus outlines; storage-failure controls remain reachable at a 720 px width (200% equivalent reflow). Reduced motion is enabled in screenshot checks. Screenshot artifacts are under `test-results/s3/` and are not source files. No story stylesheet or visual values were introduced: all screens use S1's tokens and shared styles.

The retained 100-operation benchmark with 1,000 bags and 10,000 draft brews measured save P95 **51.6 ms** and filtering P95 **0.3 ms**, below 500 ms on the documented Chromium host. This benchmark covers local persistence and full-data filtering, not network operations.

### Review revision 1 — verified

- Counted-balance corrections take priority over the opening-quantity input: preserve the persisted `initialG` and append target balance minus current ledger balance. A 231-to-230 g correction adds −1 g and retains the original 250 g receipt, even when the opening input was edited. This priority is the chosen interaction assumption; receipt-quantity correction without a counted target remains available.
- Coffee-specific and all-coffee allocation use the same active-bag selection. Archived bags are excluded from automatic/manual allocation and rejected by the consumption command itself.
- Before appending any movement, brew-linked consumption requires exact integer-tenths totals matching `brew.doseG` and the confirmed purge/waste totals in its saved allocations. The saved allocations are the source of confirmed purge/waste because Brew has no separate top-level fields for them. Duplicate bags, zero-use rows, malformed entries and bags belonging to another confirmed coffee are rejected atomically. Valid multi-bag splits remain supported.
- Forecast availability uses one finite-positive predicate in both views. Null, missing and zero manual forecasts show “Noch keine belastbare Verbrauchsprognose” with no coverage/division. Total coverage uses ambient stock including resting bags; ready coverage uses only ambient stock ready for defaultMethod. Regression fixtures verify 300/20 = 15 days total versus 60/20 = 3 days ready; a resting receipt clears reorder without clearing the readiness gap. Frozen stock remains excluded.

The corrected journal, coverage and missing-prognosis screens were captured and visually inspected at both 1280 and 390 px (`test-results/s3/review-*.png`). Existing route/theme screenshots were regenerated by the complete green suite. Lint and whitespace checks passed. The named-browser matrix remains incomplete.

### Named-browser acceptance — INCOMPLETE

The named-browser release matrix from S1 remains incomplete: Chrome 156.0.8078.48, Firefox 158.0.1 (15826.10.19), Safari 27.0 (21625.1.29.18.28). These browser versions were not executed in this environment. Bundled Chromium passes do not substitute for those results, native named-browser 200% zoom, or later-story UC3–UC6 tests.

### Assumptions and schema compatibility

- The optional bag `readyOn` stores the user's confirmed post-thaw date. It overrides the roast estimate only when `thawedOn` exists. No aging conversion is invented.
- Optional coffee `manualDailyUseG` stores a positive fallback. Existing schemaVersion=1 backups without these fields remain accepted; new forms write explicit nulls when unknown. Export/import preserves the journal, UUIDs, snapshots, operation signatures and original operation outcomes.
- Inventory commands return stable operation outcomes in the specified result/error envelope. The UI refreshes the collection after a successful command. Operation metadata is stored on the immutable movements, so repeat protection travels with a backup.
- “Verbrauch erfassen” records confirmed actual use without requiring the later timer flow. Stock-selection Start prepares a draft only; it does not debit beans. Purge starts at zero and must be entered explicitly rather than guessed.
- Receipt-quantity edits append their difference as an adjustment; an optional counted balance offers a separate correction. Both require a reason when stock changes. Corrections do not rewrite the original receipt or consumption.
