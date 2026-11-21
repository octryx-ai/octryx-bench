// Pieces shared by the brew list, form and detail: chips, recommendation texts, bean lookup.
import { h } from '../dom.js';
import { icon } from '../icons.js';
import { t } from '../i18n.js';
import { recommendation, button } from '../ui.js';
import { getState } from '../store.js';
import * as M from '../models.js';
import * as B from '../brews.js';
import { fmtNum } from './common.js';
import { formatDate } from '../format.js';

export const TASTES = ['sour', 'bitter', 'weak', 'harsh_astringent', 'balanced'];
const STATUS_ICON = { ok: 'check', warn: 'clock', error: 'alert' };

export function tasteChip(taste, testid = 'brew-taste') {
  return h('span', { class: 'chip chip--neutral', 'data-testid': testid, 'data-taste': taste }, t('taste.' + taste));
}

/** Time class chip (SPEC 4.2): colour plus icon plus text, so the status never relies on colour alone. */
export function timeClassChip({ cls, status }, testid) {
  return h('span', { class: 'chip chip--' + status, 'data-testid': testid, 'data-status': status, 'data-class': cls },
    icon(STATUS_ICON[status], 'icon--sm'), t('timeclass.' + cls));
}

const NUMERIC = ['setting', 'yieldG', 'doseG', 'tempC', 'from', 'to', 'limitS', 'timeS'];

function stepText(step) {
  const params = { ...step.params };
  for (const k of NUMERIC) if (k in params) params[k] = fmtNum(params[k]) || '–';
  return t(step.key, params);
}

/** Recommendation panel (SPEC 4.6) or null when there is nothing to show. `action` is an optional node (favourite button). */
export function recommendationPanel(rec, action) {
  if (!rec || !rec.steps?.length) return null;
  return recommendation({
    headline: t(rec.keep ? 'rec.keepTitle' : 'rec.title'),
    steps: rec.steps.map(stepText),
    keep: !!rec.keep,
    action: rec.keep ? action : undefined,
  });
}

/** Recommendation for a (possibly unsaved) brew; a missing time falls back to the middle of the target window. */
export function recFor({ method, taste, timeS, grinderSetting }, grinder) {
  const s = getState().settings;
  const time = Number.isFinite(timeS) ? timeS : (s.espressoTimeMinS + s.espressoTimeMaxS) / 2;
  return B.recommendationFor({ method, taste, timeS: time, grinderSetting }, grinder || {}, s);
}

export function favButton({ pressed, onClick, testid = 'mark-favourite' }) {
  const btn = button({ label: t('brew.fav.mark'), variant: 'secondary', iconName: 'star', testid, onClick });
  btn.setAttribute('aria-pressed', pressed ? 'true' : 'false');
  btn.classList.add('fav-mark');
  return btn;
}

/** Bag, bean and roaster of a brew (any may be missing after deletions). */
export function brewContext(brew) {
  const s = getState();
  const bag = s.bags.find((b) => b.id === brew.bagId) || null;
  const bean = bag ? s.beans.find((b) => b.id === bag.beanId) || null : null;
  const roaster = bean ? M.roasterOfBean(bean) : null;
  const grinder = s.grinders.find((g) => g.id === brew.grinderId) || null;
  const machine = s.machines.find((m) => m.id === brew.machineId) || null;
  const water = s.waters.find((w) => w.id === brew.waterId) || null;
  const hue = M.hueForRoaster(roaster?.name ?? bean?.name ?? '');
  return { bag, bean, roaster, grinder, machine, water, hue };
}

export function methodIcon(method) {
  return method === 'filter' ? 'cone' : 'cup';
}

export function brewAnchor(brew, hue) {
  const a = h('div', { class: 'anchor bean-anchor', 'data-testid': 'brew-anchor' }, icon(methodIcon(brew.method), 'icon--lg'));
  a.style.setProperty('--h', String(hue));
  return a;
}

export function settingText(brew, grinder) {
  return [fmtNum(brew.grinderSetting), grinder?.settingUnit].filter(Boolean).join(' ');
}

export function favStar(on) {
  const ic = icon('star');
  if (on) ic.classList.add('icon--filled');
  return ic;
}

/** Fills a bag <select> from B.pickerBags entries; resting bags are disabled with their ready date. */
export function fillBagSelect(sel, entries, keep) {
  const prev = keep ?? sel.value;
  const usable = entries.filter((e) => !e.disabled);
  const options = entries.map((e) => {
    const label = [e.bean.name, e.roaster?.name, `${fmtNum(e.bag.remainingG)} g`].filter(Boolean).join(' · ')
      + (e.disabled ? ` · ${t('rest.readyOn', { date: formatDate(e.rest.readyOn) })}` : '');
    return h('option', { value: e.bag.id, disabled: e.disabled }, label);
  });
  sel.replaceChildren(...(usable.length ? [] : [h('option', { value: '' }, t('form.pick'))]), ...options);
  sel.value = usable.some((e) => e.bag.id === prev) ? prev : usable[0]?.bag.id ?? '';
}
