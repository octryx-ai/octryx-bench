# Coffee companion — specification

Work item: COF-37.

## 1 Goal and scope

Build a responsive web app for a coffee enthusiast to reproduce espresso and manual filter brews, manage equipment and beans, and improve the next cup from recorded observations. A brew records its actual machine, grinder, settings, water, timing, beans and taste. Support four or more independently configured grinders, several roasters, and multiple physical bags of the same coffee.

First release: manual entry, guided timers, inventory accounting, resting readiness, reorder notices, maintenance reminders and explainable recommendations with source links. No connected scales, machine control, automatic purchases, shared accounts, social feed or automatic equipment diagnosis. Runtime web research is available on explicit request for a bean or equipment profile; normal brewing uses saved guidance and has no network dependency after loading.

The contract supplies the work-item description but no product_owner_answers or prior specification. Requirements explicitly requested there are marked PO in section 8. Other choices are proposed implementation defaults (D), not claimed as approved answers. There are no confirmed executable tests in this phase. Acceptance scenarios below define the expected implementation behavior.

## 2 Users and use cases

One local user manages one collection in one browser profile. They can export a backup and import it on another device; automatic synchronization and login are outside this release.

UC1 Register machines and four grinders with different burrs, dosing modes and adjustment scales; switch grinders without translating settings between them.

UC2 Register roasters, coffees, roast batches and individual bags; see remaining, resting, usable and frozen stock separately; receive a reorder notice early enough to allow delivery and resting.

UC3 Prepare an espresso with 17 g in the basket, a separately recorded purge, machine parameters and a timer; save actual yield, duration and taste; repeat a previous setup.

UC4 Follow a filter recipe that says how much water to add now, the cumulative target and when the next step starts; record actual amounts and timing.

UC5 See device-specific maintenance due from saved usage and elapsed days; log completion without deleting brew history.

UC6 Record water measurements with units and dates, compare with an explicitly selected guidance profile, and receive one proposed change for the next brew with its rationale and uncertainty.

## 3 Domain model

All entities have id (UUID string), createdAt/updatedAt (RFC3339 UTC), revision (positive integer), archived (boolean). Names are trimmed strings of 1–120 characters. References use IDs, never names. Optional values are null, never zero sentinels. Decimal quantities use integer tenths internally for grams and degrees Celsius; API/export fields expose decimal numbers with at most one decimal. Seconds are nonnegative integers. Dates are ISO YYYY-MM-DD in the user's configured IANA timezone.

| Entity | Required and optional fields beyond common fields |
| --- | --- |
| Settings | locale=`de-CH`, timezone=`Europe/Zurich`, theme=light/dark/system, defaultMethod=espresso/filter, default equipment IDs nullable |
| Machine | name, manufacturer/model nullable, kind=espresso/manual_filter/batch_filter, supported parameters: temperature °C, pressure bar, preinfusion seconds, basket capacity g (all nullable), manual sourceId nullable |
| Grinder | name, manufacturer/model nullable, burr=flat/conical/blade/other/unknown, drive=manual/electric, dosing=single_dose/hopper, adjustment=stepped/stepless/text, min/max/step numeric nullable, finerDirection=increase/decrease/unknown, burr description nullable, idleThresholdHours (default 12), purgeOnIdleG/purgeOnSwitchG nullable, lastUsedAt nullable |
| GrinderSetting | grinderId, displayValue string, numericValue nullable, calibrationLabel nullable; numeric step rules apply only to numeric adjustment |
| RetentionMeasurement | grinderId, occurredAt, inputG, outputG, retainedG computed, method=mass_balance/exchange_test, notes nullable; exchange purge recommendation is an independently entered measured value |
| Roaster | name, website nullable |
| Coffee | roasterId, name, origin/process/variety nullable, roast=light/medium/dark/unknown, reorderLeadDays default 5, safetyDays default 3, preferredRestDays per method nullable, sourceId nullable |
| Batch | coffeeId, roastDate nullable, restDaysEspresso/restDaysFilter nullable, rest sourceId nullable; immutable identity even for bags with the same roast date |
| Bag | batchId, initialG, openedOn nullable, storage=ambient/frozen, frozenOn/thawedOn nullable, notes nullable; balance is derived from ledger |
| StockMovement | bagId, signed amountG, kind=receipt/brew/purge/waste/adjustment/reversal, occurredAt, brewId nullable, operationId UUID, reason required for adjustment; immutable |
| Recipe | name, method, machineId nullable, grinderId nullable, setting nullable, doseG, ratio, temperatureC nullable, targetSeconds nullable, steps array for filter, sourceIds array; revisioned snapshots |
| FilterStep | offsetSeconds, incrementalWaterG, instruction string; order is ascending offset, with an explicit stable sequence for equal offsets |
| Brew | method, status=draft/running/interrupted/completed/aborted, startedAt nullable, durationSeconds nullable, recipe snapshot, machine/grinder/setting snapshots, water snapshot nullable, doseG, yieldG nullable (espresso beverage), pouredWaterG nullable (filter input), allocations [{bagId,doseG,purgeG,wasteG}], purge reason nullable, parameter snapshot, notes nullable |
| Taste | brewId, liking integer 1–5 nullable, sour/bitter/sweet/body/astringent integers 0–5 nullable, channelingObserved boolean nullable, notes nullable |
| WaterProfile | name, measuredOn nullable, measurementMethod string nullable, pH nullable, tdsMgL nullable, hardnessMgLCaCO3 nullable, alkalinityMgLCaCO3 nullable, chlorineNote nullable, sourceId nullable; water TDS differs from beverage concentration |
| MaintenanceRule | deviceId, task name, days/shots/throughputG/brewSeconds limits nullable (at least one positive), sourceId nullable, baseline completionId nullable; rules do not transfer between devices |
| MaintenanceCompletion | ruleId, completedAt, notes nullable, cumulative usage snapshot |
| Source | url HTTPS, title, publisher, retrievedAt, appliesTo, excerptSummary (own words), status=verified/unavailable/stale, reviewedAt nullable |
| Recommendation | brewId nullable, ruleId, input snapshot, proposed field/value nullable, rationale, confidence=low/medium, sourceIds, acceptedAt nullable; never changes a recipe automatically |

