// Guided filter brew (SPEC UI screen 4, focus mode): pickers, dose, then one big number per stage with a running timer.
import { h } from '../dom.js';
import { icon } from '../icons.js';
import { t } from '../i18n.js';
import { button, field, showToast } from '../ui.js';
import { createForm, parseNum } from '../forms.js';
import { formatNumber, formatTimer } from '../format.js';
import { getState } from '../store.js';
import { navigate } from '../router.js';
import * as M from '../models.js';
import * as B from '../brews.js';
import { filterStages } from '../rules/index.js';
import { makeView, fmtNum } from './common.js';
import { fillBagSelect } from './brew-parts.js';

const DEFAULT_DOSE = 30;
const MAX_TIME_S = 600;
const fresh = () => ({ step: 'pre', machineId: '', grinderId: '', bagId: '', setting: null, doseText: '', error: '', stages: [], stage: 0, startedAt: 0 });
const S = fresh();
let tickHandle = null;

export function resetGuided() {
  clearInterval(tickHandle);
  tickHandle = null;
  Object.assign(S, fresh());
}

const elapsedMs = () => performance.now() - S.startedAt;
const grams = (n) => `${fmtNum(n)} g`;

function cancelLink() {
  return h('a', { class: 'btn btn--ghost guided__cancel', href: '#/', 'data-testid': 'guided-cancel' }, icon('close'), h('span', null, t('action.cancel')));
}

function frame(...kids) {
  return [h('h1', { class: 'sr-only' }, t('screen.guided')), h('div', { class: 'guided__top' }, cancelLink(), kids.shift()), ...kids];
}

// ---- pre-step: machine, grinder, bag ----
function preStep(paint) {
  const lastBrew = B.listBrews({ method: 'filter' })[0] || null;
  const machines = M.listMachines().sort((a, b) => (b.type === 'filter') - (a.type === 'filter'));
  const grinders = M.listGrinders();
  const entries = B.pickerBags({ now: new Date(), method: 'filter' });
  const pick = (list, ...ids) => ids.find((id) => list.some((x) => x.id === id)) ?? list[0]?.id ?? '';
  S.machineId = pick(machines, S.machineId, lastBrew?.machineId);
  S.grinderId = pick(grinders, S.grinderId, lastBrew?.grinderId);
  if (S.setting === null) S.setting = lastBrew ? fmtNum(lastBrew.grinderSetting) : '';

  const f = createForm();
  const placeholder = [['', t('form.pick')]];
  const machineField = f.select('machineId', t('form.machine'), machines.length ? machines.map((m) => [m.id, m.name]) : placeholder, S.machineId);
  const grinderField = f.select('grinderId', t('form.grinder'), grinders.length ? grinders.map((g) => [g.id, g.name]) : placeholder, S.grinderId);
  const hint = (text, linkText, href) => h('p', { class: 'field__hint' }, text, ' ', h('a', { href, class: 'link-touch' }, linkText));
  if (!machines.length) machineField.append(hint(t('form.noMachine'), t('form.addDevice'), '#/equipment'));
  if (!grinders.length) grinderField.append(hint(t('form.noGrinder'), t('form.addDevice'), '#/equipment'));
  const settingField = f.text('grinderSetting', t('form.setting'), { value: S.setting, inputmode: 'decimal' });

  let bagField;
  if (!entries.length) {
    bagField = h('div', { class: 'field' },
      h('div', { class: 'notice-inline', role: 'status', 'data-testid': 'no-bag-notice' }, icon('alert', 'icon--sm'),
        h('span', null, t('form.noBag'), ' ', h('a', { href: '#/beans', class: 'link-touch', 'data-testid': 'no-bag-link' }, t('form.noBagLink')))));
  } else {
    bagField = f.select('bagId', t('form.bag'), placeholder, '');
    fillBagSelect(f.controls.bagId, entries, S.bagId || lastBrew?.bagId);
    S.bagId = f.controls.bagId.value;
  }

  const ready = machines.length && grinders.length && entries.some((e) => !e.disabled);
  const form = h('form', {
    class: 'guided__pre', novalidate: true, 'data-testid': 'guided-pre',
    onSubmit: (e) => { e.preventDefault(); S.step = 'dose'; paint(); },
    onChange: () => {
      S.machineId = f.val('machineId');
      S.grinderId = f.val('grinderId');
      S.setting = f.str('grinderSetting');
      if (f.controls.bagId) S.bagId = f.val('bagId');
    },
  }, h('h2', { class: 'guided__title' }, t('guided.pre.title')), machineField, grinderField, settingField, bagField,
  button({ label: t('guided.next'), variant: 'primary', type: 'submit', testid: 'guided-start', disabled: !ready }));
  form.addEventListener('input', () => { S.setting = f.str('grinderSetting'); });
  return frame(h('span'), form);
}

