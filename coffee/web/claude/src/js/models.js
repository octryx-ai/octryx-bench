import { getState, saveState } from './store.js';
import { restStatus } from './rules/index.js';

const KINDS = { machine: 'machines', grinder: 'grinders', roaster: 'roasters', bean: 'beans', bag: 'bags', water: 'waters' };
const MAX_DEVICES = 10;
const STEP_DEFAULTS = { stepped: 1, hand: 1, numbered: 1 };
const UNIT_DEFAULTS = { stepped: 'Stufen', stepless: 'Zahl', numbered: 'Zahl', hand: 'Klicks' };
const ISO_DAY = /^\d{4}-\d{2}-\d{2}$/;

export function uuid() {
  if (globalThis.crypto?.randomUUID) return globalThis.crypto.randomUUID();
  const h = (n) => Array.from({ length: n }, () => Math.floor(Math.random() * 16).toString(16)).join('');
  return `${h(8)}-${h(4)}-4${h(3)}-${'89ab'[Math.floor(Math.random() * 4)]}${h(3)}-${h(12)}`;
}

const todayIso = () => new Date().toISOString().slice(0, 10);
const blank = (v) => v === undefined || v === null || v === '';
const num = (v) => (blank(v) ? NaN : Number(v));
const str = (v) => (typeof v === 'string' ? v.trim() : '');
const coll = (kind) => getState()[KINDS[kind]];
const find = (kind, id) => coll(kind).find((x) => x.id === id);
const byName = (a, b) => a.name.localeCompare(b.name);
const byBrew = (kind, id) => getState().brews.filter((b) => b[`${kind}Id`] === id).length;
const decimals = (v, d) => Math.abs(v * 10 ** d - Math.round(v * 10 ** d)) < 1e-6;

function checkName(v, errors) {
  const name = str(v);
  if (name.length < 1 || name.length > 60) errors.name = 'err.name';
  return name;
}

// Each schema: (input, ctx) -> { value, errors }. For updates input is the existing item merged with the patch.
const SCHEMAS = {
  machine(i) {
    const errors = {};
    const name = checkName(i.name, errors);
    if (!['espresso', 'filter'].includes(i.type)) errors.type = 'err.type';
    return { errors, value: { name, type: i.type } };
  },

  grinder(i) {
    const errors = {};
    const name = checkName(i.name, errors);
    const type = i.type;
    if (!(type in UNIT_DEFAULTS)) errors.type = 'err.type';
    let rangeMin = null;
    let rangeMax = null;
    if (type === 'stepless') {
      rangeMin = blank(i.rangeMin) ? 0 : num(i.rangeMin);
      rangeMax = blank(i.rangeMax) ? 10 : num(i.rangeMax);
      if (!(rangeMin < rangeMax)) errors.range = 'err.range';
    }
    let stepSize = !blank(i.stepSize) ? num(i.stepSize) : type === 'stepless' ? 0.05 * (rangeMax - rangeMin) : STEP_DEFAULTS[type];
    if (!(stepSize > 0)) errors.stepSize = 'err.stepSize';
    else stepSize = Math.round(stepSize * 1e6) / 1e6;
    const retentionG = blank(i.retentionG) ? 0.5 : num(i.retentionG);
    if (!(retentionG >= 0 && retentionG <= 5) || !decimals(retentionG, 1)) errors.retention = 'err.retention';
    return {
      errors,
      value: {
        name, type, settingUnit: str(i.settingUnit) || UNIT_DEFAULTS[type] || '',
        stepSize, rangeMin, rangeMax, higherIsFiner: !!i.higherIsFiner, retentionG,
      },
    };
  },

  roaster(i) {
    const errors = {};
    const name = checkName(i.name, errors);
    const url = str(i.url);
    if (url && !/^https?:\/\/\S+/i.test(url)) errors.url = 'err.url';
    const leadTimeDays = blank(i.leadTimeDays) ? 3 : num(i.leadTimeDays);
    if (!Number.isInteger(leadTimeDays) || leadTimeDays < 0 || leadTimeDays > 30) errors.leadTime = 'err.leadTime';
    return { errors, value: { name, url, leadTimeDays } };
  },

  bean(i) {
    const errors = {};
    const name = checkName(i.name, errors);
    if (!find('roaster', i.roasterId)) errors.roaster = 'err.roaster';
    if (!['light', 'medium', 'dark'].includes(i.roastLevel)) errors.roastLevel = 'err.roastLevel';
    return {
      errors,
      value: { name, roasterId: i.roasterId, origin: str(i.origin), roastLevel: i.roastLevel, notes: str(i.notes) },
    };
  },

  bag(i, { today }) {
    const errors = {};
    if (!find('bean', i.beanId)) errors.bean = 'err.bean';
    const roastDate = str(i.roastDate);
    const valid = ISO_DAY.test(roastDate) && !isNaN(Date.parse(`${roastDate}T00:00:00Z`))
      && new Date(`${roastDate}T00:00:00Z`).toISOString().slice(0, 10) === roastDate;
    if (!valid || roastDate > today) errors.roastDate = 'err.roastDate';
    const weightG = num(i.weightG);
    if (!(weightG > 0)) errors.weightG = 'err.weightG';
    const remainingG = blank(i.remainingG) ? weightG : num(i.remainingG);
    if (!(remainingG >= 0) || remainingG > (weightG || 0)) errors.remainingG = 'err.remainingG';
    let price = null;
    if (!blank(i.price)) {
      price = num(i.price);
      if (!(price >= 0) || !decimals(price, 2)) errors.price = 'err.price';
      else price = Math.round(price * 100) / 100;
    }
    return { errors, value: { beanId: i.beanId, roastDate, weightG, remainingG, price, openedOn: str(i.openedOn) || null } };
  },
};

