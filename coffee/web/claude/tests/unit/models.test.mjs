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
const TODAY = '2026-11-16';

beforeEach(() => store.resetState());

const setup = () => {
  const r = m.createRoaster({ name: 'Bohne' }).item;
  const b = m.createBean({ name: 'Alpha', roasterId: r.id, roastLevel: 'medium' }).item;
  return { r, b };
};

test('machine validation and defaults', () => {
  assert.deepEqual(m.createMachine({ name: '  ', type: 'espresso' }).errors, { name: 'err.name' });
  const { item } = m.createMachine({ name: ' Gaggia ', type: 'espresso' });
  assert.equal(item.name, 'Gaggia');
  assert.equal(item.archived, false);
  assert.equal(item.lastBackflushAt, null);
  assert.equal(m.updateMachine(item.id, { name: 'x'.repeat(61) }).errors.name, 'err.name');
});

test('limits count archived too', () => {
  for (let i = 0; i < 10; i++) m.createMachine({ name: `M${i}`, type: 'filter' });
  m.archiveItem('machine', m.listMachines()[0].id);
  assert.deepEqual(m.createMachine({ name: 'x', type: 'filter' }).errors, { _limit: 'err.limit.machine' });
  assert.equal(m.listMachines().length, 9);
  assert.equal(m.listMachines({ includeArchived: true }).length, 10);
  for (let i = 0; i < 10; i++) m.createGrinder({ name: `G${i}`, type: 'hand' });
  assert.equal(m.createGrinder({ name: 'x', type: 'hand' }).errors._limit, 'err.limit.grinder');
});

test('grinder defaults', () => {
  const s = m.createGrinder({ name: 'S', type: 'stepless' }).item;
  assert.equal(s.stepSize, 0.5);
  assert.equal(s.rangeMax, 10);
  assert.equal(s.retentionG, 0.5);
  assert.equal(s.higherIsFiner, false);
  assert.equal(m.createGrinder({ name: 'H', type: 'hand' }).item.stepSize, 1);
  assert.equal(m.createGrinder({ name: 'S2', type: 'stepless', rangeMin: 0, rangeMax: 20 }).item.stepSize, 1);
  assert.equal(m.createGrinder({ name: 'S', type: 'stepless', rangeMin: 5, rangeMax: 5 }).errors.range, 'err.range');
  assert.equal(m.createGrinder({ name: 'H', type: 'hand', stepSize: 0 }).errors.stepSize, 'err.stepSize');
  assert.equal(m.createGrinder({ name: 'H', type: 'hand', retentionG: 5.1 }).errors.retention, 'err.retention');
  assert.equal(m.createGrinder({ name: 'H', type: 'hand', retentionG: 0.25 }).errors.retention, 'err.retention');
});

test('roaster validation', () => {
  assert.equal(m.createRoaster({ name: 'R', url: 'ftp://x' }).errors.url, 'err.url');
  assert.equal(m.createRoaster({ name: 'R', leadTimeDays: 31 }).errors.leadTime, 'err.leadTime');
  assert.equal(m.createRoaster({ name: 'R', leadTimeDays: 1.5 }).errors.leadTime, 'err.leadTime');
  assert.equal(m.createRoaster({ name: 'R', url: 'https://r.de' }).item.leadTimeDays, 3);
});

test('bean and bag validation', () => {
  const { b } = setup();
  assert.equal(m.createBean({ name: 'x', roasterId: 'nope', roastLevel: 'dark' }).errors.roaster, 'err.roaster');
  const bad = m.createBag({ beanId: 'no', roastDate: '2026-11-17', weightG: 0, remainingG: 5 }, TODAY);
  assert.deepEqual(Object.keys(bad.errors).sort(), ['bean', 'remainingG', 'roastDate', 'weightG']);
  assert.equal(m.createBag({ beanId: b.id, roastDate: '2026-11-10', weightG: 250, remainingG: 251 }, TODAY).errors.remainingG, 'err.remainingG');
  const ok = m.createBag({ beanId: b.id, roastDate: '2026-11-10', weightG: 250, price: '9.5' }, TODAY).item;
  assert.equal(ok.remainingG, 250);
  assert.equal(ok.price, 9.5);
  assert.equal(m.createBag({ beanId: b.id, roastDate: '2026-11-10', weightG: 250, price: 1.234 }, TODAY).errors.price, 'err.price');
});

