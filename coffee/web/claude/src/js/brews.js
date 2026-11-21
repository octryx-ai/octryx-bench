import { getState, saveState } from './store.js';
import { uuid, bagRest, roasterOfBean } from './models.js';
import { classifyTime, timeClassStatus, recommend, filterStages } from './rules/index.js';
import { formatNumber } from './format.js';
import { getLang } from './i18n.js';

const TASTES = ['sour', 'bitter', 'weak', 'harsh_astringent', 'balanced'];
const HOUR_MS = 3600000;
const blank = (v) => v === undefined || v === null || v === '';
const num = (v) => (blank(v) ? NaN : Number(v));
const inRange = (v, lo, hi) => Number.isFinite(v) && v >= lo && v <= hi;
const round = (n, d = 2) => Math.round(n * 10 ** d) / 10 ** d;
const find = (coll, id) => getState()[coll].find((x) => x.id === id);

// 4.1
export function ratio(doseG, yieldG) {
  const d = Number(doseG);
  const y = Number(yieldG);
  return d > 0 && Number.isFinite(y) ? y / d : null;
}

export function ratioText(doseG, yieldG, lang = getLang()) {
  const r = ratio(doseG, yieldG);
  return r === null ? '–' : `1:${formatNumber(r, 1, lang)}`;
}

// Returns { field: i18nKey }. Does not check bag stock.
export function validateBrew(i = {}) {
  const e = {};
  const method = i.method;
  if (!['espresso', 'filter'].includes(method)) e.method = 'err.method';
  if (!find('machines', i.machineId)) e.machine = 'err.machine';
  if (!find('grinders', i.grinderId)) e.grinder = 'err.grinder';
  if (!find('bags', i.bagId)) e.bag = 'err.bag';
  if (!(num(i.grinderSetting) >= 0)) e.setting = 'err.setting';
  if (!inRange(num(i.doseG), 1, 60)) e.dose = 'err.dose';
  if (method === 'filter') {
    if (!inRange(num(i.waterG), 1, 2000)) e.water = 'err.water';
  } else if (!inRange(num(i.yieldG), 1, 200)) e.yield = 'err.yield';
  if (!inRange(num(i.timeS), 0, 600)) e.time = 'err.time';
  if (!blank(i.tempC) && !inRange(num(i.tempC), 80, 100)) e.temp = 'err.temp';
  if (!blank(i.taste) && !TASTES.includes(i.taste)) e.taste = 'err.taste';
  return e;
}

// 4.5: grams to grind and discard before the dose.
export function purgeAdvice({ grinder, bean, beanId, now = new Date(), settings = getState().settings } = {}) {
  const id = beanId ?? (bean && typeof bean === 'object' ? bean.id : bean);
  const retention = grinder?.retentionG ?? 0;
  if (!grinder?.lastUsedAt || !grinder.lastBeanId) return 0;
  if (grinder.lastBeanId !== id) return round(2 * retention, 1);
  const hours = (new Date(now).getTime() - new Date(grinder.lastUsedAt).getTime()) / HOUR_MS;
  return hours >= (settings.idlePurgeHours ?? 24) ? round(retention, 1) : 0;
}

export function createBrew(input = {}, now = new Date()) {
  const state = getState();
  const errors = validateBrew(input);
  const bag = find('bags', input.bagId);
  const bean = bag ? find('beans', bag.beanId) : null;
  if (bag && bean && !errors.method && bagRest(bag, bean, new Date(now).toISOString().slice(0, 10), input.method).status === 'resting') {
    errors.bag = 'err.bag.resting';
  }
  if (Object.keys(errors).length) return { ok: false, errors };

  const grinder = find('grinders', input.grinderId);
  const machine = find('machines', input.machineId);
  const espresso = input.method === 'espresso';
  const doseG = num(input.doseG);
  const timeS = num(input.timeS);
  const purgeG = purgeAdvice({ grinder, beanId: bag.beanId, now, settings: state.settings });
  const brew = {
    id: uuid(),
    createdAt: new Date(now).toISOString(),
    method: input.method,
    machineId: machine.id,
    grinderId: grinder.id,
    grinderSetting: num(input.grinderSetting),
    bagId: bag.id,
    waterId: input.waterId || null,
    doseG,
    yieldG: espresso ? num(input.yieldG) : null,
    waterG: espresso ? null : num(input.waterG),
    timeS,
    tempC: blank(input.tempC) ? null : num(input.tempC),
    taste: input.taste || null,
    purgeG,
    favourite: false,
    notes: typeof input.notes === 'string' ? input.notes.trim() : '',
  };

  const used = round(doseG + purgeG, 3);
  const result = { ok: true, brew };
  if (used > bag.remainingG) {
    result.warning = { key: 'warn.bagLow', params: { x: bag.remainingG } };
    bag.remainingG = 0;
  } else {
    bag.remainingG = round(bag.remainingG - used, 3);
  }
  grinder.lastUsedAt = brew.createdAt;
  grinder.lastBeanId = bag.beanId;
  grinder.gramsSinceClean = round((grinder.gramsSinceClean || 0) + doseG, 3);
  machine.shotSecondsSinceBackflush = round((machine.shotSecondsSinceBackflush || 0) + timeS, 3);
  state.brews.push(brew);
  saveState();
  return result;
}

