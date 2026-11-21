# Coffee Companion – Specification (COF-24)

Status: draft 1. Product: web app (first version) for coffee enthusiasts. Primary language of the UI: German (`de`), second language English (`en`).

## 1 Goal and scope

**Goal.** One place where a coffee lover records every brew (machine, grinder and its setting, dose, yield, shot time, water, taste) and gets guidance to maximise enjoyment: dial-in advice from taste feedback, cleaning intervals derived from shot time, grinder dead-volume (Totraum) purge advice, bean inventory with reorder hints, resting time of freshly roasted beans, and step-by-step guidance for filter coffee (how many grams of water at which point).

**In scope (v1, web app).**
- Several machines and several grinders (at least 4 grinders of different types) per user.
- Beans from several roasters; several bags of the same bean.
- Brew log for espresso and filter coffee, including shot timer.
- Grinder settings and grinder retention (dead volume).
- Cleaning intervals from accumulated shot time.
- Bean inventory, rest-period check, reorder hints.
- Water values and evaluation against the SCA water targets.
- Taste feedback and improvement recommendation.
- Guided filter brew (focus mode).
- Research: the recommendation rules in section 4 are based on web research (see Sources); each rule table is data, so it can be updated without code change.

**Out of scope (v1).** Native mobile apps, multi-user sharing, shop integration (orders are hints only, nothing is ordered), hardware/scale/Bluetooth integration, cold brew and other methods than espresso and filter.

## 2 Users and use cases

Persona: one home coffee enthusiast, single user, single browser profile (data local, see 7).

| ID | Use case |
|----|----------|
| U1 | Register machines, grinders, roasters, beans, bags, water profiles. |
| U2 | Log an espresso shot: machine, grinder + setting, bean bag, dose g, yield g, time s, water, taste. |
| U3 | Run the shot timer (start/stop) while brewing and take the time over into the log. |
| U4 | After entering taste, read a recommendation what to change next. |
| U5 | See which cleaning tasks are due per machine/grinder and mark them done. |
| U6 | Before the first shot after a pause or bean change, read the purge amount for the grinder dead volume. |
| U7 | See stock per bean, whether a bag is already rested, and when/how much to reorder. |
| U8 | Enter water values and see whether they are within the target range. |
| U9 | Run a guided filter brew: enter coffee dose, get water grams per stage. |

## 3 Domain model

All ids are UUID v4 strings. Weights in grams (g), time in seconds (s), temperature in °C, dates as ISO 8601 (`YYYY-MM-DD`), timestamps ISO 8601 UTC.

- **Machine**: `id`, `name` (1–60 chars, required), `type` (`espresso` | `filter`), `lastBackflushAt`, `lastDescaleAt`, `lastDeepCleanAt` (nullable timestamps), `shotSecondsSinceBackflush` (number ≥ 0, derived, see 4.4), `archived` (boolean, default false).
- **Grinder**: `id`, `name` (required), `type` (`stepped` = electric grinder with discrete steps, `stepless` = continuous dial, `numbered` = dial with numbers, `hand` = hand grinder counted in clicks), `settingUnit` (text, e.g. `Klicks`, `Zahl`, `Umdrehungen`), `stepSize` (number > 0 = one "step" in the recommendations of 4.6; defaults: `stepped` 1, `hand` 1 click, `numbered` 1 number, `stepless` 5 % of the range = 0.05 × (`rangeMax` − `rangeMin`)), `rangeMin`/`rangeMax` (stepless only, numbers, defaults 0 and 10, so default stepSize 0.5), `higherIsFiner` (boolean, default false: whether a higher setting number means a finer grind; used by 4.6), `retentionG` (dead volume, number 0–5, 0.1 steps, default 0.5), `gramsSinceClean` (≥ 0, derived), `lastCleanAt`, `lastUsedAt`, `lastBeanId` (nullable), `archived` (boolean, default false).
- **Roaster**: `id`, `name` (required), `url` (optional), `leadTimeDays` (integer 0–30, default 3: days from order until delivery).
- **Bean**: `id`, `roasterId`, `name` (required), `origin` (text, optional), `roastLevel` (`light` | `medium` | `dark`), `notes`, `archived` (boolean, default false).
- **Bag**: `id`, `beanId`, `roastDate` (date, required), `weightG` (initial, number > 0), `remainingG` (0 ≤ x ≤ weightG), `price` (optional, EUR, 2 decimals), `openedOn` (optional).
- **WaterProfile**: `id`, `name`, `tdsMgL`, `hardnessPpm` (total hardness as CaCO₃), `alkalinityPpm` (as CaCO₃), `ph`, `chlorineMgL` (all optional numbers ≥ 0; pH 0–14).
- **Brew**: `id`, `createdAt`, `method` (`espresso` | `filter`), `machineId`, `grinderId`, `grinderSetting` (number ≥ 0, decimals allowed for stepless), `bagId`, `waterId` (optional), `doseG` (1–60), `yieldG` (espresso, 1–200, outputs g in cup), `waterG` (filter, 1–2000), `timeS` (0–600, shot or total brew time), `tempC` (optional, 80–100), `taste` (see 4.6; optional), `purgeG` (number ≥ 0, computed by 4.5 and stored at save time, so the bag deduction can be recomputed and shown later), `favourite` (boolean, default false; shown as a filled star on the brew card and detail, and filterable with the "Favoriten" chip in the Brews filter bar), `notes`.
- **Settings**: `language` (`de`|`en`, default `de`), `theme` (`light`|`dark`|`system`, default `system`), `espressoTimeMinS` (default 25), `espressoTimeMaxS` (default 30), `backflushSeconds` (default 1500), `backflushDays` (default 7), `grinderCleanG` (default 5000), `descaleBaseDays` (default 90), `hardnessTargetPpm` (default 68), `filterRatio` (default 16), `plannedShotsPerDay` (default 2), `targetCoverDays` (default 28), `idlePurgeHours` (default 24), `bloomFactor` (default 2).