test('listing order and archive', () => {
  const { r } = setup();
  m.createBean({ name: 'Zeta', roasterId: r.id, roastLevel: 'dark' });
  const a = m.createBean({ name: 'Beta', roasterId: r.id, roastLevel: 'dark' }).item;
  assert.deepEqual(m.listBeans().map((x) => x.name), ['Alpha', 'Beta', 'Zeta']);
  m.archiveItem('bean', a.id);
  assert.equal(m.listBeans().length, 2);
  m.restoreItem('bean', a.id);
  assert.equal(m.listBeans().length, 3);
});

test('usage and removal', () => {
  const { r, b } = setup();
  const mach = m.createMachine({ name: 'M', type: 'espresso' }).item;
  const bag = m.createBag({ beanId: b.id, roastDate: '2026-11-01', weightG: 250 }, TODAY).item;
  const st = store.getState();
  st.brews.push({ id: 'b1', machineId: mach.id, bagId: bag.id }, { id: 'b2', machineId: mach.id, bagId: bag.id });
  assert.equal(m.usageCount('machine', mach.id), 2);
  assert.equal(m.usageCount('bean', b.id), 2);
  assert.equal(m.usageCount('roaster', r.id), 2);
  assert.deepEqual(m.removeItem('machine', mach.id), { ok: false, reason: 'inUse', count: 2, messageKey: 'err.inUse.device', canArchive: true });
  assert.equal(m.removeItem('bean', b.id).messageKey, 'err.inUse.item');
  assert.equal(m.removeItem('bag', bag.id).reason, 'inUse');
  assert.equal(m.removeItem('roaster', r.id).reason, 'inUse');
  st.bags[0].remainingG = 0;
  assert.equal(m.removeItem('bag', bag.id).ok, true);
});

test('remove bean cascades bags; roaster with beans refused', () => {
  const { r, b } = setup();
  m.createBag({ beanId: b.id, roastDate: '2026-11-01', weightG: 250 }, TODAY);
  const refused = m.removeItem('roaster', r.id);
  assert.equal(refused.ok, false);
  assert.ok(refused.count >= 1);
  assert.equal(m.removeItem('bean', b.id).ok, true);
  assert.equal(store.getState().bags.length, 0);
  assert.equal(m.removeItem('roaster', r.id).ok, true);
});

test('hue, rest (4.7 example) and beansWithBags', () => {
  assert.equal(m.hueForRoaster('A'), 15 + (65 % 45));
  const { r, b } = setup();
  assert.equal(m.roasterOfBean(b).id, r.id);
  m.createBag({ beanId: b.id, roastDate: '2026-11-10', weightG: 250, remainingG: 100 }, TODAY);
  m.createBag({ beanId: b.id, roastDate: '2026-10-01', weightG: 250, remainingG: 50 }, TODAY);
  const [row] = m.beansWithBags({ today: TODAY });
  assert.equal(row.stockG, 150);
  assert.deepEqual(row.bags.map((x) => x.roastDate), ['2026-10-01', '2026-11-10']);
  assert.equal(row.bags[0].rest.status, 'past_peak');
  assert.equal(row.bags[1].rest.status, 'resting');
  assert.equal(row.bags[1].rest.readyOn, '2026-11-17');
  assert.equal(row.hue, m.hueForRoaster('Bohne'));
});

test('water CRUD, validation and usage', () => {
  assert.deepEqual(m.createWater({ name: '' }).errors, { name: 'err.name' });
  assert.deepEqual(m.createWater({ name: 'x', tdsMgL: -1, hardnessPpm: 'abc', ph: 15 }).errors, { tdsMgL: 'err.number', hardnessPpm: 'err.number', ph: 'err.ph' });
  assert.equal(m.createWater({ name: 'x', ph: -1 }).errors.ph, 'err.number');
  const { item } = m.createWater({ name: ' Brita ', tdsMgL: '120', ph: 7.2 });
  assert.equal(item.name, 'Brita');
  assert.equal(item.tdsMgL, 120);
  assert.equal(item.hardnessPpm, null);
  assert.equal(m.createWater({ name: 'a', ph: 0 }).ok, true);
  assert.equal(m.updateWater(item.id, { alkalinityPpm: 90 }).item.alkalinityPpm, 90);
  assert.equal(m.updateWater(item.id, { ph: 20 }).ok, false);
  assert.deepEqual(m.listWaters().map((w) => w.name), ['a', 'Brita']);
  store.getState().brews.push({ id: 'b', waterId: item.id });
  assert.equal(m.usageCount('water', item.id), 1);
  const r = m.removeItem('water', item.id);
  assert.equal(r.ok, false);
  assert.equal(r.reason, 'inUse');
  store.getState().brews = [];
  assert.equal(m.removeItem('water', item.id).ok, true);
  assert.equal(m.listWaters().length, 1);
});
