import test from 'node:test';
import assert from 'node:assert/strict';
import { classifyTime, timeClassStatus, recommend, restStatus, evaluateWater } from '../../src/js/rules/index.js';

test('4.2 time classes', () => {
  assert.equal(classifyTime(19), 'too_fast');
  assert.equal(classifyTime(22), 'fast');
  assert.equal(classifyTime(27), 'in_range');
  assert.equal(classifyTime(33), 'slow');
  assert.equal(classifyTime(36), 'too_slow');
  assert.equal(classifyTime(31, { espressoTimeMaxS: 32 }), 'in_range');
  assert.equal(classifyTime(38, { espressoTimeMaxS: 32 }), 'too_slow');
  assert.equal(timeClassStatus('slow'), 'warn');
  assert.equal(timeClassStatus('too_fast'), 'error');
  assert.equal(timeClassStatus('in_range'), 'ok');
});

const stepped = { stepSize: 1, higherIsFiner: false };
const first = (r) => r.steps[0];

test('4.6 recommendations', () => {
  let r = recommend({ method: 'espresso', taste: 'sour', timeS: 27, grinderSetting: 12 }, stepped);
  assert.equal(first(r).key, 'rec.grindFiner');
  assert.equal(first(r).params.setting, 11);
  assert.equal(r.steps.length, 2); // time >= 25 -> also temperature
  r = recommend({ method: 'espresso', taste: 'sour', timeS: 27, grinderSetting: 4 }, { stepSize: 0.5, higherIsFiner: false });
  assert.equal(first(r).params.setting, 3.5);
  r = recommend({ method: 'espresso', taste: 'sour', timeS: 27, grinderSetting: 12 }, { stepSize: 1, higherIsFiner: true });
  assert.equal(first(r).params.setting, 13);
  r = recommend({ method: 'espresso', taste: 'sour', timeS: 19, grinderSetting: 12 }, stepped);
  assert.equal(first(r).key, 'rec.grindFinerFast');
  assert.deepEqual([r.steps[0].params.timeS, r.steps[0].params.limitS], [19, 20]);
  r = recommend({ method: 'espresso', taste: 'bitter', timeS: 33, grinderSetting: 12 }, stepped);
  assert.equal(first(r).key, 'rec.grindCoarser');
  assert.equal(first(r).params.setting, 13);
  r = recommend({ method: 'espresso', taste: 'bitter', timeS: 19, grinderSetting: 12 }, stepped);
  assert.equal(first(r).key, 'rec.grindCoarser'); // bitter not overridden by too_fast
  r = recommend({ method: 'filter', taste: 'weak', timeS: 180, grinderSetting: 12 }, stepped, { filterRatio: 16 });
  assert.deepEqual([first(r).params.from, first(r).params.to], [16, 15]);
  r = recommend({ method: 'espresso', taste: 'balanced', timeS: 27, grinderSetting: 12 }, stepped);
  assert.ok(r.keep && r.favouriteOffer);
  assert.deepEqual(recommend({ method: 'espresso', timeS: 27, grinderSetting: 12 }, stepped).steps, []);
});

test('4.7 rest period', () => {
  const r = restStatus({ roastDate: '2026-11-10', roastLevel: 'medium', method: 'espresso' }, '2026-11-16');
  assert.equal(r.status, 'resting');
  assert.equal(r.daysSinceRoast, 6);
  assert.equal(r.daysToGo, 1);
  assert.equal(r.readyOn, '2026-11-17');
  assert.equal(r.peakEndsOn, '2026-12-01');
  const at = (d, lvl = 'medium', m = 'espresso') => restStatus({ roastDate: '2026-11-10', roastLevel: lvl, method: m }, d).status;
  assert.equal(at('2026-11-17'), 'ready');
  assert.equal(at('2026-12-01'), 'ready');
  assert.equal(at('2026-12-02'), 'past_peak');
  assert.equal(at('2026-11-11', 'dark', 'filter'), 'ready');
  assert.equal(at('2026-11-16', 'light', 'espresso'), 'resting');
});

test('4.9 water evaluation', () => {
  const r = evaluateWater({ tdsMgL: 120, hardnessPpm: 136, alkalinityPpm: 90, ph: 7.2, chlorineMgL: null });
  assert.equal(r.tdsMgL.status, 'ok');
  assert.equal(r.hardnessPpm.status, 'ok');
  assert.equal(r.alkalinityPpm.status, 'warn');
  assert.equal(r.alkalinityPpm.messageKey, 'water.alkalinityPpm.high');
  assert.equal(r.ph.status, 'ok');
  assert.equal(r.chlorineMgL.status, 'none');
  assert.equal(evaluateWater({ chlorineMgL: 0.3 }).chlorineMgL.status, 'warn');
  assert.equal(evaluateWater({ ph: 6 }).ph.messageKey, 'water.ph.low');
});

test('4.3 filter stages', async () => {
  const { filterStages } = await import('../../src/js/rules/index.js');
  assert.deepEqual(filterStages(30, { filterRatio: 16, bloomFactor: 2 }), {
    totalG: 480,
    stages: [{ kind: 'bloom', targetG: 60 }, { kind: 'pour', targetG: 270 }, { kind: 'pour', targetG: 480 }],
  });
  assert.equal(filterStages(30).totalG, 480);
  const r = filterStages(15, { filterRatio: 17, bloomFactor: 3 });
  assert.deepEqual(r.stages.map((s) => s.targetG), [45, 150, 255]);
});