// ---- step 1: dose ----
function doseStep(paint) {
  const last = B.lastDose('filter');
  if (!S.doseText) S.doseText = fmtNum(last ?? DEFAULT_DOSE);
  const err = S.error;
  const fld = field({ label: t('form.dose'), value: S.doseText, unit: 'g', inputmode: 'decimal', error: err, testid: 'guided-dose' });
  const form = h('form', {
    class: 'guided__dose', novalidate: true, onSubmit: (e) => {
      e.preventDefault();
      const dose = parseNum(fld.querySelector('input').value);
      S.doseText = fld.querySelector('input').value;
      if (!(dose >= 1 && dose <= 60)) { S.error = t('err.dose'); paint(); return; }
      S.error = '';
      S.stages = filterStages(dose, getState().settings).stages;
      S.stage = 0;
      S.startedAt = performance.now();
      S.step = 'stage';
      S.dose = dose;
      paint();
    },
  }, h('h2', { class: 'guided__title' }, t('guided.dose.title')), fld,
  button({ label: t('guided.next'), variant: 'primary', type: 'submit', testid: 'guided-next' }));
  return frame(h('span'), form);
}

// ---- stages ----
function stageText(i) {
  if (i >= S.stages.length) return t('guided.stage.done');
  const s = S.stages[i];
  return t(s.kind === 'bloom' ? 'guided.stage.bloom' : 'guided.stage.pour', { g: fmtNum(s.targetG) });
}

function save(paint) {
  const timeS = Math.min(MAX_TIME_S, Math.round(elapsedMs() / 100) / 10);
  clearInterval(tickHandle);
  const res = B.createGuidedBrew({
    machineId: S.machineId, grinderId: S.grinderId, grinderSetting: S.setting, bagId: S.bagId, doseG: S.dose, timeS,
  });
  if (!res.ok) {
    S.error = Object.values(res.errors).map((k) => (typeof k === 'string' ? t(k) : t('err.generic'))).join(' ');
    paint();
    return;
  }
  const id = res.brew.id;
  resetGuided();
  showToast('success', t('toast.brewSaved'));
  if (res.warning) showToast('warn', t(res.warning.key, { x: fmtNum(res.warning.params.x) }));
  navigate('/brews/new?brew=' + id);
}

function stageStep(paint) {
  const n = S.stages.length;
  const done = S.stage >= n;
  const total = S.stages[n - 1].targetG;
  const target = done ? total : S.stages[S.stage].targetG;

  const display = h('span', { class: 'guided__time', 'aria-hidden': 'true' }, formatTimer(elapsedMs()));
  const timer = h('div', { class: 'guided__timer', 'data-testid': 'guided-timer', role: 'timer', 'aria-live': 'polite', 'aria-label': t('guided.timer') },
    display, h('span', { class: 'sr-only' }, t('guided.timerRunning', { stage: stageText(S.stage) })));
  clearInterval(tickHandle);
  tickHandle = setInterval(() => {
    if (!display.isConnected) { clearInterval(tickHandle); return; }
    display.textContent = formatTimer(elapsedMs());
  }, 100);

  const number = h('div', { class: 'guided__number', 'data-testid': 'guided-number', 'data-target': String(target) },
    formatNumber(target, Number.isInteger(target) ? 0 : 1), h('span', { class: 'guided__unit' }, ' g'));
  const next = button({
    label: t(done ? 'guided.finish' : 'guided.next'), variant: 'primary', testid: 'guided-next',
    onClick: () => { if (done) save(paint); else { S.stage += 1; paint(); } },
  });
  next.classList.add('guided__next');
  return frame(timer,
    h('div', { class: 'guided__main' },
      h('p', { class: 'guided__label', 'data-testid': 'guided-label' }, stageText(S.stage)),
      number,
      h('p', { class: 'guided__target', 'data-testid': 'guided-target' },
        t('guided.progress', { n: Math.min(S.stage + 1, n), of: n, total: grams(total) })),
      S.error && h('p', { class: 'field__error', role: 'alert', 'data-testid': 'guided-error' }, icon('alert', 'icon--sm'), S.error)),
    next);
}

function build(_state, paint) {
  const kids = S.step === 'pre' ? preStep(paint) : S.step === 'dose' ? doseStep(paint) : stageStep(paint);
  return [h('div', { class: 'guided__inner', 'data-step': S.step }, kids)];
}

const view = makeView(build);
export function renderGuided(route) {
  const el = view(route);
  el.classList.add('guided');
  return el;
}
