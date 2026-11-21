import test, { beforeEach } from 'node:test';
import assert from 'node:assert/strict';

const mem = new Map();
globalThis.localStorage = { getItem: (k) => (mem.has(k) ? mem.get(k) : null), setItem: (k, v) => mem.set(k, String(v)), removeItem: (k) => mem.delete(k) };
const store = await import('../../src/js/store.js');
const m = await import('../../src/js/models.js');
const care = await import('../../src/js/care.js');
const inv = await import('../../src/js/inventory.js');
const dash = await import('../../src/js/dashboard.js');
const brews = await import('../../src/js/brews.js');
const rules = await import('../../src/js/rules/index.js');

const NOW = new Date('2026-11-16T12:00:00Z');
const daysAgo = (n) => new Date(NOW.getTime() - n * 86400000).toISOString();
beforeEach(() => store.resetState());

const machine = (patch = {}) => {
  const { item } = m.createMachine({ name: 'M', type: 'espresso' });
  Object.assign(item, { createdAt: daysAgo(1), ...patch });
  return item;
};
const task = (kind) => care.cleaningTasks(store.getState(), NOW).find((t) => t.kind === kind);

test('4.4 backflush: 53 shots x 28 s not due, 54 due', () => {
  machine({ shotSecondsSinceBackflush: 53 * 28 });
  assert.equal(task('backflush').overdue, false);
  assert.equal(task('backflush').unit, 's');
  store.getState().machines[0].shotSecondsSinceBackflush = 54 * 28;
  const t = task('backflush');
  assert.equal(t.current, 1512);
  assert.ok(Math.abs(t.ratio - 1.008) < 1e-9);
  assert.equal(t.overdue, true);
});

test('4.4 backflush by days and null start counts from creation', () => {
  machine({ lastBackflushAt: daysAgo(7) });
  const t = task('backflush');
  assert.equal(t.unit, 'days');
  assert.equal(t.overdue, true);
  store.getState().machines[0].lastBackflushAt = null;
  store.getState().machines[0].createdAt = daysAgo(3);
  assert.equal(task('backflush').overdue, false);
  assert.equal(task('backflush').current, 3);
  store.getState().machines[0].createdAt = daysAgo(8);
  assert.equal(task('backflush').overdue, true);
});

test('4.4 descale interval by hardness', () => {
  assert.equal(care.descaleDays(null), 90);
  assert.equal(care.descaleDays(136), 45);
  assert.equal(care.descaleDays(17), 180);
  assert.equal(care.descaleDays(0), 180);
  assert.equal(care.descaleDays(68), 90);
  assert.equal(care.descaleDays(2000), 14);
});

test('4.4 descale uses water of the machines last brew', () => {
  const mc = machine({ lastDescaleAt: daysAgo(30) });
  const w = m.createWater({ name: 'Hart', hardnessPpm: 136 }).item;
  assert.equal(task('descale').limit, 90);
  store.getState().brews.push({ id: 'b1', machineId: mc.id, waterId: w.id, createdAt: daysAgo(1) });
  const t = task('descale');
  assert.equal(t.limit, 45);
  assert.ok(Math.abs(t.ratio - 30 / 45) < 1e-9);
  assert.equal(t.overdue, false);
});

test('4.4 example ordering: backflush, grinder, descale', () => {
  machine({ shotSecondsSinceBackflush: 1512, lastDescaleAt: daysAgo(30) });
  const w = m.createWater({ name: 'Hart', hardnessPpm: 136 }).item;
  store.getState().brews.push({ id: 'b1', machineId: store.getState().machines[0].id, waterId: w.id, createdAt: daysAgo(1) });
  m.createGrinder({ name: 'G', type: 'stepped' });
  store.getState().grinders[0].gramsSinceClean = 4000;
  const list = care.cleaningTasks(store.getState(), NOW);
  assert.deepEqual(list.map((t) => t.kind), ['backflush', 'grinderClean', 'descale']);
  assert.deepEqual(list.map((t) => t.overdue), [true, false, false]);
  assert.equal(list[1].ratio, 0.8);
  assert.equal(care.dueTasks(store.getState(), NOW).length, 1);
});

