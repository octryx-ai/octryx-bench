import test from 'node:test';
import assert from 'node:assert/strict';

const mem = new Map();
globalThis.localStorage = {
  getItem: (k) => (mem.has(k) ? mem.get(k) : null),
  setItem: (k, v) => mem.set(k, String(v)),
  removeItem: (k) => mem.delete(k),
};
const s = await import('../../src/js/store.js');

test('first load writes key and has 14 default settings', () => {
  mem.clear();
  const st = s.loadState();
  assert.ok(mem.has(s.STORAGE_KEY));
  assert.equal(Object.keys(st.settings).length, 14);
  assert.equal(st.version, 1);
  assert.deepEqual(st.brews, []);
});

test('corrupt storage falls back to empty state', () => {
  mem.set(s.STORAGE_KEY, '{nope');
  assert.equal(s.loadState().settings.espressoTimeMinS, 25);
});

test('partial settings are merged with defaults', () => {
  mem.set(s.STORAGE_KEY, JSON.stringify({ version: 1, settings: { theme: 'dark' } }));
  const st = s.loadState();
  assert.equal(st.settings.theme, 'dark');
  assert.equal(st.settings.bloomFactor, 2);
});

test('throwing localStorage is tolerated', () => {
  const saved = globalThis.localStorage;
  globalThis.localStorage = { getItem() { throw new Error('x'); }, setItem() { throw new Error('x'); } };
  assert.equal(s.loadState().version, 1);
  s.updateSettings({ theme: 'light' });
  globalThis.localStorage = saved;
});

test('updateSettings persists and notifies; unsubscribe works', () => {
  s.resetState();
  let calls = 0;
  const off = s.subscribe(() => calls++);
  s.updateSettings({ filterRatio: 15 });
  assert.equal(calls, 1);
  assert.equal(JSON.parse(mem.get(s.STORAGE_KEY)).settings.filterRatio, 15);
  off();
  s.updateSettings({ filterRatio: 16 });
  assert.equal(calls, 1);
});

test('export/import round trip and validation', () => {
  s.resetState();
  const text = s.exportJson();
  const obj = JSON.parse(text);
  obj.machines.push({ id: 'm1' });
  s.importJson(JSON.stringify(obj));
  assert.equal(s.getState().machines.length, 1);
  assert.throws(() => s.importJson('{"version":2}'), { message: 'Ungültige Datei' });
  assert.throws(() => s.importJson('garbage'), { message: 'Ungültige Datei' });
});

test('exportFilename', () => {
  assert.equal(s.exportFilename(new Date('2026-03-05T10:00:00Z')), 'coffee-export-2026-03-05.json');
  assert.match(s.exportFilename(), /^coffee-export-\d{4}-\d{2}-\d{2}\.json$/);
});

test('importJson rejects missing arrays and bad settings, keeps state', () => {
  s.resetState();
  const ok = JSON.parse(s.exportJson());
  const before = s.exportJson();
  for (const bad of [{ ...ok, brews: undefined }, { ...ok, machines: {} }, { ...ok, settings: [] }, [], null, 'x']) {
    assert.throws(() => s.importJson(JSON.stringify(bad)), { message: 'Ungültige Datei' });
  }
  assert.equal(s.exportJson(), before);
});

test('validateSettings', () => {
  s.resetState();
  assert.deepEqual(s.validateSettings({ filterRatio: 15, theme: 'dark', language: 'en' }), {});
  const e = s.validateSettings({ filterRatio: 0, backflushDays: 'x', theme: 'pink', language: 'fr', bloomFactor: -1, plannedShotsPerDay: '' });
  assert.deepEqual(Object.keys(e).sort(), ['backflushDays', 'bloomFactor', 'filterRatio', 'language', 'plannedShotsPerDay', 'theme']);
  assert.equal(e.filterRatio, 'err.setting.filterRatio');
  assert.deepEqual(s.validateSettings({ espressoTimeMinS: 30 }), { espressoTimeMinS: 'err.setting.espressoTimeMinS' });
  assert.deepEqual(s.validateSettings({ espressoTimeMinS: 20, espressoTimeMaxS: 35 }), {});
  assert.ok(s.validateSettings({ espressoTimeMaxS: 25 }).espressoTimeMaxS);
});

test('saveSettings validates and coerces numbers', () => {
  s.resetState();
  const bad = s.saveSettings({ filterRatio: 99 });
  assert.equal(bad.ok, false);
  assert.equal(s.getState().settings.filterRatio, 16);
  assert.equal(s.saveSettings({ filterRatio: '15' }).ok, true);
  assert.equal(s.getState().settings.filterRatio, 15);
});