Deleting referenced entities archives them. Brew and ledger snapshots remain readable after renaming equipment or editing recipes. A coffee is not a roast batch and a batch is not a bag: two 250 g bags can have independent opening dates and balances.

## 4 Rules and formulas

The following are product rules with worked acceptance examples. Numeric brewing presets are starting points for experiments, not universal coffee facts. Sources S1–S4 justify recording freshness, cleaning, water and recipe variables; they do not validate the proposed numeric presets.

### R1 Stock conservation and idempotency

Bag balance = sum of its signed movements. Receipt adds initialG; saving actual consumption subtracts dose + purge + waste. Save all bag allocations and brew completion in one transaction. An operationId repeated with identical content returns the original result; reused with different content returns CONFLICT. Reject any transaction producing negative stock. Editing a completed brew adds reversal movements and replacement movements atomically; history remains intact.

Example: a 250 g receipt, 17 g dose and 2 g purge produce 250 − 17 − 2 = 231 g. Repeating the same save leaves 231 g. A second 250 g bag gives total stock 231 + 250 = 481 g. Aborting after physically grinding 17 g still offers recording 17 g waste; dismissing without confirmation makes no movement.

### R2 Retention and purge

Mass-balance retainedG = inputG − outputG, allowing negative results because old retained grounds can exit. Do not equate this with exchange retention. Purge suggestion = max(configured idle purge when idle hours >= threshold, configured switch purge when coffee batch changes), treating an inapplicable condition as zero. An applicable but unknown purge value yields “Spülmenge unbekannt – messen oder eintragen”, not a guessed quantity. User confirms actual purge; only actual grams debit stock. A grinder's last use is its own last confirmed grinding event, including aborted brews with confirmed consumption.

Example: input 20 g, output 18 g gives retained 2 g. With idle threshold 12 h, elapsed 13 h, idle purge 2 g and switch purge 3 g, suggestion = max(2,3) = 3 g; suggested bean requirement for 17 g dose = 20 g. Using a different grinder does not reset those 13 h. With elapsed 11 h and no switch, suggestion is 0 g.

Purge combination clarification: idle and coffee-change purge amounts are alternatives, not cumulative. One physical purge addresses both conditions; take the larger applicable configured amount. Thus the R2 example remains 3 g, not 5 g. If either applicable amount is unknown, the overall suggestion is unknown until entered, even when the other amount is known.

### R3 Resting and stock selection

Rest days precedence: batch override, coffee method preference, then proposed defaults espresso 10 days/filter 5 days. readyOn = roastDate + restDays calendar days; date >= readyOn means ready. S1 describes variation by roast, equipment and storage, so this is an editable readiness estimate, never a prohibition on brewing fresh coffee. Unknown roast date shows unknown readiness; frozen bags are excluded from ready stock, with no invented aging conversion. On thawing require confirmation of a readyOn date before recommending that bag. Ambient untouched batches retain their estimate.

Select bags automatically only among ambient ready bags, opened bags first, then roastDate ascending, createdAt ascending, id ascending. Explicit selection of resting/unknown beans requires “Trotzdem verwenden”; frozen bags require a storage change first. Split consumption across bags only after showing allocations for confirmation.

Example: roast 2026-11-01 plus espresso rest 10 days gives 2026-11-11; on November 10 status is resting with 1 day left, on November 11 ready. The filter default gives November 6. An override of 14 days gives November 15. Two ready bags of 10 g and 250 g cover a 17 g dose plus 2 g purge with allocations of 10 g and 9 g, leaving 0 g and 241 g.

Insufficient ready-stock selection: compute the full requested dose plus suggested (or manually entered) purge before offering automatic allocation. If ambient ready stock cannot cover it, show required and available grams and offer no partial automatic allocation. Start is blocked until the user reduces quantities, adds stock, or explicitly selects enough resting/unknown ambient bags with “Trotzdem verwenden”. Frozen bags remain unavailable. Manual allocation must cover the entire request before Start; the same nonnegative-stock validation applies at consumption save if balances changed meanwhile. Example: 17 g dose plus 2 g purge requires 19 g; 18 g ready stock produces no allocation and blocks Start with “Benötigt: 19 g; bereit: 18 g”.

### R4 Reordering with resting stock

For each coffee use total confirmed brew + purge + waste consumption in the last 28 complete local calendar days / 28 as dailyUseG. Permit a positive manual forecast when fewer than 7 days contain consumption; otherwise show “Noch keine belastbare Verbrauchsprognose”. Ready coverage = ready stock/dailyUseG; total coverage = all non-frozen stock/dailyUseG, labelled as including resting stock. ThresholdG = dailyUseG × (leadDays + methodRestDays + safetyDays). Show reorder when non-frozen stock <= threshold, plus a readiness-gap warning if ready stock < dailyUseG × leadDays. No automatic order. Proposed defaults: lead 5, safety 3; method resting follows R3. A newly received bag can clear reorder while retaining the readiness-gap warning.

Example: 560 g consumed/28 = 20 g/day; lead 5 + rest 10 + safety 3 = 18 days; threshold = 360 g. At 300 g ambient stock reorder is shown, total coverage = 15 days. Only 60 g ready gives 3 days ready coverage and 60 < 100 g produces the gap warning. A zero forecast produces no division and no coverage estimate.

Forecast method clarification: dailyUseG aggregates consumption across espresso and filter for each coffee; do not create separate stock forecasts per method. For the reorder threshold use the larger of that coffee's configured espresso and filter rest periods (coffee preference, otherwise R3 defaults), regardless of the currently selected brewing method. Batch rest overrides affect existing stock readiness only, not the estimate for a future delivery. Example: 280 g espresso consumption plus 280 g filter consumption gives 560/28 = 20 g/day; espresso rest 10 and filter rest 5 give max(10,5) = 10 days and threshold 20 × (5 + 10 + 3) = 360 g. If filter rest is overridden to 14, threshold becomes 20 × (5 + 14 + 3) = 440 g. Ready coverage uses bags ready for the user's defaultMethod and is labeled with that method; total coverage and reorder threshold remain method-independent.