test('filter machine has no backflush; archived devices are skipped', () => {
  const { item } = m.createMachine({ name: 'F', type: 'filter' });
  assert.deepEqual(care.cleaningTasks(store.getState(), NOW).map((t) => t.kind), ['descale']);
  m.archiveItem('machine', item.id);
  assert.equal(care.cleaningTasks(store.getState(), NOW).length, 0);
});

test('settings feed care thresholds', () => {
  machine({ shotSecondsSinceBackflush: 1000 });
  assert.equal(task('backflush').overdue, false);
  store.updateSettings({ backflushSeconds: 900 });
  assert.equal(task('backflush').overdue, true);
});

test('markDone resets per task type', () => {
  const mc = machine({ shotSecondsSinceBackflush: 2000 });
  const g = m.createGrinder({ name: 'G', type: 'stepped' }).item;
  g.gramsSinceClean = 6000;
  assert.equal(care.markDone('descale', mc.id, NOW).ok, true);
  assert.equal(mc.lastDescaleAt, NOW.toISOString());
  assert.equal(mc.shotSecondsSinceBackflush, 2000);
  care.markDone('backflush', mc.id, NOW);
  assert.equal(mc.shotSecondsSinceBackflush, 0);
  assert.equal(mc.lastBackflushAt, NOW.toISOString());
  care.markDone('grinderClean', g.id, NOW);
  assert.equal(g.gramsSinceClean, 0);
  assert.equal(g.lastCleanAt, NOW.toISOString());
  assert.equal(care.markDone('backflush', 'nope').ok, false);
  assert.equal(JSON.parse(mem.get(store.STORAGE_KEY)).machines[0].shotSecondsSinceBackflush, 0);
});

// ---- 4.8
const bean = (level = 'medium', lead = 3) => {
  const r = m.createRoaster({ name: 'R', leadTimeDays: lead }).item;
  return m.createBean({ name: 'B', roasterId: r.id, roastLevel: level }).item;
};
const bag = (b, o = {}) => m.createBag({ beanId: b.id, roastDate: '2026-10-01', weightG: 250, ...o }, '2026-11-16').item;
const brewOn = (bagId, daysBack, dose = 17, purge = 0) =>
  store.getState().brews.push({ id: `b${Math.random()}`, bagId, createdAt: daysAgo(daysBack), doseG: dose, purgeG: purge, machineId: 'x' });

test('4.8 worked example: 14 shots, cover 7 d, order 3 bags', () => {
  const b = bean();
  const g = bag(b);
  brewOn(g.id, 1, 17);
  const [e] = inv.inventory(store.getState(), NOW);
  assert.equal(e.stockG, 250);
  assert.equal(e.shotsLeft, 14);
  assert.equal(e.dailyUseG, 34);
  assert.equal(e.coverDays, 7);
  assert.equal(e.reorderPointG, 340);
  assert.deepEqual(e.reorder, { order: true, bags: 3 });
  assert.equal(inv.orderNeeds(store.getState(), NOW).length, 1);
});

test('4.8 daily use from 14-day window with >=3 distinct days', () => {
  const b = bean();
  const g = bag(b, { weightG: 1000 });
  brewOn(g.id, 1, 18, 1);
  brewOn(g.id, 2, 18, 1);
  brewOn(g.id, 3, 18, 1);
  brewOn(g.id, 20, 50);
  const [e] = inv.inventory(store.getState(), NOW);
  assert.equal(e.dailyUseG, 57 / 14);
});

test('4.8 no usage: coverDays null and no hint; resting bag suppresses hint; zero result no hint', () => {
  const b = bean();
  const g = bag(b);
  let [e] = inv.inventory(store.getState(), NOW);
  assert.equal(e.coverDays, null);
  assert.equal(e.shotsLeft, null);
  assert.deepEqual(e.reorder, { order: false });
  brewOn(g.id, 1, 17);
  bag(b, { roastDate: '2026-11-14' }); // resting (medium espresso 7 d)
  [e] = inv.inventory(store.getState(), NOW);
  assert.equal(e.hasResting, true);
  assert.equal(e.stockG, 500);
  assert.equal(e.usableStockG, 250);
  assert.deepEqual(e.reorder, { order: false });
  store.getState().bags.pop();
  store.getState().bags.push({ ...g, id: 'big', weightG: 5000, remainingG: 5000, roastDate: '2026-10-02' });
  [e] = inv.inventory(store.getState(), NOW);
  assert.deepEqual(e.reorder, { order: false }); // plenty of stock: 28*34 < 5250
});

