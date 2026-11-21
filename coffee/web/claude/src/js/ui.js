// Reusable component builders (used by the style guide and the screens).
import { h } from './dom.js';
import { icon } from './icons.js';
import { t } from './i18n.js';

export function button({ label, variant = 'primary', state = '', disabled = false, loading = false, href, testid, onClick, iconName, type = 'button' }) {
  const cls = ['btn', 'btn--' + variant, state && 'is-' + state, loading && 'is-loading'].filter(Boolean).join(' ');
  const attrs = { class: cls, 'data-testid': testid, onClick };
  const kids = [iconName && icon(iconName), h('span', null, label)];
  if (href) return h('a', { ...attrs, href, 'aria-disabled': disabled ? 'true' : false }, kids);
  return h('button', { ...attrs, type, disabled: disabled || loading, 'aria-busy': loading ? 'true' : false }, kids);
}

export function chip(kind, text, iconName) {
  return h('span', { class: 'chip chip--' + kind }, iconName && icon(iconName, 'icon--sm'), text);
}

let uid = 0;
export function field({ label, value = '', unit, state = '', disabled = false, error, placeholder, type = 'text', inputmode, testid }) {
  const id = 'f' + ++uid;
  const input = h('input', {
    id, class: 'input' + (state ? ' is-' + state : ''), type, value, placeholder, inputmode,
    disabled, 'aria-invalid': error ? 'true' : false, 'aria-describedby': error ? id + '-err' : false,
    'data-testid': testid,
  });
  input.value = value;
  return h('div', { class: 'field' },
    h('label', { class: 'field__label', for: id }, label),
    h('div', { class: 'input-wrap' + (unit ? ' input-wrap--unit' : '') }, input, unit && h('span', { class: 'input__unit' }, unit)),
    error && h('p', { class: 'field__error', id: id + '-err' }, icon('alert', 'icon--sm'), error));
}

export function stepper({ label, value = '', unit, disabled = false }) {
  const id = 'f' + ++uid;
  const input = h('input', { id, class: 'input', type: 'text', inputmode: 'decimal', disabled });
  input.value = value;
  const bump = (d) => () => {
    const n = parseFloat(String(input.value).replace(',', '.')) || 0;
    input.value = String(Math.max(0, Math.round((n + d) * 10) / 10));
  };
  return h('div', { class: 'field' },
    h('label', { class: 'field__label', for: id }, label),
    h('div', { class: 'stepper' },
      h('button', { type: 'button', class: 'btn btn--secondary stepper__btn', 'aria-label': t('sg.stepper.dec'), disabled, onClick: bump(-0.5) }, icon('minus')),
      h('div', { class: 'input-wrap' + (unit ? ' input-wrap--unit' : '') }, input, unit && h('span', { class: 'input__unit' }, unit)),
      h('button', { type: 'button', class: 'btn btn--secondary stepper__btn', 'aria-label': t('sg.stepper.inc'), disabled, onClick: bump(0.5) }, icon('plus'))));
}

export function recommendation({ headline, steps, keep = false, action }) {
  return h('section', { class: 'reco' + (keep ? ' reco--keep' : ''), 'data-testid': 'recommendation', 'data-state': keep ? 'keep' : 'shown' },
    icon(keep ? 'check' : 'info'),
    h('div', { class: 'reco__body' },
      h('h3', { class: 'reco__title' }, headline),
      h('ul', { class: 'reco__steps' }, steps.map((s) => h('li', { 'data-testid': 'recommendation-step' }, s))),
      action));
}

// ---- toast ----
export const TOAST_MS = 4000;
let region;
function toastRegion() {
  if (!region || !region.isConnected) {
    region = h('div', { class: 'toast-region', 'data-testid': 'toast-region', 'aria-live': 'polite' });
    document.body.append(region);
  }
  return region;
}

export function toastElement(kind, text, { onClose, role } = {}) {
  return h('div', { class: 'toast toast--' + kind, role: role || (kind === 'error' ? 'alert' : 'status'), 'data-testid': 'toast-' + kind },
    icon(kind === 'success' ? 'check' : 'alert'),
    h('span', { class: 'toast__text' }, text),
    onClose && h('button', { type: 'button', class: 'btn btn--ghost', 'aria-label': t('toast.dismiss'), onClick: onClose }, icon('close')));
}

export function showToast(kind, text) {
  const reg = toastRegion();
  const remove = () => el.remove();
  const el = toastElement(kind, text, { onClose: remove });
  reg.append(el);
  setTimeout(remove, TOAST_MS);
  return el;
}

export function pageHeader(title, ...actions) {
  return h('header', { class: 'page-header' }, h('h1', null, title), actions.length ? h('div', { class: 'sg__row' }, actions) : null);
}
