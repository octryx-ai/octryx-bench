export const STORAGE_KEY = 'coffee.v1';

export const DEFAULT_SETTINGS = Object.freeze({
  language: 'de',
  theme: 'system',
  espressoTimeMinS: 25,
  espressoTimeMaxS: 30,
  backflushSeconds: 1500,
  backflushDays: 7,
  grinderCleanG: 5000,
  descaleBaseDays: 90,
  hardnessTargetPpm: 68,
  filterRatio: 16,
  plannedShotsPerDay: 2,
  targetCoverDays: 28,
  idlePurgeHours: 24,
  bloomFactor: 2,
});

const COLLECTIONS = ['machines', 'grinders', 'roasters', 'beans', 'bags', 'waters', 'brews'];

export function emptyState() {
  const state = { version: 1, settings: { ...DEFAULT_SETTINGS } };
  for (const c of COLLECTIONS) state[c] = [];
  return state;
}

const isObject = (v) => v !== null && typeof v === 'object' && !Array.isArray(v);

function normalize(raw) {
  const state = emptyState();
  for (const c of COLLECTIONS) if (Array.isArray(raw[c])) state[c] = raw[c];
  if (isObject(raw.settings)) Object.assign(state.settings, raw.settings);
  return state;
}

function storage() {
  try {
    return globalThis.localStorage ?? null;
  } catch {
    return null;
  }
}

let state = null;
const listeners = new Set();

function notify() {
  for (const fn of [...listeners]) fn(state);
}

export function loadState() {
  let raw = null;
  try {
    raw = JSON.parse(storage()?.getItem(STORAGE_KEY));
  } catch {
    raw = null;
  }
  state = isObject(raw) && raw.version === 1 ? normalize(raw) : emptyState();
  saveState();
  return state;
}

export function getState() {
  return state ?? loadState();
}

export function saveState() {
  try {
    storage()?.setItem(STORAGE_KEY, JSON.stringify(getState()));
    return true;
  } catch {
    return false;
  }
}

export function updateSettings(patch) {
  Object.assign(getState().settings, patch);
  saveState();
  notify();
  return state.settings;
}

const SETTING_RANGES = {
  espressoTimeMinS: [1, 120], espressoTimeMaxS: [1, 180], backflushSeconds: [60, 100000], backflushDays: [1, 90],
  grinderCleanG: [100, 100000], descaleBaseDays: [14, 365], hardnessTargetPpm: [1, 500], filterRatio: [5, 30],
  plannedShotsPerDay: [0.5, 50], targetCoverDays: [1, 365], idlePurgeHours: [1, 720], bloomFactor: [0.5, 10],
};
const SETTING_ENUMS = { language: ['de', 'en'], theme: ['light', 'dark', 'system'] };

// Returns { field: 'err.setting.<field>' } for invalid values in `patch`; unknown keys are ignored.
export function validateSettings(patch = {}, current = getState().settings) {
  const errors = {};
  for (const [field, [lo, hi]] of Object.entries(SETTING_RANGES)) {
    if (!(field in patch)) continue;
    const v = patch[field];
    if (v === '' || v === null || typeof v === 'boolean' || !Number.isFinite(Number(v)) || Number(v) < lo || Number(v) > hi) errors[field] = `err.setting.${field}`;
  }
  for (const [field, allowed] of Object.entries(SETTING_ENUMS)) {
    if (field in patch && !allowed.includes(patch[field])) errors[field] = `err.setting.${field}`;
  }
  if ('espressoTimeMinS' in patch || 'espressoTimeMaxS' in patch) {
    const min = Number('espressoTimeMinS' in patch ? patch.espressoTimeMinS : current.espressoTimeMinS);
    const max = Number('espressoTimeMaxS' in patch ? patch.espressoTimeMaxS : current.espressoTimeMaxS);
    if (!(min < max)) {
      for (const f of ['espressoTimeMinS', 'espressoTimeMaxS']) if (f in patch) errors[f] = `err.setting.${f}`;
    }
  }
  return errors;
}

// Validates, then stores numbers as numbers. Returns { ok, errors, settings }.
export function saveSettings(patch = {}) {
  const errors = validateSettings(patch);
  if (Object.keys(errors).length) return { ok: false, errors };
  const clean = { ...patch };
  for (const f of Object.keys(SETTING_RANGES)) if (f in clean) clean[f] = Number(clean[f]);
  return { ok: true, errors: {}, settings: updateSettings(clean) };
}

export function subscribe(fn) {
  listeners.add(fn);
  return () => listeners.delete(fn);
}

export function resetState() {
  state = emptyState();
  saveState();
  notify();
  return state;
}

export function exportJson() {
  return JSON.stringify(getState(), null, 2);
}

export function exportFilename(date = new Date()) {
  return `coffee-export-${new Date(date).toISOString().slice(0, 10)}.json`;
}

export function importJson(text) {
  let raw;
  try {
    raw = JSON.parse(text);
  } catch {
    throw new Error('Ungültige Datei');
  }
  if (!isObject(raw) || raw.version !== 1 || !COLLECTIONS.every((c) => Array.isArray(raw[c]))
    || (raw.settings !== undefined && !isObject(raw.settings))) throw new Error('Ungültige Datei');
  state = normalize(raw);
  saveState();
  notify();
  return state;
}
