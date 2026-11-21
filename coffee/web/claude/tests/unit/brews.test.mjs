import test, { beforeEach } from 'node:test';
import assert from 'node:assert/strict';

const mem = new Map();
globalThis.localStorage = {
  getItem: (k) => (mem.has(k) ? mem.get(k) : null),
  setItem: (k, v) => mem.set(k, String(v)),
  removeItem: (k) => mem.delete(k),
};
const store = await import('../../src/js/store.js');
const m = await import('../../src/js/models.js');
const b = await import('../../src/js/brews.js');

const NOW = new Date('2026-11-16T12:00:00Z');
beforeEach(() => store.resetState());

function setup({ roastDate = '2026-11-01', weightG = 250, retentionG = 0.6 } = {}) {
  const roaster = m.createRoaster({ name: 'R' }).item;
  const bean = m.createBean({ name: 'A', roasterId: roaster.id, roastLevel: 'medium' }).item;
  const bag = m.createBag({ beanId: bean.id, roastDate, weightG }, '2026-11-16').item;
  const machine = m.createMachine({ name: 'M', type: 'espresso' }).item;
  const grinder = m.createGrinder({ name: 'G', type: 'stepped', retentionG }).item;
  const input = { method: 'espresso', machineId: machine.id, grinderId: grinder.id, bagId: bag.id, grinderSetting: 12, doseG: 17, yieldG: 34, timeS: 27 };
  return { roaster, bean, bag, machine, grinder, input };
}

test('ratio and text', () => {
  assert.equal(b.ratio(18, 36), 2);
  assert.equal(b.ratio(17, 34), 2);
  assert.equal(b.ratio(0, 36), null);
  assert.equal(b.ratioText(18, 36, 'de'), '1:2,0');
  assert.equal(b.ratioText(18, 36, 'en'), '1:2.0');
});

test('validation', () => {
  const { input } = setup();
  assert.deepEqual(b.validateBrew(input), {});
  const e = b.validateBrew({ ...input, doseG: 61, yieldG: 0.5, timeS: 601, tempC: 79, grinderSetting: -1 });
  assert.deepEqual(e, { dose: 'err.dose', yield: 'err.yield', time: 'err.time', temp: 'err.temp', setting: 'err.setting' });
  assert.equal(b.validateBrew({ ...input, doseG: 60, yieldG: 200, timeS: 0, tempC: 100 }).dose, undefined);
  assert.equal(b.validateBrew({ ...input, doseG: 0.9 }).dose, 'err.dose');
  assert.equal(b.validateBrew({ ...input, bagId: 'x', machineId: 'y', grinderId: 'z' }).bag, 'err.bag');
  const f = b.validateBrew({ ...input, method: 'filter', yieldG: undefined, waterG: 2001 });
  assert.deepEqual(f, { water: 'err.water' });
});

test('4.5 purge worked examples', () => {
  const s = { idlePurgeHours: 24 };
  const g = { retentionG: 0.6, lastUsedAt: '2026-11-15T06:00:00Z', lastBeanId: 'a' };
  assert.equal(b.purgeAdvice({ grinder: g, bean: 'a', now: NOW, settings: s }), 0.6); // 30 h
  assert.equal(b.purgeAdvice({ grinder: g, bean: 'b', now: NOW, settings: s }), 1.2);
  assert.equal(b.purgeAdvice({ grinder: { ...g, lastUsedAt: '2026-11-16T07:00:00Z' }, bean: 'a', now: NOW, settings: s }), 0);
  assert.equal(b.purgeAdvice({ grinder: { ...g, lastUsedAt: '2026-11-15T12:00:00Z' }, bean: 'a', now: NOW, settings: s }), 0.6); // exactly 24 h
  assert.equal(b.purgeAdvice({ grinder: { ...g, lastUsedAt: null }, bean: 'a', now: NOW, settings: s }), 0);
  assert.equal(b.purgeAdvice({ grinder: { ...g, lastBeanId: null }, bean: 'a', now: NOW, settings: s }), 0);
});