### R5 Brew ratios and filter guidance

Espresso ratio = beverage yield/dry dose; default target 1:2 means targetYieldG = doseG × 2. Filter ratio refers to input water/dry dose, default 1:16. Scale steps by newDose/originalDose; round each non-final increment to 0.1 g, set final increment to rounded total minus prior increments. Reject a nonpositive final increment. Display both incremental and cumulative quantities. Filter offset times are absolute from first pour; overdue steps remain visible until acknowledged; do not start a new step by silently skipping one.

Example: espresso dose 17 g × 2 gives 34 g target. A filter dose 15 g × 16 gives 240 g input water. Proposed starter steps are 45 g at 0 s, 95 g at 45 s, 100 g at 90 s; cumulative targets are 45, 140, 240 g. Scaling to 20 g uses factor 20/15; increments become 60.0, 126.7, 133.3 g, totaling 320.0 g. These are app presets, not a recipe attributed to S4. Filter beverage yield is not a structured measurement in this release; yieldG remains null and is never substituted for poured water.

### R6 Timer and maintenance

Elapsed active seconds = floor((now − startedAt − accumulatedPausedDuration)/1000). Espresso starts on the user's “Start” (pump start convention, preinfusion included); stopping records elapsed time. Filter begins at first pour. Timer display is derived from timestamps, not counts of interval callbacks; background tabs recalculate on return. Reload restores an interrupted session and offers “Fortsetzen” or “Abbrechen”; never presumes the pump stopped. Manual correction stores original and corrected duration with a reason.

Maintenance is due when ANY configured limit is reached since that rule's last completion. Count shots only for espresso usage recorded for that machine, throughput including purge/waste for that grinder, active brew seconds for that machine, calendar days independently. No default shot-duration threshold determines cleaning or descaling. Without device instructions show “Reinigungsintervall festlegen”; allow an explicit user-defined rule. S2's 4–6 week grinder guidance is shown only as Baratza general guidance, not installed on unrelated devices. Descaling requires a matching manufacturer source or a user-defined rule and never follows taste alone.

Example: a user configures 7 days OR 100 shots OR 3000 brew seconds. Since completion there are 6 days, 99 shots, 2970 seconds. One 30-second shot makes 100 shots and 3000 seconds, so due is true with both reasons. Completion resets that rule's counters; other rules remain unchanged. Timer start at 10:00:00, pause 10:00:10–10:00:15, stop 10:00:35 gives 35 − 5 = 30 s.

### R7 Water and taste advice

Compare only measured fields to a selected saved guidance profile, showing measured value, profile bounds, source and date. No inference of hardness from TDS or alkalinity from pH. Proposed reference profile transcribes the historical ranges reported in S3: TDS 75–250 mg/L; pH 6.5–7.5; alkalinity target 40 mg/L as CaCO3 (target only, no invented pass band). Label it “Literaturprofil (2018), keine Maschinenfreigabe”. Machine water limits take precedence for equipment guidance; missing limits display “Herstellervorgaben fehlen”. No mineral dosing, potability or corrosion diagnosis in release one.

Taste recommendation priority: missing dose/yield/time prompts recording; channelingObserved=true prompts preparation consistency; sour and bitter both >=3 prompts checking uneven extraction; sour>=3 with bitter<3 proposes one finer grinder step if calibrated; bitter>=3 with sour<3 proposes one coarser step. With unknown scale direction give a textual experiment without a numeric setting. Sweet/balanced with both <3 proposes repeating. No rule guarantees taste or prescribes cleaning from sourness. Show confidence low and preserve all other recipe parameters. Explicit acceptance creates a new recipe revision. S4 supports controlling brew variables; this decision tree is an app heuristic.

Example: TDS 280 against upper 250 is 30 mg/L above; missing hardness remains unknown. With sour=4, bitter=1, stepped setting=12, step=1, finerDirection=decrease, proposed setting=11; dose=17 g and target=34 g remain. With sour=4 and bitter=4, no numeric grind change is offered. Each recommendation shows the triggering measurements and its rule identifier.

Numeric grinder-step contract: a numeric recommendation requires adjustment=stepped, finite numericValue, positive configured step, finite min/max, a value on the grid min + n × step for nonnegative integer n, and known finerDirection. For finer, subtract step when finerDirection=decrease and add it when increase; coarser reverses that sign. Perform decimal arithmetic without binary-float drift. If the candidate lies outside inclusive min/max, offer no numeric change, do not clamp or wrap, and show “Grenze der Geräteskala erreicht – keine Mahlgradänderung vorgeschlagen”. Missing calibration gives the textual experiment specified in R7. Example: min=0, max=20, step=1, setting=12, direction=decrease gives finer=11 and coarser=13. At setting=0, finer would be −1 and is rejected; at setting=20, coarser would be 21 and is rejected. This contract also applies when showing numeric step controls in setup and recipe forms.

### R8 Research provenance

Research is explicit (“Informationen recherchieren”), never a hidden dependency of Save or Start. Search using manufacturer/model or roaster/coffee and method; open pages before extracting guidance. Prefer exact manufacturer manuals and roaster pages; otherwise label expert guidance. Save URL, title, publisher, retrieval time, applicability and summary. A candidate requires user acceptance before changing profile values. Conflicting sources appear separately. Unavailable search/fetch leaves existing data unchanged, displays “Recherche derzeit nicht verfügbar”, and permits manual entry. Guidance older than 180 days is marked stale, without silently deleting it.

Example: retrieved 2026-01-01, reviewed never, age 181 days on 2026-07-01 => stale (181 > 180); at age 180 it remains current. Two conflicting rest recommendations produce two candidates and zero automatic changes.

