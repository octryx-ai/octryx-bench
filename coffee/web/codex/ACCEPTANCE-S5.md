# COF-42 — maintenance acceptance record

## 7 Non-functional requirements — S5 results

Extends [S1](ACCEPTANCE.md), [S2](ACCEPTANCE-S2.md), [S3](ACCEPTANCE-S3.md) and [S4](ACCEPTANCE-S4.md). Toolchain: Node 26.4.0, npm 11.17.0, Playwright 1.58.2. Node/npm, Playwright and OS versions were checked again. Browser is the app-local bundled Chromium revision 1208 / Chrome for Testing 145.0.7632.6.

| Declared command | Actual result |
| --- | --- |
| `node --test tests/unit/*.test.mjs` | PASS — 50 tests |
| `PLAYWRIGHT_BROWSERS_PATH=./.cache/ms-playwright ./node_modules/.bin/playwright test` | PASS — 61 scenarios, 1.5 min |
| `npm run lint` | PASS — all thirteen application modules |

The new domain/integration tests cover the specified 6 days / 99 shots / 2970 active seconds example followed by one confirmed 30-second espresso: both 100 shots and 3000 seconds independently make the rule due while the seven-day boundary remains unmet. Calendar-day checks include Zurich midnight, DST and leap boundaries. Machine seconds use recorded active duration (including corrected/manual duration); filter time counts for its machine but never creates an espresso shot. Grinder throughput includes confirmed dose, purge and waste, plus net reversals/replacements, and remains independent of other grinders. Archived historical brews remain counted. A pure purge abort increases grinder throughput without inventing a shot; recorded machine timer duration remains separate from grinder use.

Completion tests verify cumulative baselines, unchanged other rules, unchanged brew and immutable ledger history, stable operation outcomes, concurrent revision rejection, invalid date/bounds rollback and JSON backup/replace roundtrip. Baseline cumulative seconds can exceed the single-brew 86400-second input limit; that aggregate is validated separately. A rule cannot migrate between devices, and completion history cannot be edited through generic entity saves. Sources must match the selected manufacturer's name and model. Explicit user-defined rules remain available without a source. Neither taste nor shot duration installs a cleaning threshold.

UC5 browser coverage verifies due-first ordering, both simultaneous reasons, cancellation changing nothing, dated completion with notes, reset of only the selected rule, retained history and updated Today/equipment panels. Form checks cover the exact no-positive-limit error, decimal comma, immutable device selection on edit, archive off by default, HTTPS sources and unverified labels. Other scenarios exercise missing rules/instructions, configured none-due, Baratza-only guidance without automatic rule creation, full-data search over 30 rules, 25-item pages, device filtering, return pagination, 500 ms draft autosave, dirty cancel, storage failure/retry/export and stale completion retaining local notes.

All new screen types were captured and visually inspected at both 1280 and 390 px: maintenance list, rule create/detail/edit, completion confirmation, empty collection, Today notices and equipment panels. The screenshot suite runs both light and dark themes with reduced motion, checks page-wide overflow, shared 3 px keyboard focus and Escape dismissal. S5 failure controls are also checked at 720×450 (200% equivalent reflow). Controls reuse the shared 44 px targets and contrast-tested tokens. No story stylesheet or visual literals were added. The style guide includes due/not-due counters, positive-limit errors, source/last-completion text, threshold fields, completion date/confirmation and saving/error/disabled states. Artifacts are under `test-results/s5/`, outside source control.

The existing 100-operation CI benchmark with 1000 bags and 10000 S4 draft brews remains in the declared suite. The final full run measured save P95 **76.5 ms** and filter P95 **0.4 ms**, both below 500 ms.

### Named-browser acceptance — INCOMPLETE

Chrome 156.0.8078.48, Firefox 158.0.1 (15826.10.19) and Safari 27.0 (21625.1.29.18.28) were not available for execution. Their named-browser/native 200% zoom results remain **INCOMPLETE**; bundled Chromium and equivalent-width reflow do not substitute. UC6 belongs to a later story.

### Assumptions

- Before the first completion, days start at rule creation; usage includes all recorded use of that device. A confirmed completion snapshots cumulative usage at logging time and restarts calendar days from the selected date. Completion dates cannot precede rule creation/the previous completion or lie in the future.
- An espresso shot is a completed espresso or an aborted espresso with confirmed dose consumption. Pure grinder purge/waste does not imply a machine shot. Saved active machine duration counts independently; unknown durations do not contribute invented seconds.
- Saving the rule is the explicit action establishing a user-defined cleaning/descaling interval. Entered manufacturer URLs remain unverified; no cleaning instructions or thresholds are fetched or installed implicitly. Baratza's general 4–6 week note is limited to Baratza grinders.
- Today shows at most three compact due notices and links to the complete list. Archiving a device preserves its use history and leaves its independently configurable rules available until the user archives them.
