// Brew form (SPEC UI screen 3): fields, live preview (ratio, time class, purge, recommendation), timer, sticky save bar.
import { h } from '../dom.js';
import { icon } from '../icons.js';
import { t } from '../i18n.js';
import { button, pageHeader, showToast } from '../ui.js';
import { createForm, parseNum } from '../forms.js';
import { errorBox } from '../dialog.js';
import { formatNumber } from '../format.js';
import { getState } from '../store.js';
import { navigate, queryParam } from '../router.js';
import { renderTasteForm } from './brew-taste.js';
import * as M from '../models.js';
import * as B from '../brews.js';
import { createTimer } from '../timer.js';
import { fmtNum } from './common.js';
import { TASTES, timeClassChip, recommendationPanel, recFor, favButton, fillBagSelect } from './brew-parts.js';

const DEFAULT_DOSE = 18;
const DEFAULT_YIELD = 36;
const g1 = (n) => formatNumber(n, 1);
const gOut = (n, method) => (method === 'filter' ? formatNumber(n, 0) : g1(n));
const roundTo = (n, d = 2) => Math.round(n * 10 ** d) / 10 ** d;

/** Number field with minus/plus buttons and a unit suffix; the buttons fire a bubbling input event. */
function stepperField(f, name, label, { value, unit, step, dec = 1, hidden }) {
  const el = f.text(name, label, { value, unit, inputmode: 'decimal', hidden });
  const input = f.controls[name];
  const bump = (d) => () => {
    const n = parseNum(input.value);
    const next = Math.max(0, roundTo((Number.isFinite(n) ? n : 0) + d));
    input.value = formatNumber(next, dec);
    input.dispatchEvent(new Event('input', { bubbles: true }));
  };
  const btn = (d, ic, key) => h('button', {
    type: 'button', class: 'btn btn--secondary stepper__btn', 'aria-label': t(key, { label }), onClick: bump(d),
  }, icon(ic));
  const wrap = el.querySelector('.input-wrap');
  const group = h('div', { class: 'stepper stepper--field' }, btn(-step, 'minus', 'form.stepDec'), wrap, btn(step, 'plus', 'form.stepInc'));
  el.querySelector('label').after(group);
  return el;
}

function linkHint(text, linkText, href) {
  return h('p', { class: 'field__hint' }, text, ' ', h('a', { href, class: 'link-touch' }, linkText));
}

