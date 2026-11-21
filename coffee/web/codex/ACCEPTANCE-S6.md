# COF-43 — water, taste advice and research acceptance

## 7 Non-functional requirements — actual S6 results

Extends [S1](ACCEPTANCE.md), [S2](ACCEPTANCE-S2.md), [S3](ACCEPTANCE-S3.md), [S4](ACCEPTANCE-S4.md) and [S5](ACCEPTANCE-S5.md). Rechecked Node 26.4.0, npm 11.17.0, Playwright 1.58.2; app-local bundled Chromium revision 1208, Chrome for Testing 145.0.7632.6. The browser package and Playwright version are pinned in the app-local setup and lockfile; the measured CI host is a macOS/arm64 host, not an unspecified Linux substitute.

| Declared command | Actual result |
| --- | --- |
| `node --test tests/unit/*.test.mjs` | PASS — 65 tests |
| `PLAYWRIGHT_BROWSERS_PATH=./.cache/ms-playwright ./node_modules/.bin/playwright test` | PASS — 73 scenarios, 1.9 min |
| `npm run lint` | PASS |

Domain/integration coverage includes R1–R8 nulls, finite numeric bounds, exact stepped grids/rounding, calendar boundaries, device isolation, ledger conservation/idempotency, revisions and transactional rollback. S6 adds method-specific missing measurements, channeling priority, both sour/bitter high, one-step finer/coarser 12→11/13, unchanged 17 g/34 g recipe parameters, boundary rejection at 0/20 without clamping, absent calibration, balanced repeat and explicit revisioned acceptance. A stale recipe or brew cannot accept old advice; generating advice changes neither recipes nor stock.

Water tests cover explicit nulls, 280 versus 250 → 30 mg/L, manufacturer precedence, target-only alkalinity without a pass band, unknown hardness and immutable saved brew water snapshots after profile editing. Historical guidance is previewed before creation and is labelled “Literaturprofil (2018), keine Maschinenfreigabe”. Saved selection is explicit; no hardness, alkalinity, mineral dose, potability or corrosion diagnosis is inferred.

UC1–UC6 run in the combined browser suite. UC6 covers measurement creation/edit, literature preview, selected comparison, explicit research query preview (zero requests before Start), query privacy, research failure/retry, separate conflicting candidates, no automatic profile changes, explicit source/value acceptance and revision conflict, taste preview/acceptance, durable drafts and local storage failure/retry/export. Existing browser tests cover atomic/cross-tab operations, five-minute timer return/reload, offline timers, full-data search, pagination, keyboard/focus and shared navigation.

The server adapter accepts only the enumerated profile query fields. Search and page fetching run server-side; there are no browser credentials or exported credentials. DNS answers must all be public; the selected answer is pinned into HTTPS connection lookup. Every redirect is revalidated. Tests reject private/local/IP-literal destinations, credentials in URLs, non-HTTPS, mixed DNS, redirect loops, bodies above 2 MiB (UTF-8 bytes) and aborted/deadline-bound work, including DNS. Public page retrieval precedes extraction. Script/style content is stripped, rendered content is escaped data, and candidates only contain whitelisted fields. Requests share a 15-second deadline and bounded request bodies. Failure changes no collection data. Network tests use deterministic adapters; no live search-provider availability is claimed.

JSON roundtrip tests include every implemented array, balances and brew/equipment/water snapshots, maintenance completions/baselines, sources and recommendations. Imported source verification is intentionally reset to unverified and requires opening/review; this explicit trust reset is the only provenance change on import. Sources remain stored when older than 180 days; exactly 180 days is current and 181 is stale.

New screen types were captured and visually inspected at 1280 and 390 px: water list/create/detail/edit, taste advice, research preview/candidates and provenance. Both shared themes and reduced motion run in screenshot tests. Further captures/checks use 1440×900 and 720 px (200% equivalent reflow); existing tests cover 390×844, 3 px keyboard focus, reachable controls and no page-wide horizontal scroll. Shared tokens/components supply all visual values; no story stylesheet was introduced. Screenshot artifacts are under `test-results/s6/` and are not committed.