test('createBrew stores brew, deducts stock, updates counters', () => {
  const { input, bag, grinder, machine } = setup();
  const r = b.createBrew(input, NOW);
  assert.ok(r.ok);
  assert.equal(r.warning, undefined);
  assert.equal(r.brew.purgeG, 0); // first use
  assert.equal(r.brew.createdAt, NOW.toISOString());
  assert.equal(r.brew.favourite, false);
  assert.equal(m.listGrinders()[0].lastBeanId, bag.beanId);
  assert.equal(grinder.gramsSinceClean, 17);
  assert.equal(machine.shotSecondsSinceBackflush, 27);
  assert.equal(bag.remainingG, 233);
  // second brew 30 h later, same bean -> purge 0.6
  const later = new Date(NOW.getTime() + 30 * 3600000);
  const r2 = b.createBrew(input, later);
  assert.equal(r2.brew.purgeG, 0.6);
  assert.equal(bag.remainingG, 215.4);
  assert.equal(machine.shotSecondsSinceBackflush, 54);
  assert.equal(JSON.parse(mem.get('coffee.v1')).brews.length, 2);
});

test('bag low warning and resting bag', () => {
  const { input, bag } = setup({ weightG: 10 });
  const r = b.createBrew(input, NOW);
  assert.ok(r.ok);
  assert.deepEqual(r.warning, { key: 'warn.bagLow', params: { x: 10 } });
  assert.equal(bag.remainingG, 0);
  assert.equal(b.listBrews().length, 1);

  const s2 = setup({ roastDate: '2026-11-10' }); // medium espresso: 7 days -> resting at day 6
  const r2 = b.createBrew(s2.input, NOW);
  assert.equal(r2.ok, false);
  assert.equal(r2.errors.bag, 'err.bag.resting');
  assert.equal(s2.bag.remainingG, 250);
  assert.equal(b.createBrew({ ...s2.input, method: 'filter', waterG: 270, yieldG: undefined }, NOW).ok, true); // 3 days for filter
});

test('invalid input does not change state', () => {
  const { input, bag } = setup();
  const r = b.createBrew({ ...input, doseG: 0 }, NOW);
  assert.deepEqual(r.errors, { dose: 'err.dose' });
  assert.equal(bag.remainingG, 250);
  assert.equal(b.listBrews().length, 0);
});

test('update, favourite, remove, list filters and order', () => {
  const { input, bean, grinder } = setup();
  const a = b.createBrew(input, NOW).brew;
  const c = b.createBrew({ ...input, method: 'filter', waterG: 270, yieldG: undefined }, new Date(NOW.getTime() + 1000)).brew;
  assert.deepEqual(b.listBrews().map((x) => x.id), [c.id, a.id]);
  assert.deepEqual(b.listBrews({ method: 'espresso' }).map((x) => x.id), [a.id]);
  assert.equal(b.listBrews({ beanId: bean.id }).length, 2);
  assert.equal(b.listBrews({ beanId: 'nope' }).length, 0);
  assert.equal(b.listBrews({ grinderId: grinder.id }).length, 2);
  assert.equal(b.toggleFavourite(a.id).brew.favourite, true);
  assert.deepEqual(b.listBrews({ favourite: true }).map((x) => x.id), [a.id]);
  const remaining = m.listBeans() && store.getState().bags[0].remainingG;
  assert.equal(b.updateBrew(a.id, { notes: ' fein ', taste: 'sour', doseG: 5 }).brew.notes, 'fein');
  assert.equal(b.getBrew(a.id).doseG, 17);
  assert.equal(store.getState().bags[0].remainingG, remaining);
  assert.equal(b.updateBrew(a.id, { taste: 'bad' }).errors.taste, 'err.taste');
  assert.equal(b.updateBrew('x', {}).ok, false);
  assert.ok(b.removeBrew(a.id).ok);
  assert.equal(b.getBrew(a.id), null);
});

