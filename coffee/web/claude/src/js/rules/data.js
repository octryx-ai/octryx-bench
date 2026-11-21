// Thresholds and tables for the rules in SPEC 4.2, 4.6, 4.7, 4.9. Edit data here, not logic.

// 4.2: offsets (s) around the configured [min, max] window, and the colour status of each class.
export const TIME_CLASSES = {
  marginS: 5,
  status: { too_fast: 'error', fast: 'warn', in_range: 'ok', slow: 'warn', too_slow: 'error' },
};

// 4.6: each entry lists advice steps; `when` is an optional condition on the shot.
// Step keys are i18n keys; `{setting}` etc. are filled from the computed params.
export const TASTE_RULES = {
  'espresso.sour': [
    { key: 'rec.grindFiner' },
    { key: 'rec.tempUp', when: { timeAtLeast: 'min' }, params: { tempC: 1 } },
  ],
  'espresso.bitter': [
    { key: 'rec.grindCoarser' },
    { key: 'rec.tempDown', when: { timeAtMost: 'max' }, params: { tempC: 1 } },
  ],
  'espresso.weak': [{ key: 'rec.weakEspresso', params: { yieldG: 2, doseG: 0.5 } }],
  'espresso.harsh_astringent': [
    { key: 'rec.stopEarlier', params: { yieldG: 2 } },
    { key: 'rec.grindCoarser', when: { timeAbove: 'max' } },
  ],
  'filter.sour': [{ key: 'rec.sourFilter', grind: 'finer', params: { tempC: 1 } }],
  'filter.bitter': [{ key: 'rec.bitterFilter', grind: 'coarser', params: { tempC: 1 } }],
  'filter.weak': [{ key: 'rec.weakFilter', ratioDelta: -1 }],
  'filter.harsh_astringent': [{ key: 'rec.harshFilter', grind: 'coarser', params: { tempC: 1 } }],
};
export const KEEP_KEY = 'rec.keep';

// Time-class override: grind advice that takes priority (unless the taste contradicts it).
export const TIME_PRIORITY = {
  too_fast: { unlessTaste: 'bitter', key: 'rec.grindFinerFast', grind: 'finer' },
  too_slow: { unlessTaste: 'sour', key: 'rec.grindCoarserSlow', grind: 'coarser' },
};

// 4.7: minimum rest days by roast level and method; peak window end in days after roast.
export const REST_DAYS = {
  dark: { filter: 1, espresso: 3 },
  medium: { filter: 3, espresso: 7 },
  light: { filter: 7, espresso: 10 },
};
export const PEAK_END_DAYS = 21;

// 4.9: ok ranges per water field (inclusive). Messages are i18n keys water.<field>.<low|high>.
export const WATER_RANGES = {
  tdsMgL: { min: 75, max: 250, target: 150 },
  hardnessPpm: { min: 50, max: 175, target: 68 },
  alkalinityPpm: { min: 40, max: 70, target: 40 },
  ph: { min: 6.5, max: 7.5, target: 7 },
  chlorineMgL: { min: 0, max: 0, target: 0 },
};

// 4.3: filter water stages. Remaining water after the bloom is split into `pours` equal pours; targets rounded to `decimals`.
export const FILTER_STAGES = { defaultRatio: 16, defaultBloomFactor: 2, pours: 2, decimals: 1 };