## 5 Defaults, limits, ordering and errors

All bounds below are product validation limits, not equipment operating recommendations. Grams 0–1000000 with one decimal; brew dose >0 and <=1000; ratio >0 and <=100; water temperature 0–100 °C; pressure 0–20 bar; durations 0–86400 s; water concentrations 0–10000 mg/L; pH 0–14; rest/lead/safety days 0–365. Numeric fields reject NaN, infinity, unknown units and excess precision. UI accepts decimal comma or point; no thousands separator in input. Unknown machine parameters stay null. Equipment manual bounds, if entered, further constrain recipe values. Text notes <=4000 characters, URLs <=2048, filter steps 1–30. Exactly zero actual consumption is allowed for a discarded draft, never as a completed dose.

Lists sort by name using de-CH collation then id, except history newest startedAt first then id, maintenance due first then device name, and bags by R3. Lists have 25 items/page, search across full data, archive toggle off initially. Search matches case-insensitive substrings of displayed names and roaster names. Empty filters show “Keine Treffer” and “Filter zurücksetzen”; empty collections show the relevant create action. No missing measurement renders as 0. Unknown estimates render “Unbekannt”.

Only one running brew exists per browser collection. Start a second => “Ein Bezug läuft bereits” linking to it. Insufficient stock prevents committing consumption, keeps the draft and shows required and available grams; correction or another bag is required. Save/storage failure retains form values and offers retry/export. Unsupported import version, broken references, duplicate IDs or negative resulting stock reject the entire import with a path-specific error. Version conflicts preserve the user's draft and offer reload; never last-write-wins silently. Referenced data is archived, standalone drafts may be deleted after a confirmation dialog. A cancelled dialog changes nothing.

## 6 Interfaces and formats

This specification defines a local domain interface; it does not require an HTTP backend. All domain operations return `{ok:true,data,revision}` or `{ok:false,error:{code,field,message}}`. Codes: VALIDATION, NOT_FOUND, INSUFFICIENT_STOCK, CONFLICT, STORAGE_UNAVAILABLE, RESEARCH_UNAVAILABLE, UNSUPPORTED_VERSION. Errors have German user text; machine codes remain stable. No partial success for commands.

Commands: `saveEntity(type, entity, expectedRevision)` creates with null expectedRevision or updates matching revision; `startBrew(brewId, startedAt)` snapshots selected profiles; `recordConsumption(brewId, operationId, allocations, expectedRevision)` records actual use even on abort; `completeBrew(brewId, operationId, actuals, taste, expectedRevision)` atomically records remaining unrecorded consumption and completion; allocations already recorded by operation are referenced rather than charged twice. `reviseBrew` reverses and replaces completed consumption per R1. `completeMaintenance(ruleId, completedAt)` records baseline. `researchProfile(type,id)` returns candidates, not mutations; `acceptCandidate(candidateId,expectedRevision)` stores source and selected values atomically. Every input uses section 3 types and section 5 bounds.

Example complete actuals: `{durationSeconds:30,doseG:17,yieldG:34,pouredWaterG:null,allocations:[{bagId:"<UUID>",doseG:17,purgeG:2,wasteG:0}]}`. Espresso requires yieldG>0 and pouredWaterG=null; filter requires pouredWaterG>0 and yieldG=null. Opposite-method measurements are outside this release's structured data contract; non-null opposite-method fields return VALIDATION with that field named. Notes remain unstructured observations and are never parsed as measurements. A user confirms actual consumption before committing.

Export downloads UTF-8 JSON named `coffee-backup-YYYY-MM-DD.json`, MIME application/json, root `{schemaVersion:1,exportedAt,settings,entities:{machines,grinders,retentionMeasurements,roasters,coffees,batches,bags,stockMovements,recipes,brews,tastes,waterProfiles,maintenanceRules,maintenanceCompletions,sources,recommendations}}`. All arrays are present; references preserve UUIDs. Nulls are explicit. Import is replace-only with a preview of counts, version validation and “Daten ersetzen” confirmation; export existing collection first. Limit 20 MiB; no CSV import in release one. Treat imported text as text, never HTML or code. URL schemes restricted to HTTPS; imported sources remain unverified until opened/reviewed.

Persist entities and ledger atomically in IndexedDB. Drafts save after a 500 ms idle interval and on explicit Save. A visible indicator distinguishes “Entwurf gespeichert” from “Nicht gespeichert”. Cross-tab revisions prevent duplicate completion; broadcasts refresh idle views. A new tab cannot claim a timer without obtaining the active-session lock in the same transaction. Research uses a server-side search/fetch adapter; provider credentials never enter browser storage or exports. Only profile query fields are sent, with the query preview before submission. Fetch accepts public HTTPS, rejects private/local destinations and redirects to them, and limits responses to 2 MiB and 15 seconds; returned content is data, never executable instructions.

Import size contract: measure the original uploaded file's byte length (browser File.size), before decoding or parsing. Accept at most 20 × 1024 × 1024 = 20971520 bytes; reject 20971521 bytes or more with VALIDATION, field `file`, and “Datei zu gross: maximal 20 MiB (20 971 520 Bytes).” Do not alter existing data or open the replacement confirmation for an oversized file.

## 7 Non-functional requirements

German (`de-CH`) is the only first-release UI language; English internal field names are not displayed. Dates DD.MM.YYYY, decimal comma, units g, s, min, °C, bar and mg/L; hardness/alkalinity append “als CaCO₃”. Raw JSON remains locale independent.

Keyboard reaches every control with visible focus. Exact accessibility targets: WCAG AA contrast >=4.5:1 for normal text, >=3:1 for large text and meaningful control boundaries; focus outline >=2 CSS px with >=3:1 adjacent contrast; interactive targets >=44×44 CSS px. Errors connect to inputs; timer announcements occur only on step transition, not each second; reduced-motion preference disables animation. Color always has text/icon redundancy.