const WATER_FIELDS = ['tdsMgL', 'hardnessPpm', 'alkalinityPpm', 'ph', 'chlorineMgL'];

SCHEMAS.water = (i) => {
  const errors = {};
  const name = checkName(i.name, errors);
  const value = { name };
  for (const f of WATER_FIELDS) {
    if (blank(i[f])) { value[f] = null; continue; }
    const n = num(i[f]);
    if (!(n >= 0)) errors[f] = 'err.number';
    else if (f === 'ph' && n > 14) errors[f] = 'err.ph';
    value[f] = n;
  }
  return { errors, value };
};

const DEFAULTS = {
  water: () => ({}),
  machine: () => ({ createdAt: new Date().toISOString(), lastBackflushAt: null, lastDescaleAt: null, lastDeepCleanAt: null, shotSecondsSinceBackflush: 0, archived: false }),
  grinder: () => ({ createdAt: new Date().toISOString(), gramsSinceClean: 0, lastCleanAt: null, lastUsedAt: null, lastBeanId: null, archived: false }),
  roaster: () => ({}),
  bean: () => ({ archived: false }),
  bag: () => ({}),
};

function create(kind, input = {}, today = todayIso()) {
  if ((kind === 'machine' || kind === 'grinder') && coll(kind).length >= MAX_DEVICES) {
    return { ok: false, errors: { _limit: `err.limit.${kind}` } };
  }
  const { errors, value } = SCHEMAS[kind](input, { today });
  if (Object.keys(errors).length) return { ok: false, errors };
  const item = { id: uuid(), ...DEFAULTS[kind](), ...value };
  coll(kind).push(item);
  saveState();
  return { ok: true, item };
}

function update(kind, id, patch = {}, today = todayIso()) {
  const item = find(kind, id);
  if (!item) return { ok: false, errors: { _id: 'err.notFound' } };
  const { errors, value } = SCHEMAS[kind]({ ...item, ...patch }, { today });
  if (Object.keys(errors).length) return { ok: false, errors };
  Object.assign(item, value);
  saveState();
  return { ok: true, item };
}

