import { TIME_CLASSES, TASTE_RULES, KEEP_KEY, TIME_PRIORITY, REST_DAYS, PEAK_END_DAYS, WATER_RANGES, FILTER_STAGES } from './data.js';

const DAY_MS = 86400000;
const round = (n, d = 2) => Math.round(n * 10 ** d) / 10 ** d;

// 4.2
export function classifyTime(timeS, { espressoTimeMinS: min = 25, espressoTimeMaxS: max = 30 } = {}) {
  const m = TIME_CLASSES.marginS;
  if (timeS < min - m) return 'too_fast';
  if (timeS < min) return 'fast';
  if (timeS <= max) return 'in_range';
  if (timeS <= max + m) return 'slow';
  return 'too_slow';
}

export const timeClassStatus = (cls) => TIME_CLASSES.status[cls];

// 4.6
function conditionHolds(when, timeS, { espressoTimeMinS: min = 25, espressoTimeMaxS: max = 30 }) {
  if (!when) return true;
  if (when.timeAtLeast) return timeS >= min;
  if (when.timeAtMost) return timeS <= max;
  if (when.timeAbove) return timeS > max;
  return true;
}

function targetSetting(grind, { setting, stepSize = 1, higherIsFiner = false }) {
  const up = (grind === 'finer') === higherIsFiner;
  return round(setting + (up ? stepSize : -stepSize));
}

/**
 * Returns { steps: [{key, params}], keep, favouriteOffer }.
 * brew: { method, taste, timeS, grinderSetting }; grinder: { stepSize, higherIsFiner }.
 */
export function recommend(brew, grinder = {}, settings = {}) {
  const { method, taste, timeS, grinderSetting } = brew;
  if (!taste) return { steps: [], keep: false, favouriteOffer: false };
  if (taste === 'balanced') return { steps: [{ key: KEEP_KEY, params: {} }], keep: true, favouriteOffer: true };

  const g = { setting: grinderSetting, ...grinder };
  const result = (steps) => ({ steps, keep: false, favouriteOffer: false });
  const min = settings.espressoTimeMinS ?? 25;
  const cls = method === 'espresso' ? classifyTime(timeS, settings) : null;

  const prio = TIME_PRIORITY[cls];
  if (prio && taste !== prio.unlessTaste) {
    const limit = prio.grind === 'finer' ? min - TIME_CLASSES.marginS : (settings.espressoTimeMaxS ?? 30) + TIME_CLASSES.marginS;
    return result([{ key: prio.key, params: { setting: targetSetting(prio.grind, g), timeS, limitS: limit } }]);
  }

  const rules = TASTE_RULES[`${method}.${taste}`] ?? [];
  const steps = [];
  for (const r of rules) {
    if (!conditionHolds(r.when, timeS, settings)) continue;
    const params = { ...r.params };
    const grind = r.grind ?? (r.key === 'rec.grindFiner' ? 'finer' : r.key === 'rec.grindCoarser' ? 'coarser' : null);
    if (grind) params.setting = targetSetting(grind, g);
    if (r.ratioDelta) {
      const from = settings.filterRatio ?? 16;
      Object.assign(params, { from, to: from + r.ratioDelta });
    }
    steps.push({ key: r.key, params });
  }
  return result(steps);
}

// 4.7
const toUtcDay = (iso) => {
  const [y, m, d] = String(iso).slice(0, 10).split('-').map(Number);
  return Date.UTC(y, m - 1, d);
};
const isoDay = (ms) => new Date(ms).toISOString().slice(0, 10);

export function restStatus({ roastDate, roastLevel, method }, today = isoDay(Date.now())) {
  const minRestDays = REST_DAYS[roastLevel][method];
  const daysSinceRoast = Math.round((toUtcDay(today) - toUtcDay(roastDate)) / DAY_MS);
  const status = daysSinceRoast < minRestDays ? 'resting' : daysSinceRoast <= PEAK_END_DAYS ? 'ready' : 'past_peak';
  return {
    status,
    daysSinceRoast,
    minRestDays,
    daysToGo: Math.max(0, minRestDays - daysSinceRoast),
    readyOn: isoDay(toUtcDay(roastDate) + minRestDays * DAY_MS),
    peakEndsOn: isoDay(toUtcDay(roastDate) + PEAK_END_DAYS * DAY_MS),
  };
}

// 4.9: per-field ok range, unit and target for the UI; the hardness target comes from settings.
const WATER_UNITS = { tdsMgL: 'mg/L', hardnessPpm: 'ppm', alkalinityPpm: 'ppm', ph: '', chlorineMgL: 'mg/L' };
export function waterRanges(settings = {}) {
  const out = {};
  for (const [field, r] of Object.entries(WATER_RANGES)) out[field] = { ...r, unit: WATER_UNITS[field] };
  out.hardnessPpm.target = settings.hardnessTargetPpm ?? WATER_RANGES.hardnessPpm.target;
  return out;
}

// 4.9: returns { field: { status: 'ok'|'warn'|'none', messageKey|null } }
export function evaluateWater(water) {
  const out = {};
  for (const [field, { min, max }] of Object.entries(WATER_RANGES)) {
    const v = water?.[field];
    if (v === null || v === undefined || v === '') out[field] = { status: 'none', messageKey: null };
    else if (v < min) out[field] = { status: 'warn', messageKey: `water.${field}.low` };
    else if (v > max) out[field] = { status: 'warn', messageKey: `water.${field}.high` };
    else out[field] = { status: 'ok', messageKey: null };
  }
  return out;
}

// 4.3: cumulative scale targets for a guided filter brew.
export function filterStages(doseG, { filterRatio = FILTER_STAGES.defaultRatio, bloomFactor = FILTER_STAGES.defaultBloomFactor } = {}) {
  const r = (n) => round(n, FILTER_STAGES.decimals);
  const totalG = r(doseG * filterRatio);
  const bloomG = r(doseG * bloomFactor);
  const pourG = (totalG - bloomG) / FILTER_STAGES.pours;
  const stages = [{ kind: 'bloom', targetG: bloomG }];
  for (let i = 1; i < FILTER_STAGES.pours; i++) stages.push({ kind: 'pour', targetG: r(bloomG + pourG * i) });
  stages.push({ kind: 'pour', targetG: totalG });
  return { totalG, stages };
}