The declared suite benchmarks 100 filtering operations and 100 local settings saves with 10,000 brews and 1,000 bags, extended with water/source/recommendation records. Both p95 limits are asserted ≤500 ms. Final measured save p95: **77.4 ms**; filter p95: **0.4 ms**. Both passed.

### Named-browser acceptance — INCOMPLETE

| Required pinned browser | Actual result |
| --- | --- |
| Full Chrome 156.0.8078.48 | INCOMPLETE — unavailable |
| Firefox 158.0.1 (15826.10.19) | INCOMPLETE — unavailable |
| macOS Safari 27.0 (21625.1.29.18.28) | INCOMPLETE — unavailable |

Bundled Chromium results and equivalent-width reflow do not substitute for these browsers or their native 200% zoom runs. Full section 7 acceptance remains incomplete until that named-browser matrix is executed.

### Assumptions and implementation choices

- Measurement units are fixed and visible per field: mg/L, mg/L als CaCO₃ and unitless pH. Blank optional values remain null. Manufacturer water limits override only the corresponding explicitly supplied fields.
- Research uses a credential-free public search adapter and conservative extraction of explicitly stated numeric values/ranges. Ambiguous pages yield no proposal and offer retry/manual entry. Exact manufacturer/roaster matches sort before labelled expert fallbacks; conflicting candidates remain independent. The Vite server registers the same-origin server adapter; static-file-only hosting must provide this endpoint separately.
- Taste advice is available on saved brew detail after review, so its triggering measurements are durable. Acceptance updates the referenced recipe with revision validation, or creates an experiment recipe from the saved snapshot if no recipe was selected. Other recipe parameters and historical brews stay unchanged.

### Independent review revision 1

All three findings were fixed and regression-tested. Numeric grind advice now explicitly requires a finite saved numeric setting, a stepped scale with an exact min+n×step grid, matching grinder/calibration and a known finer direction; invalid or missing settings produce a textual experiment. Target-only alkalinity comparisons remain target-only for values below, at and above 40, including target objects with omitted optional bounds. Explicit manufacturer bounds remain authoritative; no pass band is invented from a target.

The research adapter rejects IPv4 special-use CIDRs including documentation (192.0.2/24, 198.51.100/24, 203.0.113/24), benchmarking (198.18/15), reserved, private, loopback, link-local, shared and multicast ranges. IPv4-mapped IPv6 is expanded and its embedded IPv4 is checked with the same policy, for dotted and hexadecimal forms. Tests cover DNS and redirect rejection before a second request, plus public boundary neighbours. Special-use networks are denied conservatively, including the entire 192.0.0/24 block.

Re-ran the declared commands verbatim: 64 unit tests PASS, 73 Playwright scenarios PASS (1.6 min), lint PASS. Benchmark with 100 operations, 10,000 brews and 1,000 bags: save p95 71.2 ms, filter p95 0.4 ms. Named-browser acceptance remains INCOMPLETE as documented above. These fixes change domain validation and server address policy; existing responsive screen inspections remain applicable.

### Independent review revision 2

Research retrieval now always returns unverified sources (`status: stale`, `reviewedAt: null`, using the existing schema), even if a response claims verification. Fetching and preview remain free of collection mutations. Assumption: the first explicit “Quelle öffnen” persists the source as unverified without changing any profile values. The user must then choose “Geprüft bestätigen”; only that command sets verification and the review timestamp. “Übernehmen” stays disabled until this separate review completes, and its transaction requires an opened, persisted, verified source. Acceptance only links that source and saves values with revision validation; it does not create verification, change the review timestamp or append a second source.

Regression tests prove that direct acceptance before opening, after opening without confirmation, and after backup/import trust reset rejects without changing the profile. Existing imported-source opening/review remains mandatory. Conflicting candidates each need their own review. Browser tests open a source page, verify unverified persistence, confirm review, then accept; candidate/reviewed states were captured and visually inspected at 1280 and 390 px, with further reflow checks at 1440 and 720 px.

Declared commands rerun verbatim: 65 unit tests PASS, 73 Playwright scenarios PASS (1.9 min), lint PASS. Latest benchmark: save p95 77.4 ms, filter p95 0.4 ms. Named Chrome/Firefox/Safari acceptance remains INCOMPLETE as documented above.
