import { getState, saveState } from './store.js';

const DAY_MS = 86400000;
const clamp = (v, lo, hi) => Math.min(hi, Math.max(lo, v));
const ms = (t) => (t ? new Date(t).getTime() : NaN);

// 4.4: descale interval in days for a hardness (ppm); null/undefined hardness uses the base interval.
export function descaleDays(hardnessPpm, settings = getState().settings) {
  const { descaleBaseDays: base, hardnessTargetPpm: target } = settings;
  if (hardnessPpm === null || hardnessPpm === undefined || !Number.isFinite(Number(hardnessPpm))) return base;
  return clamp(Math.round((base * target) / Math.max(Number(hardnessPpm), 17)), 14, 180);
}

// Hardness of the water used by the machine's newest brew, or null.
export function machineHardness(machine, state = getState()) {
  const last = state.brews.filter((b) => b.machineId === machine.id).sort((a, b) => b.createdAt.localeCompare(a.createdAt))[0];
  const water = last?.waterId ? state.waters.find((w) => w.id === last.waterId) : null;
  return water?.hardnessPpm ?? null;
}

const daysSince = (from, now) => (Number.isNaN(ms(from)) ? 0 : Math.max(0, (now - ms(from)) / DAY_MS));

/**
 * 4.4: all cleaning tasks of non-archived devices, sorted by ratio desc.
 * { kind: 'backflush'|'descale'|'grinderClean', deviceKind, device, current, limit, unit, ratio, overdue }
 */
export function cleaningTasks(state = getState(), now = new Date()) {
  const t = new Date(now).getTime();
  const s = state.settings;
  const tasks = [];
  const add = (kind, deviceKind, device, current, limit, unit) => {
    const ratio = current / limit;
    tasks.push({ kind, deviceKind, device, current, limit, unit, ratio, overdue: ratio >= 1 });
  };
  for (const m of state.machines.filter((x) => !x.archived)) {
    if (m.type === 'espresso') {
      const secs = m.shotSecondsSinceBackflush || 0;
      const days = Math.floor(daysSince(m.lastBackflushAt ?? m.createdAt, t));
      if (secs / s.backflushSeconds >= days / s.backflushDays) add('backflush', 'machine', m, secs, s.backflushSeconds, 's');
      else add('backflush', 'machine', m, days, s.backflushDays, 'days');
    }
    const limit = descaleDays(machineHardness(m, state), s);
    add('descale', 'machine', m, Math.floor(daysSince(m.lastDescaleAt ?? m.createdAt, t)), limit, 'days');
  }
  for (const g of state.grinders.filter((x) => !x.archived)) {
    add('grinderClean', 'grinder', g, g.gramsSinceClean || 0, s.grinderCleanG, 'g');
  }
  return tasks.sort((a, b) => b.ratio - a.ratio);
}

export const dueTasks = (state, now) => cleaningTasks(state, now).filter((x) => x.overdue);

// 4.4 "Erledigt": backflush and grinder clean reset their counter, descale only stamps the date.
export function markDone(kind, deviceId, now = new Date()) {
  const state = getState();
  const at = new Date(now).toISOString();
  const machine = state.machines.find((m) => m.id === deviceId);
  const grinder = state.grinders.find((g) => g.id === deviceId);
  if (kind === 'backflush' && machine) {
    machine.shotSecondsSinceBackflush = 0;
    machine.lastBackflushAt = at;
  } else if (kind === 'descale' && machine) {
    machine.lastDescaleAt = at;
  } else if (kind === 'grinderClean' && grinder) {
    grinder.gramsSinceClean = 0;
    grinder.lastCleanAt = at;
  } else return { ok: false };
  saveState();
  return { ok: true };
}