## 4 Rules and formulas

### 4.1 Espresso ratio
`ratio = yieldG / doseG` (shown as `1:x`, x = ratio rounded to 1 decimal). Default recipe 18 g in → 36 g out in 25–30 s (ratio 1:2). Example: 18 g → 36 g gives 36/18 = 2.0 → `1:2.0`; 17 g → 34.0 g gives 34/17 = 2.0.

### 4.2 Time classification of an espresso shot
With `min = espressoTimeMinS` (25) and `max = espressoTimeMaxS` (30):
- `timeS < min − 5` (20) → `too_fast` (grind probably too coarse).
- `min − 5 ≤ timeS < min` → `fast`.
- `min ≤ timeS ≤ max` → `in_range`.
- `max < timeS ≤ max + 5` (35) → `slow`.
- `timeS > max + 5` → `too_slow` (grind probably too fine).
Colour of the class (chips, bottom bar of brew cards): `in_range` = ok; `fast`, `slow` = warn; `too_fast`, `too_slow` = error.
Example: 19 s → `too_fast`; 27 s → `in_range`; 33 s → `slow`; 36 s → `too_slow`. With max set to 32: 31 s → `in_range`, 38 s → `too_slow`.

### 4.3 Filter water amount and stages
`totalWaterG = doseG × filterRatio` (default 16, allowed 14–18). 1:16 equals 1000/16 = 62.5 g coffee per litre.
Stages: bloom `bloomG = doseG × bloomFactor` (default 2); remaining water `totalWaterG − bloomG` is split into 2 equal pours. Cumulative scale targets: bloom, bloom + pour 1, total.
Example: 30 g coffee, ratio 16 → total 480 g; bloom 60 g (cumulative 60); remaining 420 g → 2 × 210 g; cumulative targets 60 g → 270 g → 480 g.

