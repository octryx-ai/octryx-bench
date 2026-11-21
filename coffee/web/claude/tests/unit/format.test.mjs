import test from 'node:test';
import assert from 'node:assert/strict';

globalThis.localStorage = { getItem: () => null, setItem() {} };
const f = await import('../../src/js/format.js');

test('numbers and grams per language', () => {
  assert.equal(f.formatGrams(18, 'de'), '18,0 g');
  assert.equal(f.formatGrams(18, 'en'), '18.0 g');
  assert.equal(f.formatNumber(2.5, 2, 'de'), '2,50');
  assert.equal(f.formatNumber(2.5, 0, 'en'), '3');
});

test('seconds', () => {
  assert.equal(f.formatSeconds(27, 'de'), '27 s');
  assert.equal(f.formatSeconds(27.5, 'de'), '27,5 s');
});

test('dates', () => {
  assert.equal(f.formatDate('2026-11-17', 'de'), '17.11.');
  assert.equal(f.formatDate('2026-11-17', 'en'), '17 Nov');
});

test('timer', () => {
  assert.equal(f.formatTimer(0), '00:00.0');
  assert.equal(f.formatTimer(27300), '00:27.3');
  assert.equal(f.formatTimer(65400), '01:05.4');
});