test('time class and summaries', () => {
  const s = store.getState().settings;
  assert.deepEqual(b.brewTimeClass({ method: 'espresso', timeS: 33 }, s), { cls: 'slow', status: 'warn' });
  assert.deepEqual(b.brewTimeClass({ method: 'espresso', timeS: 31 }, { ...s, espressoTimeMaxS: 32 }), { cls: 'in_range', status: 'ok' });
  assert.equal(b.brewTimeClass({ method: 'filter', timeS: 33 }, s).cls, null);
  const e = { method: 'espresso', doseG: 18, yieldG: 36, timeS: 27 };
  assert.equal(b.brewSummary(e, 'de'), '18,0 g → 36,0 g · 1:2,0 · 27 s');
  assert.equal(b.brewSummary(e, 'en'), '18.0 g → 36.0 g · 1:2.0 · 27 s');
  assert.equal(b.brewSummary({ method: 'filter', doseG: 30, waterG: 480, timeS: 210 }, 'de'), '30,0 g → 480 g · 1:16,0 · 03:30');
});

test('pickerBags order, archive, stock, resting flag', () => {
  const { roaster, bean, bag } = setup({ roastDate: '2026-11-10' });
  const bean2 = m.createBean({ name: 'B', roasterId: roaster.id, roastLevel: 'dark' }).item;
  const old = m.createBag({ beanId: bean2.id, roastDate: '2026-10-01', weightG: 100 }, '2026-11-16').item;
  const empty = m.createBag({ beanId: bean2.id, roastDate: '2026-09-01', weightG: 100, remainingG: 0 }, '2026-11-16').item;
  const p = b.pickerBags({ now: NOW });
  assert.deepEqual(p.map((x) => x.bag.id), [old.id, bag.id]);
  assert.deepEqual(p.map((x) => x.disabled), [false, true]);
  assert.equal(p[0].roaster.id, roaster.id);
  assert.ok(!p.some((x) => x.bag.id === empty.id));
  assert.equal(b.pickerBags({ now: NOW, method: 'filter' })[1].disabled, false);
  m.archiveItem('bean', bean.id);
  assert.deepEqual(b.pickerBags({ now: NOW }).map((x) => x.bag.id), [old.id]);
});

test('4.6 recommendationFor with grinder step and direction', () => {
  const brew = { method: 'espresso', taste: 'sour', timeS: 27, grinderSetting: 12 };
  assert.equal(b.recommendationFor({ ...brew, taste: null }, {}), null);
  assert.equal(b.recommendationFor(brew, { stepSize: 1, higherIsFiner: false }).steps[0].params.setting, 11);
  assert.equal(b.recommendationFor(brew, { stepSize: 1, higherIsFiner: true }).steps[0].params.setting, 13);
  assert.equal(b.recommendationFor({ ...brew, grinderSetting: 4 }, { stepSize: 0.5 }).steps[0].params.setting, 3.5);
});

test('guided filter brew, lastDose', () => {
  const { bag, machine, grinder } = setup();
  assert.equal(b.lastDose('filter'), null);
  const r = b.createBrew({ method: 'filter', machineId: machine.id, grinderId: grinder.id, bagId: bag.id, grinderSetting: 0, doseG: 30, waterG: 480, yieldG: null, timeS: 210 }, NOW);
  assert.ok(r.ok);
  assert.equal(r.brew.yieldG, null);
  assert.equal(b.brewSummary(r.brew, 'de'), '30,0 g → 480 g · 1:16,0 · 03:30');
  assert.equal(b.lastDose('filter'), 30);
  assert.equal(b.lastDose('espresso'), null);
  const g = b.createGuidedBrew({ machineId: machine.id, grinderId: grinder.id, bagId: bag.id, doseG: 20, timeS: 180, settings: { filterRatio: 15, bloomFactor: 2 } }, new Date('2026-11-16T13:00:00Z'));
  assert.ok(g.ok, JSON.stringify(g.errors));
  assert.equal(g.brew.waterG, 300);
  assert.equal(g.brew.grinderSetting, 0);
  assert.equal(b.lastDose(), 20);
});