### 4.4 Cleaning intervals from shot time
Each logged brew adds `timeS` to the machine's `shotSecondsSinceBackflush`, and `doseG` to the grinder's `gramsSinceClean`.
- Backflush/group-head clean due when `shotSecondsSinceBackflush ≥ backflushSeconds` (1500 = 50 shots × 30 s) or `backflushDays` (7) days since `lastBackflushAt`, whichever first.
- Descale due after `descaleDays = clamp(round(descaleBaseDays × hardnessTargetPpm / max(hardnessPpm, 17)), 14, 180)` days since `lastDescaleAt` (defaults 90 and 68; 68 ppm is the SCA hardness target; hardness taken from the water profile of the machine's last brew; without one: `descaleBaseDays`).
- Grinder brush/clean due when `gramsSinceClean ≥ grinderCleanG` (5000).
- Null start values (new machine or grinder): `lastBackflushAt = null` and no shot yet → backflush not due until a threshold is reached, counting days from the item's creation date; `lastDescaleAt = null` → descale counted from creation date; `lastCleanAt = null` → counted by grams only.
- Task → counter reset by the button "Erledigt": backflush resets `shotSecondsSinceBackflush` to 0 and sets `lastBackflushAt = now`; grinder clean resets `gramsSinceClean` to 0 and sets `lastCleanAt = now`; descale only sets `lastDescaleAt = now`. Each task has its own button.
- Overdue ratio (for sorting in Pflege and Heute): backflush `max(shotSeconds / backflushSeconds, daysSince / backflushDays)`; descale `daysSince / descaleDays`; grinder `gramsSinceClean / grinderCleanG`. Due when ratio ≥ 1; sorted by ratio descending. Example: 1512/1500 = 1.008; descale 30 of 45 days = 0.667; 4000/5000 = 0.8 → order backflush, grinder, descale (only the first is due).
Examples: with 28 s shots, 53 shots = 1484 s (not due), 54 shots = 1512 s → due at shot 54. Hardness 136 ppm → 90 × 68 / 136 = 45 days. Hardness 17 ppm → 90 × 68 / 17 = 360 → clamped to 180.
Note: the numeric intervals are app defaults chosen by the product (no authoritative source found); all five constants are Settings fields (section 3) and editable.

### 4.5 Grinder dead volume (Totraum) purge
Dead volume = coffee remaining in the grinder (`retentionG`), measured by the user.
- If `lastUsedAt` or `lastBeanId` is null (first use of the grinder): `purgeG = 0`.
- Else if the bean changed since `lastBeanId`: `purgeG = 2 × retentionG`.
- Else if hours since `lastUsedAt ≥ idlePurgeHours (24)`: `purgeG = retentionG`.
- Else `purgeG = 0`.
`purgeG` is computed when the brew is saved and stored in `Brew.purgeG`; saving also sets the grinder's `lastUsedAt`, `lastBeanId`.
Advice: grind and discard `purgeG` first, then grind the dose. Total to grind = `doseG + purgeG`.
Example: dose 17 g, retention 0.6 g, last use 30 h ago, same bean → purge 0.6 g, grind 17.6 g in total. Bean changed → purge 1.2 g, total 18.2 g. Last use 5 h ago → purge 0 g, total 17 g.
Stock accounting: purged grams are subtracted from the bag too (`remainingG −= doseG + purgeG`).

### 4.6 Taste feedback and recommendation
Taste values: `sour`, `bitter`, `weak`, `harsh_astringent`, `balanced`. Combined with the time class (4.2) for espresso, change **one variable at a time**:

| Taste | Condition | Recommendation |
|-------|-----------|----------------|
| sour | espresso | Grind 1 `stepSize` finer (3, Grinder: 1 step/click/number, or 5 % of the range for stepless); keep ratio; if time already ≥ 25 s and still sour: raise temperature by 1 °C (≈ 2 °F) |
| bitter | espresso | Grind 1 step coarser; if time already ≤ 30 s and still bitter: lower temperature by 1 °C |
| weak | espresso | Keep time; reduce yield by 2 g (shorter ratio), or increase dose by 0.5 g |
| harsh_astringent | espresso | Stop the shot earlier (yield −2 g), then grind coarser if time > 30 s |
| sour | filter | Grind 1 step finer or raise water temperature 1 °C |
| bitter | filter | Grind 1 step coarser or lower water temperature 1 °C |
| weak | filter | Lower filterRatio by 1 (e.g. 16 → 15) |
| harsh_astringent | filter | Grind 1 step coarser or lower water temperature 1 °C |
| balanced | any | "Keep this recipe" and a button "Als Favorit markieren" / "Mark as favourite" that sets `Brew.favourite = true` |

"1 step" always means the grinder's `stepSize`; the advice names the target setting, e.g. setting 12 with stepSize 1 → "Setting 11" (finer = lower number unless `higherIsFiner`; the grinder form has the checkbox "Höhere Zahl = feiner" / "Higher number = finer"). Example: setting 12, stepSize 1, `higherIsFiner` false, taste sour → "Setting 11"; stepless 0–10, setting 4, stepSize 0.5, sour → "Setting 3.5".

If the time class is `too_fast` and taste is not `bitter`, the grind-finer advice takes priority; if `too_slow` and taste is not `sour`, grind-coarser takes priority. Example: espresso 18 g → 36 g in 19 s, taste `sour` → "Grind 1 step finer (shot too fast, 19 s < 20 s)". Example: espresso 33 s, taste `bitter` → "Grind 1 step coarser". Most espresso is dialled in within 3–7 shots; the UI shows the shot number = count of saved espresso brews with the same bean (via bag) and the same grinder, including the one being edited (example: 2 earlier + this one = "Shot 3").

### 4.7 Rest period (beans cannot be used freshly roasted)
`daysSinceRoast = today − roastDate` (whole days). `minRestDays` by method and roast level (app table, informed by sources: dark 1–3, medium 2–7, light 7–14 days; espresso needs more; the table gives 3 to 10 days for espresso by roast level):

| Roast level | filter | espresso |
|-------------|--------|----------|
| dark | 1 | 3 |
| medium | 3 | 7 |
| light | 7 | 10 |

`readyOn = roastDate + minRestDays`. Status per bag: `resting` if `daysSinceRoast < minRestDays`, `ready` if `minRestDays ≤ daysSinceRoast ≤ 21`, `past_peak` if > 21 (hint only, bag stays usable). A `resting` bag shows "ready on <date>" and is disabled in the bag picker of the brew form, with no override (decision: one behaviour; the user waits or logs with another bag).
Example: roast 2026-11-10, medium, espresso: readyOn = 2026-11-17; on 2026-11-16 daysSinceRoast = 6 → `resting`, 1 day to go. Peak window ends 2026-12-01 (roast + 21).

### 4.8 Inventory and reorder hints
- `stockG(bean) = Σ remainingG` of all bags of that bean; `usableStockG` = only `ready` and `past_peak` bags.
- `shotsLeft = floor(usableStockG / doseG)` using the last used dose of that bean; purge is excluded (the example uses purge 0).
- `dailyUseG` = grams (dose + purge) logged for the bean in the last 14 days ÷ 14; if fewer than 3 distinct brew days exist: `plannedShotsPerDay × last dose`.
- `coverDays = usableStockG / dailyUseG` (rounded down).
- `reorderPointG = dailyUseG × (roaster.leadTimeDays + minRestDays)` – a new bag arrives after the lead time and must still rest.
- Hint "order now" when `usableStockG ≤ reorderPointG` and the bean has no `resting` bag (a resting bag counts as already ordered). Suggested quantity: `bags = max(0, ceil((targetCoverDays × dailyUseG − stockG) / bagWeightG))`, using `stockG` (all bags), with `bagWeightG` = `weightG` of the bag of that bean with the newest `roastDate`. A result of 0 (negative before max) shows no quantity and no hint.
Example: bag 250 g, dose 17 g → shotsLeft = floor(250/17) = 14 (238 g used, 12 g left). Daily use 2 × 17 = 34 g/day → coverDays = floor(250/34) = 7. Lead time 3 d + espresso/medium rest 7 d → reorderPoint = 34 × 10 = 340 g; 250 ≤ 340 → "order now". Quantity: 28 × 34 = 952 g; 952 − 250 = 702; 702/250 = 2.81 → 3 bags.

### 4.9 Water evaluation
Per value a status `ok` / `warn` / `none`: a value not entered (null) has status `none` (neutral chip "–"); a value outside its ok range is `warn` (TDS, hardness, alkalinity, pH alike): TDS target 150 mg/L (ok 75–250); total hardness ok 50–175 ppm (target 68); alkalinity ok 40–70 ppm (target 40); pH ok 6.5–7.5 (target 7.0); chlorine ok = 0 (warn > 0). Sources differ on hardness and alkalinity ranges (see Decisions), values are editable data.
Example: TDS 120, hardness 136, alkalinity 90, pH 7.2 → TDS ok, hardness ok, alkalinity warn (90 > 70), pH ok. Message for alkalinity warn: "Too high: risk of flat, chalky taste and scale".

## 5 Defaults, limits, ordering, empty and error cases

- Defaults: see Settings in section 3. Newly created grinder retention 0.5 g.
- Ordering: brew log newest first (`createdAt` desc); beans by name A–Z; bags by `roastDate` oldest first (use oldest ready bag first, "first in, first out"); cleaning tasks by overdue ratio desc (4.4).
- Empty data: no machine/grinder/bag yet → each list shows an illustrated empty state with one button ("Maschine hinzufügen", etc.); brew form without bag says "Lege zuerst eine Bohnen-Packung an" with link. No recommendation is shown without a taste entry.
- Validation errors (inline, below the field, red, text de / en): doseG outside 1–60 ("Dosis muss zwischen 1 und 60 g liegen" / "Dose must be between 1 and 60 g"), yieldG outside 1–200 ("Ausbeute muss zwischen 1 und 200 g liegen" / "Yield must be between 1 and 200 g"), timeS outside 0–600 ("Zeit muss zwischen 0 und 600 s liegen" / "Time must be between 0 and 600 s"), `remainingG > weightG` ("Restmenge darf das Packungsgewicht nicht überschreiten" / "Remaining amount must not exceed the bag weight"), roastDate in the future ("Röstdatum darf nicht in der Zukunft liegen" / "Roast date must not be in the future"), name empty/over 60 chars ("Name: 1–60 Zeichen" / "Name: 1–60 characters"). Saving is blocked until fixed.
- Brew consuming more than `remainingG` → warning "Packung hat nur noch X g" / "Bag has only X g left", remaining is set to 0, brew is still saved.
- Division by zero guarded: `dailyUseG = 0` → coverDays shown as "–", no reorder hint.
- Deleting a machine/grinder/bean that is referenced by brews: blocked with message "N Brews verwenden dieses Gerät" / "N brews use this item"; the dialog offers the button "Archivieren" / "Archive" (also in the card menu "⋯" of Geräte and Bohnen, with "Wiederherstellen" / "Restore"). Archived items are hidden from the pickers of forms and from the default lists (switch "Archivierte anzeigen" / "Show archived"); brews that reference them still display them. Bags are deleted only when `remainingG = 0` or unreferenced.

## 6 Interfaces and formats

Web app, single page, client-side only in v1 (no backend).
- **Storage**: browser `localStorage` key `coffee.v1`, JSON `{ "version": 1, "machines": [], "grinders": [], "roasters": [], "beans": [], "bags": [], "waters": [], "brews": [], "settings": {} }` with the fields of section 3.
- **Export/Import**: button "Daten exportieren" downloads `coffee-export-YYYY-MM-DD.json` (same JSON); import validates `version == 1` and replaces data after confirmation; invalid file → error "Ungültige Datei".
- **Number format**: shown per language (`de`: `18,0 g`, `en`: `18.0 g`); stored with `.`.
- **Shot timer**: button Start/Stop, display `mm:ss.s`; Stop copies `timeS` (1 decimal) to the form.
- **Routes** (hash routing): `#/` Heute, `#/brews`, `#/brews/new`, `#/brews/:id`, `#/guided`, `#/beans`, `#/equipment`, `#/water`, `#/care`, `#/settings`.
- **Rule data** (sections 4.2, 4.6, 4.7, 4.9) lives in one module `rules` so it can be unit-tested with the worked examples above.

## 7 Non-functional requirements

- Initial load ≤ 2 s on a 4G profile; any list of 500 brews renders in ≤ 200 ms; recommendation computed in ≤ 50 ms.
- Offline-capable after first load (no network needed for core functions).
- Accessibility: WCAG 2.2 AA – text contrast ≥ 4.5:1 (large text ≥ 3:1), visible focus ring 2 px, all actions keyboard operable, touch targets ≥ 44 × 44 px, shot timer announces state via `aria-live="polite"`.
- Browsers: current and previous major version of Chrome, Firefox, Safari, Edge.
- Privacy: no data leaves the browser; no tracking.
- Languages: `de` and `en` complete; no mixed-language screens.
- Tests: unit tests for every worked example in section 4; Playwright system test for the log-a-shot flow (create grinder, bean, bag, log shot, see recommendation).

## UI and design

**Direction: "Warm Crema"** – warm, calm, kitchen-counter feeling: cream backgrounds, espresso-brown text, caramel accent; cards with soft shadow; generous spacing for use with wet hands (large touch targets).

**Looks like.**
- *List screens (Brews, Beans, Equipment)*: a page title, one primary button top right, then a vertical stack (one column on phone, 2–3 columns of cards on desktop). Each card has a visual anchor on the left/top, about a third of the card, then name, key numbers and a status chip.
- *Detail/form (Brew, Bean, Machine)*: two-column form on desktop (inputs left, live preview of ratio and time class right), one column on phone; sticky save bar at the bottom.
- *Focus mode (Guided filter brew, shot timer)*: full-screen, one big number (target grams or time) at about 25 % of the viewport height, one big button, minimal chrome, dimmed background.

**Design tokens** (intent = guide the build may refine; exact = fixed).

| Token | Light | Dark | Kind |
|-------|-------|------|------|
| `--bg` page | #FBF5EC | #1E1713 | intent |
| `--surface` card | #FFFFFF | #2A211B | intent |
| `--text` | #2B1D14 | #F3E9DC | exact (contrast ≥ 4.5:1 on bg) |
| `--text-muted` | #6B5646 | #BFAE9E | exact (≥ 4.5:1) |
| `--accent` (primary action) | #8A4B1F | #E0A06A | exact (text on accent ≥ 4.5:1) |
| `--ok` | #2F7D4F | #6CC48E | intent |
| `--warn` | #A35F00 | #F2B24D | intent |
| `--error` | #B3261E | #FF8A80 | intent |
| focus ring | 2 px solid #1A5FB4 (dark: #8AB4F8), offset 2 px | | exact |

Fonts: headings "Fraunces", serif fallback Georgia; body/UI "Inter", fallback system-ui; numbers use tabular figures. Type scale (intent): 12 / 14 / 16 / 20 / 24 / 32 / 64 px (64 only for focus-mode number). Spacing scale (intent): 4, 8, 12, 16, 24, 32, 48 px. Radius: 8 px controls, 16 px cards, 999 px chips (intent). Shadow: `0 2px 8px rgba(43,29,20,.12)` light, none + 1 px border in dark (intent). Breakpoints (intent): phone < 600 px, tablet 600–1023 px, desktop ≥ 1024 px.

**Drawn elements.**
- *Bean/bag card anchor*: a rectangle with a linear gradient 135° from hue H (lightness 78 %, saturation 45 %) to hue H+25° (lightness 58 %), where `H = 15 + (sum of char codes of the roaster name mod 45)` (warm range 15–59). Hue collisions between different roasters are accepted (1 in 45 chance per pair); cards of the same roaster share the hue, and the roast-level bean icon plus the bean name tell them apart. Centered coffee-bean icon, 48 px, colour `--text` (#2B1D14) in the light theme (≥ 3:1 on the 78 %/58 % gradient) and #FFFFFF in the dark theme (≥ 3:1 on the 38 %/28 % gradient); the roast level shows as bean fill (light = 1 bean outline, medium = half filled, dark = filled). Dark theme: lightness 38 % / 28 %.
- *Brew card anchor*: same gradient from the bean; icon by method: espresso cup (small cup with crema ellipse) or filter cone (V60). For filter brews the card shows `30,0 g → 480 g · 1:16,0 · 03:30` (dose → water · ratio · mm:ss). A thin 4 px bar along the bottom shows the time class colour (ok/warn/error).
- *Machine/grinder card anchor*: flat tinted square (accent at 12 % opacity) with machine icon (portafilter for `espresso` machines, V60 cone for `filter` machines) or grinder icon (burr for electric types, crank handle for `hand`), 48 px.
- *Empty-state illustration*: line drawing, 96 px, 2 px stroke in `--text-muted`, above a headline and one button: empty cup (brews), bean bag (beans), portafilter (equipment), water drop (water), sparkle brush (care: "Alles sauber").
- *Rest chip on bag*: `resting` chip background `--accent` with hourglass icon and text "Bereit am 17.11." / "Ready 17 Nov"; `ready` chip background `--ok` with check icon; `past_peak` chip background `--warn` with clock icon (chip text white, ≥ 4.5:1).

**Component catalogue** (all states; themes = token overrides of the table above).
- *Button primary/secondary/ghost*: default; hover (+8 % darker); focus (ring); pressed; disabled (40 % opacity, no pointer); loading (spinner replaces label).
- *Input / number stepper*: default, focus, filled, error (red border + message), disabled; unit shown as suffix.
- *Card*: default, hover (shadow lifts), selected (2 px accent border), loading (skeleton shimmer), empty (see above), error ("Konnte nicht geladen werden" + retry).
- *Chip*: ok, warn, error, neutral.
- *Recommendation panel*: info icon, headline, 1–3 bullet steps; states: none (hidden), shown, "keep this recipe" (green).
- *Timer*: idle `00:00.0`, running (accent pulse), stopped (value highlighted).
- *Toast*: success/error, 4 s auto-dismiss.

**App shell and navigation map.** Desktop: left side bar 240 px with logo and items Heute, Brews, Bohnen, Geräte, Wasser, Pflege, Einstellungen (en: Today, Brews, Beans, Devices, Water, Care, Settings; phone tab "Mehr" = "More"); page content max-width 1100 px; side bar and page fill the viewport height (`min-height: 100vh`). Tablet (600–1023 px): side bar collapsed to a 72 px icon rail (labels as tooltips), card lists 2 columns, forms 1 column with the live preview below the inputs. Phone (< 600 px): side bar becomes a bottom tab bar with 5 tabs (Heute, Brews, Bohnen, Geräte, Mehr); "Mehr" opens Wasser, Pflege, Einstellungen. A floating "+" button (phone) / primary button (desktop) opens `#/brews/new` from any screen.

| Screen | Reached via (desktop / phone) |
|--------|-------------------------------|
| Heute (dashboard) | side bar "Heute" / tab "Heute" |
| Brews (list) | side bar / tab |
| Brew form `#/brews/new`, detail `#/brews/:id` | "+ Neuer Brew" button, card tap |
| Guided filter brew `#/guided` | Heute card "Filterkaffee starten", Brew form method filter |
| Bohnen (beans, bags, order hints) | side bar / tab |
| Geräte (machines + grinders) | side bar / tab |
| Wasser | side bar / Mehr |
| Pflege (cleaning) | side bar / Mehr |
| Einstellungen | side bar / Mehr |

**Per screen composition** (texts de / en).

1. *Heute*: regions top to bottom: greeting + primary button "Neuer Brew" / "New brew"; row "Fällig" / "Due" (due cleaning tasks, chips); row "Bohnen" / "Beans" (beans needing order, resting bags with ready date); last 3 brews. A row without content is hidden together with its heading; if all rows are empty only the empty text below is shown. Primary action: new brew. Secondary: start filter brew, mark cleaning done. Empty: "Noch kein Brew – starte mit deinem ersten Shot." / "No brew yet – start with your first shot."
2. *Brews list*: filter bar (method, grinder, bean, chip "Favoriten" / "Favourites"), cards newest first; card shows bean, `18,0 g → 36,0 g · 1:2,0 · 27 s`, setting, taste chip. Tap opens detail. Empty state: cup illustration, "Noch keine Brews" / "No brews yet", button "Ersten Brew erfassen" / "Log first brew".
3. *Brew form*: fields in order: method (segmented espresso/filter), machine, grinder, grinder setting, bag (resting bags disabled with date), water, dose, yield (espresso) or water (filter), time with timer button, temperature, taste (5 chips), notes. Live preview: ratio, time class chip, purge advice box ("Vorher 0,6 g mahlen und verwerfen" / "Grind and discard 0.6 g first"), recommendation panel after taste chosen. Primary: "Speichern" / "Save"; secondary: "Abbrechen" / "Cancel". Errors per section 5.
4. *Guided filter brew (focus mode)*: step 1 dose input (default last dose) → step 2 big number "Bloom 60 g" with button "Weiter" / "Next" → "Gieße bis 270 g" → "Gieße bis 480 g" → "Fertig – Zeit eintragen" (en: "Bloom 60 g", "Pour to 270 g", "Pour to 480 g", "Done – enter time"). Shows running timer and the cumulative target; "Abbrechen" / "Cancel" top left. Mapping to the saved filter Brew (`method = filter`): dose input → `doseG`; final cumulative target → `waterG` (480); timer value at "Fertig" → `timeS`; machine, grinder, bag chosen in a pre-step (same pickers and resting-bag rule as the brew form); `yieldG` is empty for filter; ratio on the card = `waterG / doseG`. After saving, the Brew form opens for taste entry.
5. *Bohnen*: grouped by bean card (anchor, roaster, stock `250 g`, shots left, cover days, order chip "Jetzt bestellen · 3 Packungen" / "Order now · 3 bags"); expanding shows bags with rest chips. Primary: "Packung hinzufügen" / "Add bag"; secondary: "Bohne hinzufügen" / "Add bean", "Rösterei hinzufügen" / "Add roaster". Roaster add/edit form (dialog): `name` (required), `url` (optional, must start with http:// or https://), `leadTimeDays` (integer 0–30, default 3, label "Lieferzeit (Tage)" / "Lead time (days)"); roasters are listed in a "Röstereien" / "Roasters" section below the beans, each row with edit action. Empty: bean-bag illustration, "Noch keine Bohnen" / "No beans yet", one button "Bohne hinzufügen" / "Add bean".
6. *Geräte*: two tabs Maschinen / Mühlen; cards with name, type, due chips; grinder card shows retention `0,5 g`, setting unit. Primary: "Gerät hinzufügen" / "Add device". Form fields as in section 3 (grinder type picker with the 4 types; stepless shows range fields). Empty: portafilter illustration, "Noch keine Geräte" / "No devices yet", button "Gerät hinzufügen" / "Add device". Machines: at most 10 per user, grinders at most 10 per user.
7. *Wasser*: list of profiles with per-value status chips (4.9) and the target ranges beside inputs. Primary: "Wasserprofil hinzufügen". Empty: drop illustration.
8. *Pflege*: list of tasks per device, sorted by overdue ratio (4.4); each shows progress bar (`1512 / 1500 s`, `30 / 45 Tage`, `4000 / 5000 g`) and its own button "Erledigt" / "Done" with the reset per task type of 4.4. Empty (no devices): sparkle-brush illustration, "Alles sauber" / "All clean", one button "Gerät hinzufügen" / "Add device".
9. *Einstellungen*: language, theme, rule defaults (section 3 Settings), export/import, reset (confirm dialog). Primary: "Speichern".

### Look and feel

- LF1 All screens: page and side bar background fill the viewport down to the bottom, also on a short page (no white strip below).
- LF2 Brews list, Beans, Equipment: each card's anchor is a warm gradient with a bean/cup/machine icon; cards of the same roaster share a hue, different roasters usually differ (collisions accepted).
- LF3 Beans: every bag shows a rest chip with the ready date or "bereit"; resting chips have `--accent` background with an hourglass icon, ready chips `--ok` background with a check icon.
- LF4 All lists: no heading stands above an empty region; empty lists show the illustration, a sentence and one button.
- LF5 Brew form: the ratio, time-class chip, purge advice and recommendation update while typing; only one primary (filled caramel) button is visible.
- LF6 Guided filter brew: one number whose height is 22–28 % of the viewport height (at 800 px: 176–224 px), one button, no side bar.
- LF7 Every text, unit, date and number format is in the screen's language (e.g. `18,0 g` and `17.11.` in de; `18.0 g` in en); no mixed languages.
- LF8 Dark theme: text contrast ≥ 4.5:1, gradients darker (lightness 38 %/28 %), cards separated by 1 px border instead of shadow.
- LF9 Phone width 375 px: bottom tab bar with 5 tabs, no horizontal scroll, touch targets ≥ 44 px.
- LF10 Keyboard focus: a 2 px blue ring is visible on every interactive element.

## 8 Decisions

No product owner answers were supplied with the run contract yet; the following are defaults taken by the specification and not overruled:

1. Web app first, client-side with localStorage (section 6) – from the work item ("fürs erste eine web app").
2. Multiple grinders of the 4 types `stepped`, `stepless`, `numbered`, `hand` (max 10 per user) and multiple machines (max 10 per user) (3, Geräte).
3. Several roasters, several bags per bean (3, 4.8).
4. Rest period before use of freshly roasted beans, by roast level and method (4.7).
5. Cleaning intervals derived from accumulated shot time (4.4); numeric values are app defaults, not sourced.
6. Dead volume purge advice (4.5); factor 2 on bean change and 24 h idle threshold are app defaults.
7. Reorder hints include lead time and rest time (4.8).
8. Water evaluation per SCA targets; hardness 50–175 ppm and alkalinity 40–70 ppm chosen (as in the opened thirdwavewater page; other sources give 40–75) because sources disagree (4.9).
9. Taste recommendation by table (4.6); one variable at a time.
10. Filter default ratio 1:16 (4.3), bloom 2 × dose, 2 pours – bloom factor and pour count are app defaults.
11. UI languages: German primary, English second (7, UI).
12. Single user, no accounts (1, 7).

## 9 Open questions

None explicitly left open by the product owner. Points to confirm in the next round: which machine and grinder models (for model-specific cleaning intervals and grinder scales), preferred units for water hardness (ppm vs °dH), and whether bean orders should link to roaster shops.

## Sources

Research done with web search; pages marked * were opened in full, the others were used from search results only (not opened).
- https://www.moustachecoffeeclub.com/blog/day-of-roast-coffee * (rest days by roast level and method)
- https://simonandbearns.coffee/en/blogs/kaffeeblog/coffee-degassing-how-long-to-rest-filter-coffee-and-espresso (degassing)
- https://methodicalcoffee.com/blogs/coffee-culture/freshly-roasted-coffee-explained-degassing-rest-and-flavor (degassing)
- https://thirdwavewater.eu/blogs/news/what-is-sca-water-standard-complete-guide-to-coffee-brewing-water-quality (SCA water standard)
- https://www.pulled.coffee/blog/coffee-brewing-water (water: TDS, hardness; fetch failed, snippet only)
- https://coffeeroastco.com/blogs/coffee-roast-co-blog/best-water-for-coffee (water targets)
- https://coffeestudies.com/barista-skills/dialing-in-espresso (dial-in; fetch failed, snippet only)
- https://clivecoffee.com/blogs/learn/why-is-my-espresso-sour-or-bitter-how-to-fix-it-clive-coffee (sour/bitter fixes)
- https://masteringcoffee.com/how-to-dial-in-espresso/ (dial-in 1:2, 25–30 s)
- https://en.wikipedia.org/wiki/Coffee_extraction (extraction, brew ratio)
- https://lamose.com/blogs/recipes/coffee-to-water-ratio-guide-the-golden-numbers-for-every-method (filter ratio 1:16, g/L)