test('4.8 resting bag list with readyOn', () => {
  const b = bean();
  bag(b, { roastDate: '2026-11-14' });
  bag(b, { roastDate: '2026-10-01' });
  const list = inv.restingBags(NOW);
  assert.equal(list.length, 1);
  assert.equal(list[0].readyOn, '2026-11-21');
  assert.equal(list[0].daysToGo, 5);
});

test('4.8 targetCoverDays and plannedShotsPerDay come from settings', () => {
  const b = bean();
  const g = bag(b);
  brewOn(g.id, 1, 17);
  store.updateSettings({ plannedShotsPerDay: 1, targetCoverDays: 14 });
  const [e] = inv.inventory(store.getState(), NOW);
  assert.equal(e.dailyUseG, 17);
  assert.equal(e.coverDays, 14);
  assert.deepEqual(e.reorder, { order: false }); // 250 > 17*10 and so no hint
});

// ---- dashboard
test('dashboard: empty, then populated', () => {
  assert.equal(dash.todayData(NOW).empty, true);
  const b = bean();
  bag(b, { roastDate: '2026-11-14' });
  const d = dash.todayData(NOW);
  assert.equal(d.empty, false);
  assert.equal(d.restingBags[0].readyOn, '2026-11-21');
  for (let i = 0; i < 5; i++) store.getState().brews.push({ id: `x${i}`, bagId: 'z', createdAt: daysAgo(i), doseG: 1 });
  assert.deepEqual(dash.todayData(NOW).lastBrews.map((x) => x.id), ['x0', 'x1', 'x2']);
});

test('dashboard: due tasks only overdue', () => {
  machine({ shotSecondsSinceBackflush: 1600 });
  m.createGrinder({ name: 'G', type: 'stepped' });
  const d = dash.todayData(NOW);
  assert.deepEqual(d.dueTasks.map((t) => t.kind), ['backflush']);
});

// ---- 4.9 / settings feeding rules
test('4.9 worked example and ranges', () => {
  const r = rules.evaluateWater({ tdsMgL: 120, hardnessPpm: 136, alkalinityPpm: 90, ph: 7.2 });
  assert.deepEqual([r.tdsMgL.status, r.hardnessPpm.status, r.alkalinityPpm.status, r.ph.status, r.chlorineMgL.status], ['ok', 'ok', 'warn', 'ok', 'none']);
  assert.equal(r.alkalinityPpm.messageKey, 'water.alkalinityPpm.high');
  assert.equal(rules.evaluateWater({ chlorineMgL: 0.2 }).chlorineMgL.status, 'warn');
  assert.equal(rules.evaluateWater({ ph: 6.5 }).ph.status, 'ok');
  assert.equal(rules.evaluateWater({ ph: 7.6 }).ph.status, 'warn');
  assert.equal(rules.evaluateWater({ tdsMgL: 74 }).tdsMgL.messageKey, 'water.tdsMgL.low');
  const ranges = rules.waterRanges({ hardnessTargetPpm: 80 });
  assert.deepEqual(ranges.alkalinityPpm, { min: 40, max: 70, target: 40, unit: 'ppm' });
  assert.equal(ranges.hardnessPpm.target, 80);
  assert.equal(rules.waterRanges().hardnessPpm.target, 68);
});

test('settings feed classifyTime, recommend and filterStages', () => {
  assert.equal(rules.classifyTime(33, { espressoTimeMinS: 25, espressoTimeMaxS: 30 }), 'slow');
  assert.equal(rules.classifyTime(33, { espressoTimeMinS: 25, espressoTimeMaxS: 35 }), 'in_range');
  const brew = { method: 'espresso', taste: 'bitter', timeS: 33, grinderSetting: 10 };
  assert.ok(rules.recommend(brew, {}, { espressoTimeMaxS: 30 }).steps.some((s) => s.key === 'rec.tempDown') === false);
  assert.ok(rules.recommend(brew, {}, { espressoTimeMaxS: 35 }).steps.some((s) => s.key === 'rec.tempDown'));
  assert.equal(rules.filterStages(10, { filterRatio: 15 }).totalG, 150);
  store.updateSettings({ espressoTimeMaxS: 40 });
  assert.equal(brews.brewTimeClass({ method: 'espresso', timeS: 38 }).cls, 'in_range');
});