At 390×844 and 1440×900 CSS px, no page-wide horizontal scrolling; at 200% zoom controls remain reachable. Loaded timers and drafts operate without internet; research explicitly indicates offline. Verify latest stable Chrome, Firefox and Safari at implementation time. On a fixture of 10000 brews and 1000 bags, list filtering and local saves finish within 500 ms at the 95th percentile across 100 operations on the documented CI browser host; record host and measured results. Stopwatch is within 1 s of timestamp-derived elapsed after a background-tab interval of 5 min. Data survives reload, including interrupted timers, and export/import roundtrip preserves balances and snapshots exactly.

Acceptance coverage: unit tests for R1–R8 including nulls, boundaries, rounding, date rollover and per-device isolation; integration tests for atomic save and cross-tab conflict; Playwright scenarios UC1–UC6, failed storage/research, export/import, keyboard use and both viewport sizes/themes. Test fixtures include four grinders, two roasters, two batches of one coffee and two bags of one batch. No executable implementation exists in this draft workspace; these are required future checks, not reported passing tests.

The environment file declares the intended Node unit-test and Playwright commands for subsequent implementation. This documentation phase creates no package manifest, lockfile or test suite; readiness checks therefore fail until implementation supplies them. No setup or application tests were run in this phase. All installations and caches declared there stay inside the app folder.

Browser version policy (supersedes “latest stable” above): at implementation acceptance, pin full desktop Chrome, Firefox and macOS Safari version numbers and OS/build in the committed acceptance report, using stable versions available on that report's date. Freeze those versions for reruns of that release; record a new version matrix and rerun acceptance when a browser version changes. Record the Playwright package and bundled Chromium build separately; Chromium-only pipeline success does not substitute for Chrome, Firefox or Safari acceptance. In each of the three named browsers, require UC1–UC6, stock/idempotency persistence, reload/timer recovery including the 5-minute background check, cross-tab conflict handling, research/storage failure behavior, JSON roundtrip and import validation, keyboard/focus checks, both viewport sizes, both themes and 200% zoom to pass. Browser-independent unit tests run once on the pinned Node version; the specified performance benchmark runs on the pinned CI Chromium host only. A browser without recorded results leaves release acceptance incomplete.

### COF-38 implementation acceptance

Actual implementation versions, executed test results, performance measurements and the incomplete named-browser matrix are recorded in [ACCEPTANCE.md](ACCEPTANCE.md), section 7. This supersedes the documentation-phase statement above that no executable implementation exists.

## 8 Decisions

PO1 (§1, §2): First deliverable is a web app for coffee enjoyment and repeatable preparation.

PO2 (§3, R6): Record machine settings and shot duration; provide usage-based cleaning reminders.

PO3 (§3, R2): Track grinder settings and variable retention, recommending purge after inactivity and changes.

PO4 (§3, R1): Maintain bean inventory including the 17 g basket dose and separate purge usage.

PO5 (§3, R7): Record water values and taste and propose improvements.

PO6 (§3, R5): Guide filter preparation with timed incremental water additions.

PO7 (R8, Sources): Research external information needed for the specification and profile guidance.

PO8 (§3): Support multiple grinders and types, multiple roasters, and repeated bags of the same coffee.

PO9 (R3, R4): Include reorder guidance and post-roast resting before recommending beans.

D1 (§1, §2, §6): Proposed single-user local storage, manual operation and JSON transfer; no login or sync.

D2 (§5, §7): Proposed German Swiss locale, metric units, Europe/Zurich timezone, validation limits and ordering as specified.

D3 (R2): Proposed 12 h idle threshold, independently measured purge amounts and no arbitrary default purge grams.

D4 (R3): Proposed editable 10-day espresso/5-day filter resting estimates, source/override precedence and explicit early-use confirmation.

D5 (R4): Proposed 28-day forecast, 7 active days for confidence, 5-day delivery and 3-day safety defaults.

D6 (R5): Proposed 1:2 espresso, 1:16 filter and the three-step starter recipe with exact rounding.

D7 (R6): Proposed pump-start timer convention, timestamp recovery and device-specific OR maintenance limits, with no universal shot-time cleaning rule.

D8 (R7): Proposed historical water reference label and deterministic, low-confidence, single-variable taste experiments.

D9 (R8): Proposed explicit research acceptance, provenance and 180-day stale marker.

D10 (§6, §7): Proposed atomic persistence, idempotency, replace-only validated import and measurable accessibility/performance acceptance.

D11 (UI and design): Proposed warm workshop journal design, light/dark/system themes and screen composition below.

D12 (R2, R3): Assumption for automatic revision 1: purge conditions use the maximum, not a sum; insufficient ready stock offers no partial allocation and blocks Start until the full requirement is explicitly covered.

D13 (R4): Assumption for automatic revision 1: forecast consumption spans both methods; future-delivery resting uses the larger method preference/default, while ready coverage names the selected default method.

D14 (R7): Assumption for automatic revision 1: numeric advice requires a calibrated stepped scale and rejects out-of-range candidates without clamping.

D15 (§6): Assumption for automatic revision 1: opposite-method structured measurements are excluded; import size is the original file's bytes with the explicit 20 MiB error above.

D16 (§7, UI and design): Assumption for automatic revision 1: browser acceptance pins full versions and runs the stated matrix; coffee-card height follows the sizing intent below.

PO10 (§8): Automatic revision 1 of 2 requests fixing all independent-review findings and unverified tasks; product choices use the simplest option consistent with this specification and are disclosed as assumptions.

## 9 Open questions

None explicitly left open by the product owner in the supplied run contract. Section 8's D entries are proposed defaults for review, not previously accepted product-owner decisions.

## UI and design

### Direction and screen families

“Warm workshop journal”: a quiet cream workspace, ink typography, copper actions, technical measurements aligned in tabular numerals, and illustrated equipment/bean silhouettes. List screens resemble a tidy shelf of labeled coffee bags with compact factual rows beneath. Details resemble a journal page with a profile header and grouped measurements. Forms resemble a setup sheet with persistent labels, units at the right and a bottom Save row. Focus mode resembles a brewing instrument: large timer, one current instruction, next target and a single dominant control. No stock photography or decorative hero occupies brewing space.