export const createMachine = (i) => create('machine', i);
export const updateMachine = (id, p) => update('machine', id, p);
export const createGrinder = (i) => create('grinder', i);
export const updateGrinder = (id, p) => update('grinder', id, p);
export const createRoaster = (i) => create('roaster', i);
export const updateRoaster = (id, p) => update('roaster', id, p);
export const createBean = (i) => create('bean', i);
export const updateBean = (id, p) => update('bean', id, p);
export const createWater = (i) => create('water', i);
export const updateWater = (id, p) => update('water', id, p);
export const createBag = (i, today) => create('bag', i, today);
export const updateBag = (id, p, today) => update('bag', id, p, today);

const list = (kind, { includeArchived = false, archived = false } = {}) =>
  coll(kind).filter((x) => includeArchived || archived || !x.archived).sort(byName);
export const listMachines = (o) => list('machine', o);
export const listGrinders = (o) => list('grinder', o);
export const listRoasters = () => list('roaster', { includeArchived: true });
export const listWaters = () => list('water');
export const listBeans = (o) => list('bean', o);

const beansOfRoaster = (id) => coll('bean').filter((b) => b.roasterId === id);
const bagsOfBean = (id) => coll('bag').filter((b) => b.beanId === id);

export function usageCount(kind, id) {
  switch (kind) {
    case 'machine':
    case 'grinder':
    case 'bag':
    case 'water': return byBrew(kind, id);
    case 'bean': return bagsOfBean(id).reduce((n, b) => n + byBrew('bag', b.id), 0);
    case 'roaster': return beansOfRoaster(id).reduce((n, b) => n + usageCount('bean', b.id), 0);
    default: return 0;
  }
}

export function removeItem(kind, id) {
  const state = getState();
  const item = find(kind, id);
  if (!item) return { ok: false, reason: 'notFound' };
  let count = usageCount(kind, id);
  if (kind === 'bag' && item.remainingG === 0) count = 0;
  if (kind === 'roaster' && count === 0) count = beansOfRoaster(id).length;
  if (count > 0) {
    const device = kind === 'machine' || kind === 'grinder';
    return {
      ok: false, reason: 'inUse', count,
      messageKey: device ? 'err.inUse.device' : 'err.inUse.item',
      canArchive: device || kind === 'bean',
    };
  }
  if (kind === 'bean') state.bags = state.bags.filter((b) => b.beanId !== id);
  state[KINDS[kind]] = state[KINDS[kind]].filter((x) => x.id !== id);
  saveState();
  return { ok: true };
}

function setArchived(kind, id, archived) {
  const item = ['machine', 'grinder', 'bean'].includes(kind) ? find(kind, id) : null;
  if (!item) return { ok: false };
  item.archived = archived;
  saveState();
  return { ok: true, item };
}
export const archiveItem = (kind, id) => setArchived(kind, id, true);
export const restoreItem = (kind, id) => setArchived(kind, id, false);

export const hueForRoaster = (name) => 15 + ([...String(name)].reduce((s, c) => s + c.charCodeAt(0), 0) % 45);
export const roasterOfBean = (bean) => (bean ? find('roaster', bean.roasterId) ?? null : null);

// Bean-screen default method is espresso (stricter rest table, 4.7).
export function bagRest(bag, bean, today, method = 'espresso') {
  return restStatus({ roastDate: bag.roastDate, roastLevel: bean.roastLevel, method }, today);
}

export function beansWithBags({ includeArchived = false, today } = {}) {
  return list('bean', { includeArchived }).map((bean) => {
    const roaster = roasterOfBean(bean);
    const bags = bagsOfBean(bean.id)
      .sort((a, b) => a.roastDate.localeCompare(b.roastDate))
      .map((b) => ({ ...b, rest: bagRest(b, bean, today) }));
    return {
      bean, roaster, hue: hueForRoaster(roaster?.name ?? bean.name), bags,
      stockG: bags.reduce((s, b) => s + b.remainingG, 0),
    };
  });
}