export function renderBrewForm(route) {
  const tasteId = queryParam('brew');
  if (tasteId && B.getBrew(tasteId)) return renderTasteForm(route, tasteId);
  const state = getState();
  const settings = state.settings;
  const last = B.listBrews()[0] || null;
  const f = createForm();
  const machines = M.listMachines();
  const grinders = M.listGrinders();
  const waters = state.waters.filter((w) => !w.archived);
  const pick = (list, id) => (list.some((x) => x.id === id) ? id : list[0]?.id ?? '');
  const placeholder = [['', t('form.pick')]];

  let method = last?.method || 'espresso';
  let taste = '';
  let favourite = false;

  // ---- method (segmented) ----
  const segBtn = (m) => h('button', {
    type: 'button', class: 'segmented__btn', 'aria-pressed': m === method ? 'true' : 'false', 'data-testid': 'method-' + m,
    onClick: () => setMethod(m),
  }, t('method.' + m));
  const methodGroup = h('div', { class: 'segmented', role: 'group', 'aria-labelledby': 'method-label', 'data-testid': 'field-method' },
    segBtn('espresso'), segBtn('filter'));
  const guidedLink = h('a', { href: '#/guided', class: 'link-touch', 'data-testid': 'link-guided', hidden: method !== 'filter' }, icon('cone', 'icon--sm'), t('form.guidedLink'));
  const methodField = h('div', { class: 'field' }, h('span', { class: 'field__label', id: 'method-label' }, t('form.method')), methodGroup, guidedLink);

  // ---- selects ----
  const machineField = f.select('machineId', t('form.machine'),
    machines.length ? machines.map((m) => [m.id, m.name]) : placeholder, pick(machines, last?.machineId));
  if (!machines.length) machineField.append(linkHint(t('form.noMachine'), t('form.addDevice'), '#/equipment'));
  const grinderField = f.select('grinderId', t('form.grinder'),
    grinders.length ? grinders.map((x) => [x.id, x.name]) : placeholder, pick(grinders, last?.grinderId));
  if (!grinders.length) grinderField.append(linkHint(t('form.noGrinder'), t('form.addDevice'), '#/equipment'));

  const settingField = f.text('grinderSetting', t('form.setting'), { value: last ? fmtNum(last.grinderSetting) : '', inputmode: 'decimal' });

  // bag picker (resting bags are disabled with their ready date)
  const bagEntries = () => B.pickerBags({ now: new Date(), method });
  const noBag = bagEntries().length === 0;
  let bagField;
  if (noBag) {
    bagField = h('div', { class: 'field' },
      h('div', { class: 'notice-inline', role: 'status', 'data-testid': 'no-bag-notice' },
        icon('alert', 'icon--sm'),
        h('span', null, t('form.noBag'), ' ', h('a', { href: '#/beans', class: 'link-touch', 'data-testid': 'no-bag-link' }, t('form.noBagLink')))));
  } else {
    bagField = f.select('bagId', t('form.bag'), placeholder, '');
  }

  function fillBags(keep) {
    if (f.controls.bagId) fillBagSelect(f.controls.bagId, bagEntries(), keep);
  }
  fillBags(last?.bagId);

  const waterField = f.select('waterId', t('form.waterProfile'),
    [['', t('form.noWater')], ...waters.map((w) => [w.id, w.name])], last?.waterId ?? '');

  // ---- numbers ----
  const dose0 = last?.doseG ?? DEFAULT_DOSE;
  const doseField = stepperField(f, 'doseG', t('form.dose'), { value: g1(dose0), unit: 'g', step: 0.5 });
  const yieldField = stepperField(f, 'yieldG', t('form.yield'), { value: g1(last?.yieldG ?? DEFAULT_YIELD), unit: 'g', step: 1, hidden: method === 'filter' });
  const waterGField = stepperField(f, 'waterG', t('form.waterG'),
    { value: formatNumber(last?.waterG ?? dose0 * (settings.filterRatio ?? 16), 0), unit: 'g', step: 10, dec: 0, hidden: method !== 'filter' });

  const timeField = f.text('timeS', t('form.time'), { value: '', unit: 's', inputmode: 'decimal' });
  const timer = createTimer({
    compact: true,
    onStop: (s) => {
      f.controls.timeS.value = formatNumber(s, 1);
      f.controls.timeS.dispatchEvent(new Event('input', { bubbles: true }));
    },
  });
  const tempField = f.text('tempC', t('form.temp'), { value: last?.tempC != null ? fmtNum(last.tempC) : '', unit: '°C', inputmode: 'decimal' });

  // ---- taste chips ----
  const tasteBtns = TASTES.map((k) => h('button', {
    type: 'button', class: 'taste-chip', 'aria-pressed': 'false', 'data-testid': 'taste-' + k,
    onClick: () => { taste = taste === k ? '' : k; paintTaste(); update(); },
  }, t('taste.' + k)));
  const tasteField = h('div', { class: 'field' },
    h('span', { class: 'field__label', id: 'taste-label' }, t('form.taste')),
    h('div', { class: 'taste-group', role: 'group', 'aria-labelledby': 'taste-label', 'data-testid': 'field-taste' }, tasteBtns));
  function paintTaste() {
    tasteBtns.forEach((b, i) => b.setAttribute('aria-pressed', TASTES[i] === taste ? 'true' : 'false'));
  }

  const notesField = f.textarea('notes', t('form.notes'));

  // ---- preview ----
  const previewRatio = h('p', { class: 'preview__ratio', 'data-testid': 'preview-ratio' });
  const previewShot = h('p', { class: 'stat', 'data-testid': 'preview-shot' });
  const previewClass = h('div', { class: 'preview__class' });
  const purgeText = h('span', { 'data-testid': 'purge-text' });
  const purgeTotal = h('span', { class: 'stat', 'data-testid': 'purge-total' });
  const purgeBox = h('div', { class: 'purge', 'data-testid': 'purge-advice', hidden: true }, icon('info', 'icon--sm'), h('div', { class: 'purge__text' }, purgeText, purgeTotal));
  const recSlot = h('div', { class: 'preview__rec' });
  const favBtn = favButton({ pressed: false, onClick: () => { favourite = !favourite; favBtn.setAttribute('aria-pressed', favourite ? 'true' : 'false'); } });
  const preview = h('aside', { class: 'card brew-preview', 'aria-label': t('preview.title') },
    h('h2', { class: 'preview__title' }, t('preview.title')), previewRatio, previewShot, previewClass, purgeBox, recSlot);

  function update() {
    const dose = f.num('doseG');
    const out = method === 'filter' ? f.num('waterG') : f.num('yieldG');
    const timeS = f.num('timeS');
    const ok = dose > 0 && out > 0;
    previewRatio.textContent = ok ? `${g1(dose)} → ${gOut(out, method)} · ${B.ratioText(dose, out)}` : '–';

    const grinder = state.grinders.find((x) => x.id === f.val('grinderId'));
    const bag = state.bags.find((b) => b.id === f.val('bagId'));

    // 4.2 time class, espresso only
    previewClass.replaceChildren();
    if (method === 'espresso' && Number.isFinite(timeS) && timeS >= 0 && timeS <= 600) {
      previewClass.append(timeClassChip(B.brewTimeClass({ method, timeS }, settings), 'preview-timeclass'));
    }

    // shot number (4.6): earlier espresso brews with this bean and grinder, plus this one
    previewShot.hidden = !(method === 'espresso' && bag && grinder);
    if (!previewShot.hidden) {
      const beanOf = (bagId) => state.bags.find((b) => b.id === bagId)?.beanId;
      const n = state.brews.filter((b) => b.method === 'espresso' && b.grinderId === grinder.id && beanOf(b.bagId) === bag.beanId).length + 1;
      previewShot.textContent = t('preview.shot', { n });
    }

    // 4.5 purge advice
    const purge = grinder && bag ? B.purgeAdvice({ grinder, beanId: bag.beanId, now: new Date(), settings }) : 0;
    purgeBox.hidden = !(purge > 0);
    if (purge > 0) {
      purgeText.textContent = t('preview.purge', { g: g1(purge) });
      purgeTotal.textContent = Number.isFinite(dose) ? t('preview.purgeTotal', { g: g1(dose + purge) }) : '';
    }

    // 4.6 recommendation (only after a taste is chosen)
    const rec = taste ? recFor({ method, taste, timeS, grinderSetting: f.num('grinderSetting') }, grinder) : null;
    const panel = recommendationPanel(rec, favBtn);
    recSlot.replaceChildren(...(panel ? [panel] : []));
  }

  function updateSettingLabel() {
    const grinder = state.grinders.find((x) => x.id === f.val('grinderId'));
    settingField.querySelector('label').textContent = t('form.setting') + (grinder?.settingUnit ? ` (${grinder.settingUnit})` : '');
  }

  function setMethod(m) {
    method = m;
    methodGroup.querySelectorAll('button').forEach((b) => b.setAttribute('aria-pressed', b.dataset.testid === 'method-' + m ? 'true' : 'false'));
    guidedLink.hidden = m !== 'filter';
    yieldField.hidden = m === 'filter';
    waterGField.hidden = m !== 'filter';
    if (m === 'filter' && !f.str('waterG')) f.controls.waterG.value = formatNumber((f.num('doseG') || DEFAULT_DOSE) * (settings.filterRatio ?? 16), 0);
    if (m === 'espresso' && !f.str('yieldG')) f.controls.yieldG.value = g1(DEFAULT_YIELD);
    f.clearErrors();
    fillBags();
    update();
  }

  // ---- save ----
  const box = errorBox();
  const saveBtn = button({ label: t('action.save'), variant: 'primary', type: 'submit', testid: 'save-brew', disabled: noBag });
  const cancelBtn = button({ label: t('action.cancel'), variant: 'secondary', href: '#/brews', testid: 'cancel-brew' });

  function submit(e) {
    e.preventDefault();
    box.clear();
    f.clearErrors();
    const espresso = method === 'espresso';
    const res = B.createBrew({
      method,
      machineId: f.val('machineId'),
      grinderId: f.val('grinderId'),
      grinderSetting: f.num('grinderSetting'),
      bagId: f.val('bagId'),
      waterId: f.val('waterId'),
      doseG: f.num('doseG'),
      yieldG: espresso ? f.num('yieldG') : undefined,
      waterG: espresso ? undefined : f.num('waterG'),
      timeS: f.num('timeS'),
      tempC: f.num('tempC'),
      taste,
      notes: f.str('notes'),
    });
    if (!res.ok) {
      const { leftover, firstBad } = f.setErrors(res.errors);
      if (leftover.length) box.show(leftover);
      firstBad?.focus();
      return;
    }
    if (favourite && res.brew.taste === 'balanced') B.toggleFavourite(res.brew.id);
    showToast('success', t('toast.brewSaved'));
    if (res.warning) showToast('warn', t(res.warning.key, { x: fmtNum(res.warning.params.x) }));
    navigate('/brews');
  }

  const form = h('form', { class: 'brew-form', novalidate: true, 'data-testid': 'brew-form', onSubmit: submit },
    h('div', { class: 'brew-layout' },
      h('div', { class: 'card brew-fields' },
        methodField,
        h('div', { class: 'field-grid' }, machineField, grinderField),
        h('div', { class: 'field-grid' }, settingField, tempField),
        bagField,
        waterField,
        h('div', { class: 'field-grid' }, doseField, yieldField, waterGField),
        h('div', { class: 'time-group' }, timeField, timer.el),
        tasteField,
        notesField),
      preview),
    h('div', { class: 'save-bar' }, box, h('div', { class: 'save-bar__actions' }, cancelBtn, saveBtn)));

  const onEdit = (e) => {
    const id = e.target.getAttribute?.('data-testid') || '';
    if (id.startsWith('field-')) f.clearError(id.slice(6));
    if (id === 'field-grinderId') updateSettingLabel();
    update();
  };
  form.addEventListener('input', onEdit);
  form.addEventListener('change', onEdit);

  updateSettingLabel();
  update();
  return h('div', { class: 'page', 'data-testid': route.testid }, pageHeader(t('screen.brewNew')), form);
}