### Tokens

All aesthetic values below are intent, refinable during build. Exact values are restricted to section 7's accessibility targets. Fonts intent: headings Georgia/serif, body system-ui/sans-serif, measurements ui-monospace/monospace; type scale 12/14/16/20/28/40/64 px, weights 400/600/700. Spacing intent 4/8/12/16/24/32/48 px; radius intent 8 px controls, 16 px cards, round status dots; shadow intent 0 4px 20px #241A1214. Breakpoints intent: phone <640 px, tablet 640–1023, desktop >=1024; content max width intent 1200 px.

| Color role (all intent) | Light | Dark override |
| --- | --- | --- |
| Page | #F6F0E7 | #181512 |
| Sidebar | #EBE2D5 | #211C18 |
| Panel | #FFFDF8 | #29221D |
| Text | #2B211B | #F5EBDD |
| Secondary text | #68594C | #C4B4A4 |
| Border | #C6B6A5 | #756457 |
| Primary/action | #854523 | #EDAA7B |
| On-primary | #FFFFFF | #24180F |
| Ready/success | #315E45 | #A0D0AF |
| Warning | #795315 | #E8C17B |
| Error | #A12F32 | #FFA7A7 |
| Focus | #175E91 | #8BCBFF |

Validate final token combinations against exact contrast requirements, refining aesthetic values as needed. Themes override tokens throughout backgrounds, forms, charts and illustrations, not only body text.

### Drawn visual anchors

Coffee cards devote about a third of their height to a drawn bag: a centered outlined rectangle with folded top, a round bean glyph split by a curved seam, and roaster initials on its label. Its background is a 135-degree gradient. Choose variant by sum of coffee-name Unicode code points modulo 3: light stops #EAD5BD→#C59770, #DBDFCE→#A6B794, #E8D4CD→#C39485; dark equivalents #453426→#71523A, #303A2D→#506047, #44302C→#715044. Glyph is ink token, never the only identifier; coffee name/roaster are text below. Batch readiness appears as a text chip beside roast date, never encoded only by hue.

Equipment anchors use a 48 px line drawing at the upper left of a 96 px token-sidebar area: espresso machine = rectangular group head and two cups; filter = cone over carafe; grinder = hopper, burr circle and grounds cup. Flat/conical burrs use two parallel discs/a nested cone inside that circle; other/unknown use a dotted circle. Name hash selects the same three gradient pairs, with theme overrides above. Empty-state illustrations are 64 px outline objects centered above one sentence and create button: empty bag for beans, unconnected gear for equipment, droplet for water, cup for history/recipes, brush for maintenance. Use border token outlines with primary-token seam/detail; no random imagery. Dashboard has no hero: the next-brew panel uses the selected coffee's bag anchor; absent selection uses the empty cup. Loading placeholders keep anchor shape and use panel/sidebar tokens with no shimmer under reduced motion.

Coffee-card sizing intent: minimum total height 288 CSS px, with an anchor region of 96 CSS px at that height, yielding 96/288 = one third. At desktop and phone widths use the same minimum and allow the text body to grow for wrapping or zoom; do not crop text to preserve the proportion. The bag drawing fits within an 80 × 80 CSS px box centered in that anchor. These values guide the build and are not exact accessibility constraints.

### Components and states

| Component | Default and hover | Selected and disabled | Empty, loading and error |
| --- | --- | --- | --- |
| Button/link | Primary solid action token; secondary outlined; hover underline links and darken/lighten button by one visible token step | Selected uses check icon and aria-pressed; disabled uses muted token, disabled attribute and adjacent reason | Async label “Wird gespeichert…” and spinner, duplicate action disabled; error preserves enabled retry |
| Cards/rows | Panel with border, anchor, name and 2–4 measurements; hover border action color | Selected check and thicker border; archived “Archiviert” | Empty illustration and entity action; loading 3 labeled skeletons “Wird geladen…”; error “Daten konnten nicht geladen werden” + “Erneut versuchen” |
| Fields/selectors | Visible label, current value, unit and help; hover border primary | Selection text+check; disabled reason | Missing uses “Nicht erfasst”; loading selector “Wird geladen…”; invalid error text below field and error border; retain value |
| Status chip | Icon+German status, outlined by semantic token; hover tooltip with reason | Active filter check; unavailable filter disabled with reason | Unknown “Unbekannt”; loading “Wird berechnet…”; failed “Nicht verfügbar” |
| Timer/stepper | Tabular timer and current/next instruction; hover controls as buttons | Current step numbered and marked “Jetzt”; completed check; unavailable next action disabled | Initial 00:00 “Bereit”; restore “Unterbrochener Bezug”; invalid time shows correction field; no silent reset |
| Dialog/toast | Panel above scrim, named heading, close and explicit actions | Focus trapped/restored; destructive primary text states consequence | Progress “Wird importiert…”; error remains open; empty preview “Keine Daten zum Importieren”; no empty heading |
| Measurement/advice panel | Label, value+unit, source/reason; hover source underline | Accepted advice “Übernommen”; missing prerequisites disable acceptance with reason | Empty “Noch keine Messung”; loading “Recherche läuft…”; research failure copy R8 and retry |

Every component uses both token themes. Focus is visible in all states that can receive it. Skeletons never replace an active timer. Toasts announce saves but persistent inline errors remain until corrected.

### Shell and navigation map

Desktop: full-height left sidebar, app name “Kaffeejournal”, routes below, theme control at bottom. Main content contains title/action row, content and optional right summary. Phone: title bar, content, fixed bottom navigation “Heute”, “Brühen”, “Bohnen”, “Mehr”; Mehr opens a full-height route list. Main padding includes bottom navigation height. Sidebar/panels/page background extend to viewport bottom on short pages. Breadcrumb/back returns to source list with search and pagination preserved.

