// Taste entry for a saved brew (opened after a guided brew): taste, notes, favourite. Saving only patches the brew.
import { h } from '../dom.js';
import { t } from '../i18n.js';
import { button, pageHeader, showToast } from '../ui.js';
import { createForm } from '../forms.js';
import { errorBox } from '../dialog.js';
import { navigate } from '../router.js';
import * as B from '../brews.js';
import { TASTES, recommendationPanel, recFor, favButton, brewContext } from './brew-parts.js';

export function renderTasteForm(route, id) {
  const brew = B.getBrew(id);
  const ctx = brewContext(brew);
  const f = createForm();
  let taste = brew.taste || '';
  let favourite = !!brew.favourite;

  const tasteBtns = TASTES.map((k) => h('button', {
    type: 'button', class: 'taste-chip', 'aria-pressed': k === taste ? 'true' : 'false', 'data-testid': 'taste-' + k,
    onClick: () => { taste = taste === k ? '' : k; tasteBtns.forEach((b, i) => b.setAttribute('aria-pressed', TASTES[i] === taste ? 'true' : 'false')); update(); },
  }, t('taste.' + k)));
  const tasteField = h('div', { class: 'field' },
    h('span', { class: 'field__label', id: 'taste-label' }, t('form.taste')),
    h('div', { class: 'taste-group', role: 'group', 'aria-labelledby': 'taste-label', 'data-testid': 'field-taste' }, tasteBtns));
  const notesField = f.textarea('notes', t('form.notes'), { value: brew.notes || '' });
  const favBtn = favButton({ pressed: favourite, onClick: () => { favourite = !favourite; favBtn.setAttribute('aria-pressed', favourite ? 'true' : 'false'); } });
  const recSlot = h('div', { class: 'preview__rec' });

  function update() {
    const rec = taste ? recFor({ method: brew.method, taste, timeS: brew.timeS, grinderSetting: brew.grinderSetting }, ctx.grinder) : null;
    const panel = recommendationPanel(rec, favBtn);
    recSlot.replaceChildren(...(panel ? [panel] : []));
  }

  const box = errorBox();
  function submit(e) {
    e.preventDefault();
    box.clear();
    const res = B.updateBrew(id, { taste, notes: f.str('notes'), favourite: favourite && taste === 'balanced' });
    if (!res.ok) { box.show(Object.values(res.errors).map((k) => t(k))); return; }
    showToast('success', t('toast.brewSaved'));
    navigate('/brews/' + id);
  }

  const form = h('form', { class: 'brew-form', novalidate: true, 'data-testid': 'brew-form', 'data-mode': 'taste', onSubmit: submit },
    h('div', { class: 'card brew-fields taste-form' },
      h('p', { class: 'brew-card__summary', 'data-testid': 'taste-summary' }, [ctx.bean?.name, B.brewSummary(brew)].filter(Boolean).join(' · ')),
      tasteField, notesField, recSlot),
    h('div', { class: 'save-bar' }, box, h('div', { class: 'save-bar__actions' },
      button({ label: t('brew.taste.skip'), variant: 'secondary', href: '#/brews/' + id, testid: 'cancel-brew' }),
      button({ label: t('action.save'), variant: 'primary', type: 'submit', testid: 'save-brew' }))));
  update();
  return h('div', { class: 'page', 'data-testid': route.testid }, pageHeader(t('brew.taste.title')), form);
}
