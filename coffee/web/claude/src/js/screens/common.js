// Shared pieces of the list screens: self-repainting view, switch, empty state, card menu, formatting.
import { h } from '../dom.js';
import { icon } from '../icons.js';
import { t } from '../i18n.js';
import { button } from '../ui.js';
import { formatNumber } from '../format.js';

export function todayIso() {
  const d = new Date();
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`;
}

/** Number without trailing zeros (1 -> "1", 0.5 -> "0,5", 0.05 -> "0,05"), localized. */
export function fmtNum(n) {
  n = Number(n);
  if (!Number.isFinite(n)) return '';
  const dec = Number.isInteger(n) ? 0 : Math.abs(n * 10 - Math.round(n * 10)) < 1e-9 ? 1 : 2;
  return formatNumber(n, dec);
}
export const fmtG = (n) => `${fmtNum(n)} g`;

/**
 * A screen whose content repaints itself (tab, switch, menu, mutations) without a full app render.
 * build(state, paint) returns the array of child nodes. The latest rendered root is the one repainted.
 */
export function makeView(build, initial = {}) {
  let root = null;
  const state = { menu: null, ...initial };

  function paint() {
    if (!root) return;
    const active = document.activeElement;
    const id = root.contains(active) ? active.getAttribute('data-testid') : null;
    const idx = id ? [...root.querySelectorAll(`[data-testid="${id}"]`)].indexOf(active) : -1;
    root.replaceChildren(...build(state, paint).filter(Boolean));
    if (id && idx >= 0) root.querySelectorAll(`[data-testid="${id}"]`)[idx]?.focus();
  }

  document.addEventListener('click', (e) => {
    if (state.menu && !e.target.closest?.('.card-menu-wrap')) { state.menu = null; paint(); }
  });
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && state.menu) {
      const key = state.menu;
      state.menu = null;
      paint();
      document.querySelector(`[data-menu-key="${key}"] [data-testid="card-menu"]`)?.focus();
    }
  });

  return function render(route) {
    root = h('div', { class: 'page', 'data-testid': route.testid });
    paint();
    return root;
  };
}

export function showArchivedSwitch(checked, onChange) {
  return h('label', { class: 'switch' },
    h('input', { type: 'checkbox', role: 'switch', checked, 'data-testid': 'show-archived', onChange: (e) => onChange(e.target.checked) }),
    h('span', null, t('list.showArchived')));
}

export function emptyState({ iconName, title, text, actionLabel, onAction }) {
  return h('section', { class: 'empty-state', 'data-testid': 'empty-state' },
    icon(iconName, 'icon--illustration'),
    h('p', { class: 'empty-state__title heading' }, title),
    text && h('p', { class: 'empty-state__text' }, text),
    button({ label: actionLabel, variant: 'primary', testid: 'empty-action', onClick: onAction }));
}

/** The "..." menu of a card: edit, archive/restore, delete. */
export function cardMenu({ key, name, archived, state, paint, onEdit, onArchive, onRestore, onDelete }) {
  const isOpen = state.menu === key;
  const item = (testid, label, fn, cls = '') => h('button', {
    type: 'button', role: 'menuitem', class: 'menu__item ' + cls, 'data-testid': testid,
    onClick: () => { state.menu = null; paint(); fn(); },
  }, label);
  return h('div', { class: 'card-menu-wrap', 'data-menu-key': key },
    h('button', {
      type: 'button', class: 'btn btn--ghost card-menu-btn', 'data-testid': 'card-menu',
      'aria-haspopup': 'menu', 'aria-expanded': isOpen ? 'true' : 'false', 'aria-label': t('menu.open', { name }),
      onClick: (e) => { e.stopPropagation(); state.menu = isOpen ? null : key; paint(); },
    }, icon('more')),
    isOpen && h('div', { class: 'menu', role: 'menu' },
      item('menu-edit', t('action.edit'), onEdit),
      archived ? item('menu-restore', t('action.restore'), onRestore) : item('menu-archive', t('action.archive'), onArchive),
      item('menu-delete', t('action.delete'), onDelete, 'menu__item--danger')));
}