export function lastDose(method) {
  const last = listBrews(method ? { method } : {})[0];
  return last ? last.doseG : null;
}

// Guided filter flow: water is the 4.3 total for the dose; a missing grinder setting defaults to 0.
export function createGuidedBrew({ machineId, grinderId, grinderSetting, bagId, doseG, timeS, settings = getState().settings, ...rest } = {}, now = new Date()) {
  const d = num(doseG);
  const waterG = d > 0 ? filterStages(d, settings).totalG : NaN;
  return createBrew({ ...rest, method: 'filter', machineId, grinderId, bagId, doseG, timeS, waterG, grinderSetting: blank(grinderSetting) ? 0 : grinderSetting }, now);
}

// Edits metadata only: no stock, grinder or machine counters are re-applied.
const PATCHABLE = ['notes', 'taste', 'favourite', 'tempC', 'waterId'];
export function updateBrew(id, patch = {}) {
  const brew = find('brews', id);
  if (!brew) return { ok: false, errors: { _id: 'err.notFound' } };
  const next = { ...patch };
  const errors = {};
  if ('taste' in next) {
    if (blank(next.taste)) next.taste = null;
    else if (!TASTES.includes(next.taste)) errors.taste = 'err.taste';
  }
  if ('tempC' in next) {
    if (blank(next.tempC)) next.tempC = null;
    else if (!inRange(num(next.tempC), 80, 100)) errors.temp = 'err.temp';
    else next.tempC = num(next.tempC);
  }
  if (Object.keys(errors).length) return { ok: false, errors };
  for (const k of PATCHABLE) if (k in next) brew[k] = k === 'favourite' ? !!next[k] : k === 'notes' ? String(next[k] ?? '').trim() : next[k];
  saveState();
  return { ok: true, brew };
}

export function toggleFavourite(id) {
  const brew = find('brews', id);
  return brew ? updateBrew(id, { favourite: !brew.favourite }) : { ok: false, errors: { _id: 'err.notFound' } };
}

export const getBrew = (id) => find('brews', id) ?? null;

export function removeBrew(id) {
  const state = getState();
  const n = state.brews.length;
  state.brews = state.brews.filter((b) => b.id !== id);
  saveState();
  return { ok: state.brews.length < n };
}

export function listBrews({ method, grinderId, beanId, favourite } = {}) {
  const state = getState();
  const beanOf = (b) => state.bags.find((x) => x.id === b.bagId)?.beanId;
  return state.brews
    .filter((b) => (!method || b.method === method)
      && (!grinderId || b.grinderId === grinderId)
      && (!beanId || beanOf(b) === beanId)
      && (!favourite || b.favourite))
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

export function brewTimeClass(brew, settings = getState().settings) {
  if (brew.method !== 'espresso') return { cls: null, status: null };
  const cls = classifyTime(brew.timeS, settings);
  return { cls, status: timeClassStatus(cls) };
}

const mmss = (s) => `${String(Math.floor(s / 60)).padStart(2, '0')}:${String(Math.round(s) % 60).padStart(2, '0')}`;

export function brewSummary(brew, lang = getLang()) {
  const g = (n, d = 1) => `${formatNumber(n, d, lang)} g`;
  if (brew.method === 'filter') {
    return `${g(brew.doseG)} → ${formatNumber(brew.waterG, 0, lang)} g · ${ratioText(brew.doseG, brew.waterG, lang)} · ${mmss(brew.timeS)}`;
  }
  const t = formatNumber(brew.timeS, Number.isInteger(brew.timeS) ? 0 : 1, lang);
  return `${g(brew.doseG)} → ${g(brew.yieldG)} · ${ratioText(brew.doseG, brew.yieldG, lang)} · ${t} s`;
}

// Bags of non-archived beans with stock, oldest roast first (FIFO), resting ones flagged disabled.
export function pickerBags({ now = new Date(), method = 'espresso' } = {}) {
  const state = getState();
  const today = new Date(now).toISOString().slice(0, 10);
  return state.bags
    .filter((bag) => bag.remainingG > 0)
    .map((bag) => ({ bag, bean: state.beans.find((b) => b.id === bag.beanId) }))
    .filter(({ bean }) => bean && !bean.archived)
    .sort((a, b) => a.bag.roastDate.localeCompare(b.bag.roastDate))
    .map(({ bag, bean }) => {
      const rest = bagRest(bag, bean, today, method);
      return { bag, bean, roaster: roasterOfBean(bean), rest, disabled: rest.status === 'resting' };
    });
}

export function recommendationFor(brew, grinder, settings = getState().settings) {
  if (!brew?.taste) return null;
  return recommend(brew, grinder, settings);
}