| Screen/route | Desktop entry | Phone entry |
| --- | --- | --- |
| Today `/` | Heute | Heute |
| Brew setup `/brew/new` | Brühen or today's primary | Brühen |
| Focus `/brew/:id/run` | Setup Start; active-brew banner | Same |
| Brew review/detail `/brews/:id` | Focus finish or history row | Same |
| History `/brews` | Verlauf | Mehr → Verlauf |
| Beans `/beans` | Bohnen | Bohnen |
| Coffee detail `/beans/:id` | Coffee card | Same |
| Inventory form `/beans/new`, `/beans/:id/edit`, `/beans/:id/bags/new`, `/bags/:id/edit`, `/roasters/new` | Beans/detail actions | Same |
| Equipment `/equipment` | Geräte | Mehr → Geräte |
| Equipment detail `/equipment/:id` | Equipment card | Same |
| Equipment form `/equipment/new`, `/equipment/:id/edit` | Geräte/detail actions | Same |
| Recipes `/recipes`, detail `/recipes/:id` | Rezepte; recipe row | Mehr → Rezepte; row |
| Recipe form `/recipes/new`, `/recipes/:id/edit` | Recipes/detail actions | Same |
| Water `/water`, form `/water/new`, `/water/:id/edit` | Wasser; row edit/new | Mehr → Wasser; same |
| Maintenance `/maintenance`, rule form `/maintenance/new`, `/maintenance/:id/edit` | Pflege; rule action | Mehr → Pflege; same |
| Settings `/settings` | Einstellungen | Mehr → Einstellungen |

Direct links load the same screen; missing IDs show “Eintrag nicht gefunden” and “Zur Übersicht”. Forms use the same shell; focus suppresses sidebar/bottom navigation in favor of “Zur Übersicht” and the active-brew banner on return.

### Screen composition and copy

All text below is the release's German copy; variable names in braces are interpolated with localized values/units. Shared Save/Cancel actions read “Speichern”/“Abbrechen”; Save validates and persists then returns to detail, Cancel warns “Ungespeicherte Änderungen verwerfen?” if dirty. Shared research action opens a query preview “Suchanfrage”, “Recherche starten”, then candidate/source cards with “Übernehmen”; error/loading states follow component catalogue. No English fallback UI.

| Screen | Regions, density and elements | Primary action and secondary actions | Empty and exceptional state text |
| --- | --- | --- | --- |
| Today | Spacious next-brew panel first, then two compact panels “Bohnen bereit” and “Pflege fällig”; selected coffee anchor, last setup and stock warning | “Kaffee zubereiten” opens setup; “Letzten Bezug wiederholen” copies snapshot to draft; notice links to beans or maintenance | “Dein erster Kaffee beginnt hier” with setup action; no due tasks says “Keine Pflege fällig” |
| Brew setup | Medium-density form grouped “Methode”, “Bohnen”, “Geräte”, “Rezept”, “Wasser”; stock allocation/purge preview on right or below on phone; labels “Dosis”, “Zielmenge”, “Mahlgrad”, “Temperatur”, “Vorbrühzeit”, “Druck” | “Start” validates, snapshots and enters focus; “Rezept wählen”, “Manuell erfassen” (review without timer), “Abbrechen” | “Keine Bohnen vorhanden” links bag form; “Kein Gerät ausgewählt”; “Bohnen ruhen noch bis {date}” and explicit override; stock error §5 |
| Focus | Sparse, machine+coffee identity, large elapsed mm:ss, current filter step “Jetzt {increment} g zugeben, insgesamt {total} g”, next step/time below; espresso target dose/yield | “Stoppen” espresso / “Schritt bestätigen” filter; after final step primary “Bezug beenden”; secondary “Pause”/“Fortsetzen”, “Abbrechen”, actual amount correction | “Nächster Schritt überfällig” preserves pending instruction; interrupted restore per R6; abort dialog “Wurde Kaffee verbraucht?” offers consumption fields and confirmation |
| Brew review/detail | Medium-density actual measurements, setup snapshot, taste sliders with “Nicht bewertet” option, notes, then one advice panel and provenance | Unsaved “Bezug speichern”; saved “Erneut zubereiten”; secondary “Bearbeiten”, “Empfehlung übernehmen” creates recipe revision, “Quelle öffnen” | “Noch keine Geschmacksbewertung”; “Für eine Empfehlung fehlen Messwerte”; show missing fields; advice never replaces saved measurements |
| History | Compact dated rows showing method, coffee, grinder, dose, yield/water and liking; date/method/coffee filters above | “Bezug erfassen” opens setup manual mode; row opens detail; “Filter zurücksetzen”, pagination | “Noch keine Bezüge” with primary; filtered empty “Keine Treffer” |
| Beans | Medium card grid, stock totals “Gesamt”, “Bereit”, “Ruhend”, “Gefroren”; search/roaster/readiness filters, reorder notice with reason | “Bohnen hinzufügen”; coffee cards open detail | “Noch keine Bohnen” bag illustration; “Noch keine belastbare Verbrauchsprognose” when R4 lacks data |
| Coffee detail | Bag anchor and roaster header; batch groups with roast/rest dates; bag rows with balances, opening/storage; forecast panel and recent brews | “Beutel hinzufügen”; “Bearbeiten”, “Röster hinzufügen”, “Informationen recherchieren”, bag edit, “Mit diesen Bohnen brühen” | “Kein Beutel auf Lager”; “Röstdatum unbekannt”; “Nachbestellen empfohlen: {reason}”; no dead heading above missing history |
| Inventory forms (all listed routes) | Medium single-column grouped fields; coffee form name/roaster/origin/process/roast/preferences; bag form batch selector or “Neue Charge”, roast date, initial mass, opening and storage; roaster form name/website | “Speichern”; Cancel; “Charge hinzufügen” reveals inline fields without losing bag draft | “Röstdatum fehlt – Reife unbekannt”; current-balance corrections require “Grund der Korrektur”; receipt quantity edit uses ledger adjustment rather than replacing history |
| Equipment list | Compact cards grouped “Maschinen”/“Mühlen”, device anchor, type and last use, count not capped at four | “Gerät hinzufügen”; row detail | Each missing group has its own gear illustration, “Noch keine Maschine”/“Noch keine Mühle” and create action |
| Equipment detail | Medium header, settings/retention table, last use, maintenance and source panel | “Mit diesem Gerät brühen”; “Bearbeiten”, “Totraum messen” opens inline input/output/exchange measurement form, “Informationen recherchieren”, “Archivieren” | “Noch keine Totraummessung”; “Spülmenge unbekannt”; “Reinigungsintervall festlegen” links maintenance form |
| Equipment form | Medium grouped identity/type, adjustment scale/direction, supported machine bounds or grinder purge settings; conditional fields from section 3 | “Speichern”; Cancel | Numeric incompatibilities show “Wert liegt ausserhalb der Geräteskala”; text scale explicitly allows “Feiner-Richtung unbekannt” |
| Recipes list/detail | List compact method/name/dose/ratio; detail journal page with step table, equipment and source, recipe revision | List “Rezept erstellen”; detail “Rezept brühen”; secondary edit/duplicate/archive | “Noch keine Rezepte”; starter recipe available with badge “Startvorschlag” and preview before creating |
| Recipe form | Medium method/dose/ratio/target/temperature groups; filter step rows offset+increment with computed total | “Speichern”; “Schritt hinzufügen”, “Schritt entfernen”, Cancel | “Wassermengen ergeben nicht die Zielmenge” blocks inconsistent manual recipe; “Mindestens ein Schritt erforderlich” |
| Water list/form | List measurement cards with date and missing-field labels; form identity, measurement date/method and section 3 values; comparison panel beneath selected profile | List “Wasserprofil hinzufügen”; form “Speichern”; secondary edit/select reference/source link | “Noch kein Wasserprofil”; “Keine Messung für {field}”; outside profile states measured value and bound without a green machine-approval badge |
| Maintenance list | Compact due-first task rows grouped device, counters, due reasons, last completion and source | “Pflege protokollieren” on selected task opens completion confirmation with date; “Regel hinzufügen”, edit/source | “Keine Pflege fällig” when configured rules aren't due; with none “Noch keine Pflegeregeln” plus create action |
| Maintenance rule form | Medium device/task, optional thresholds grouped “Fällig sobald eine Grenze erreicht ist”, source URL and user-defined label | “Speichern”; Cancel | “Mindestens eine positive Grenze angeben”; no generic backflush/descale instructions without applicable source |
| Settings | Medium grouped “Darstellung”, “Region”, “Datensicherung”; theme radio buttons, timezone selector, backup/import file control and counts preview | “Einstellungen speichern”; “Daten exportieren”, “Daten importieren” opens preview/replace dialog | “Dateiformat nicht unterstützt”; “Daten ersetzen?” names counts and backup action; storage unavailable persistent message “Lokales Speichern nicht verfügbar” |

