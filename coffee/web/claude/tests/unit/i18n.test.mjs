import test from 'node:test';
import assert from 'node:assert/strict';

const mem = new Map();
globalThis.localStorage = { getItem: (k) => mem.get(k) ?? null, setItem: (k, v) => mem.set(k, String(v)) };
const { t, getLang, setLang, onLangChange } = await import('../../src/js/i18n.js');
const { getState } = await import('../../src/js/store.js');
const de = (await import('../../src/js/locales/de.js')).default;
const en = (await import('../../src/js/locales/en.js')).default;

test('de/en key parity', () => {
  const d = Object.keys(de).sort();
  const e = Object.keys(en).sort();
  assert.deepEqual(d.filter((k) => !(k in en)), [], 'missing in en');
  assert.deepEqual(e.filter((k) => !(k in de)), [], 'missing in de');
});

test('t falls back to the key and fills placeholders', () => {
  assert.equal(t('__unknown.key__'), '__unknown.key__');
  setLang('de');
  const key = Object.keys(de).find((k) => de[k].includes('{name}'));
  if (key) assert.ok(!t(key, { name: 'X' }).includes('{name}'));
});

test('setLang updates store, listeners and getLang', () => {
  let got = null;
  const off = onLangChange((l) => (got = l));
  setLang('en');
  assert.equal(getLang(), 'en');
  assert.equal(getState().settings.language, 'en');
  assert.equal(got, 'en');
  off();
  setLang('de');
  assert.equal(getLang(), 'de');
});
