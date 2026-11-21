import { h } from './dom.js';
import { icon } from './icons.js';
import { t } from './i18n.js';

// Phone items first (tab bar), then the secondary items that live in the "More" sheet on phone.
const PRIMARY = [
  { id: 'heute', href: '#/', labelKey: 'nav.today', icon: 'today' },
  { id: 'brews', href: '#/brews', labelKey: 'nav.brews', icon: 'brews' },
  { id: 'beans', href: '#/beans', labelKey: 'nav.beans', icon: 'beans' },
  { id: 'equipment', href: '#/equipment', labelKey: 'nav.equipment', icon: 'equipment' },
];
const SECONDARY = [
  { id: 'water', href: '#/water', labelKey: 'nav.water', icon: 'water' },
  { id: 'care', href: '#/care', labelKey: 'nav.care', icon: 'care' },
  { id: 'settings', href: '#/settings', labelKey: 'nav.settings', icon: 'settings' },
];

function navLink(item, activeId) {
  const label = t(item.labelKey);
  return h('a', {
    class: 'nav__item',
    href: item.href,
    title: label,
    'aria-label': label,
    'aria-current': item.id === activeId ? 'page' : false,
    'data-testid': 'nav-' + item.id,
  }, icon(item.icon), h('span', { class: 'nav__label' }, label));
}

/**
 * Builds the single navigation element. CSS turns it into the side bar (desktop),
 * the icon rail (tablet) or the bottom tab bar (phone); `variant` only decides
 * which data-testid it carries so exactly one variant exists at a time.
 */
export function buildShell({ focus, activeNav, variant, moreOpen, onToggleMore, content }) {
  if (focus) return h('div', { class: 'shell shell--focus' }, h('main', { class: 'content', id: 'main' }, content));
  const moreLabel = t('nav.more');
  const nav = h('nav', {
    class: 'nav' + (moreOpen ? ' is-more-open' : ''),
    'aria-label': t('nav.main'),
    'data-testid': variant,
  },
    h('a', { class: 'nav__logo', href: '#/', 'aria-label': t('app.name'), title: t('app.name') },
      icon('logo'), h('span', { class: 'nav__logo-text' }, t('app.name'))),
    h('a', {
      class: 'btn btn--primary new-brew', href: '#/brews/new', 'data-testid': 'new-brew',
      title: t('action.newBrew'), 'aria-label': t('action.newBrew'),
    }, icon('plus'), h('span', { class: 'new-brew__label' }, t('action.newBrew'))),
    h('ul', { class: 'nav__list' },
      PRIMARY.map((i) => h('li', null, navLink(i, activeNav))),
      h('li', { class: 'nav__tab-more' },
        h('button', {
          type: 'button', class: 'nav__item', 'data-testid': 'tab-more',
          'aria-expanded': moreOpen ? 'true' : 'false', 'aria-controls': 'more-sheet',
          'aria-label': moreLabel, onClick: onToggleMore,
        }, icon('more'), h('span', { class: 'nav__label' }, moreLabel)))),
    h('ul', { class: 'nav__secondary', id: 'more-sheet', 'aria-label': t('nav.moreTitle') },
      SECONDARY.map((i) => h('li', null, navLink(i, activeNav)))));

  const scrim = h('button', {
    type: 'button', class: 'nav__scrim' + (moreOpen ? ' is-open' : ''), tabindex: '-1',
    'aria-label': t('nav.close'), 'data-testid': 'more-scrim', onClick: onToggleMore,
  });
  return h('div', { class: 'shell' }, scrim, nav, h('main', { class: 'content', id: 'main' }, content));
}