### Look and feel

LF1 All screens: cream/ink/copper in light, warm charcoal/parchment/copper in dark; background, sidebar and panels extend to the bottom of the viewport on short pages.

LF2 Today, Beans, Coffee detail: coffee bag anchors have folded top, bean seam and roaster initials over the specified name-derived gradient; different hash variants visibly differ in both themes.

LF3 Equipment list/detail: machine, filter and grinder silhouettes identify device kinds, with flat/conical/unknown burr details visible on grinder cards.

LF4 Focus: timer is the largest text; exactly one primary action, current increment and cumulative water target are visible without opening a menu at phone width.

LF5 All forms and review: units align beside values, labels remain visible after entry, unknown values say “Nicht erfasst” or “Unbekannt”, errors have words and an error outline.

LF6 All lists, Today and details: no heading sits above an empty region; each absence has the specified drawn icon, sentence and appropriate next action or explicit “Keine Pflege fällig”.

LF7 Every screen: every visible label, date, decimal and unit follows de-CH; no internal enum or English fallback appears.

LF8 Shell: desktop sidebar and phone bottom navigation identify the current destination; content clears the fixed phone navigation, and focused controls have the specified visible outline.

LF9 Cards and panels: restrained borders and spacing separate factual groups; technical values use tabular numerals, headings use the journal serif, no photography replaces specified drawings.

LF10 Review, water and maintenance: recommendations show triggering values and source/date or “Benutzerdefiniert”; readiness and due states include text and icon so the screenshot remains interpretable without color.

## Sources

Sources S1, S2 and S3 were checked again during review. Their contents continue to support variable resting estimates, manufacturer-scoped cleaning guidance and separately recorded water properties; no change to those factual claims was required.

Sources were opened and read on 2026-11-16. These sources support the limited statements attributed above, not all numeric product defaults. This is not a claim that historical guidance is a current SCA standard.

- S1 Scott Rao, resting variation and storage dependence: https://www.scottrao.com/blog/restingbeans
- S2 Baratza, grinder cleaning and general 4–6 week routine: https://www.baratza.com/en-us/blog/cleaning/grinder-cleaning-essentials
- S3 Jonathan Gagné, separately recorded water properties and historical reference ranges: https://coffeeadastra.com/2018/12/16/water-for-coffee-extraction/
- S4 Jonathan Gagné, filter brewing variables and repeatability: https://coffeeadastra.com/2018/11/30/brewing-better-coffee/

Change summary: automatic revision 1 addresses all eight review findings: alternative purge amounts, full-stock allocation before Start, cross-method forecasts with the larger rest estimate, reproducible bounded grinder steps, exclusion of opposite-method structured measurements, byte-measured import limits with error copy, implementable card sizing, and pinned browser acceptance. The simplest product assumptions are D12–D16. No question was explicitly left open by the product owner. Implementation and browser execution remain future acceptance requirements, not verified results of this documentation phase.
