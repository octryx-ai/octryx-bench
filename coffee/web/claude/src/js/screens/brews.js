// Brews list (SPEC UI screen 2): filter bar, cards newest first, empty state.
import { h } from '../dom.js';
import { t } from '../i18n.js';
import { button, pageHeader } from '../ui.js';
import * as M from '../models.js';
import * as B from '../brews.js';
import { getState } from '../store.js';
import { makeView, emptyState } from './common.js';
import { navigate } from '../router.js';
import { tasteChip, brewContext, brewAnchor, settingText, favStar } from './brew-parts.js';

const filters = { method: '', grinderId: '', beanId: '', favourite: false };

function select(testid, label, allLabel, options, value, onChange) {
  return h('select', { class: 'select', 'data-testid': testid, 'aria-label': label, onChange: (e) => onChange(e.target.value) },
    h('option', { value: '' }, allLabel),
    options.map(([v, text]) => h('option', { value: v, selected: v === value }, text)));
}

function filterBar(paint) {
  const set = (k) => (v) => { filters[k] = v; paint(); };
  const beans = M.listBeans({ includeArchived: true });
  const grinders = M.listGrinders({ includeArchived: true });
  return h('div', { class: 'filter-bar', role: 'group', 'aria-label': t('brews.filter.label') },
    select('filter-method', t('brews.filter.method'), t('brews.filter.allMethods'),
      [['espresso', t('method.espresso')], ['filter', t('method.filter')]], filters.method, set('method')),
    select('filter-grinder', t('brews.filter.grinder'), t('brews.filter.allGrinders'), grinders.map((g) => [g.id, g.name]), filters.grinderId, set('grinderId')),
    select('filter-bean', t('brews.filter.bean'), t('brews.filter.allBeans'), beans.map((b) => [b.id, b.name]), filters.beanId, set('beanId')),
    h('button', {
      type: 'button', class: 'filter-chip', 'aria-pressed': filters.favourite ? 'true' : 'false', 'data-testid': 'filter-fav',
      onClick: () => { filters.favourite = !filters.favourite; paint(); },
    }, favStar(filters.favourite), t('brews.filter.fav')));
}

export function brewCard(brew, paint, testid = 'brew-card') {
  const ctx = brewContext(brew);
  const tc = B.brewTimeClass(brew);
  const status = tc.status || 'none';
  const title = ctx.bean?.name ?? '–';
  return h('article', { class: 'card item-card brew-card', 'data-testid': testid, 'data-id': brew.id },
    h('a', { class: 'brew-card__link', href: '#/brews/' + brew.id },
      brewAnchor(brew, ctx.hue),
      h('div', { class: 'item-card__body' },
        h('h3', { class: 'item-card__head', 'data-testid': 'brew-bean' }, title),
        h('p', { class: 'brew-card__summary', 'data-testid': 'brew-summary' }, B.brewSummary(brew)),
        h('p', { class: 'stat', 'data-testid': 'brew-setting' }, t('brew.setting', { value: settingText(brew, ctx.grinder) })),
        brew.taste ? h('div', { class: 'item-card__chips' }, tasteChip(brew.taste)) : null,
        tc.cls ? h('span', { class: 'sr-only' }, t('timeclass.' + tc.cls)) : null)),
    h('button', {
      type: 'button', class: 'btn btn--ghost btn--icon fav-toggle' + (brew.favourite ? ' is-on' : ''), 'data-testid': 'fav-toggle',
      'aria-pressed': brew.favourite ? 'true' : 'false', 'aria-label': t(brew.favourite ? 'brew.fav.remove' : 'brew.fav.add'),
      onClick: () => { B.toggleFavourite(brew.id); paint(); },
    }, favStar(brew.favourite)),
    h('div', { class: 'brew-bar', 'data-testid': 'brew-bar', 'data-status': status }));
}

function build(state, paint) {
  const total = getState().brews.length;
  if (total === 0) {
    return [
      pageHeader(t('screen.brews')),
      emptyState({ iconName: 'brews', title: t('brews.empty.title'), text: t('brews.empty.text'), actionLabel: t('brews.empty.action'), onAction: () => navigate('/brews/new') }),
    ];
  }
  const list = B.listBrews(filters);
  return [
    pageHeader(t('screen.brews'), button({ label: t('action.newBrew'), iconName: 'plus', href: '#/brews/new', testid: 'add-brew' })),
    filterBar(paint),
    list.length
      ? h('div', { class: 'card-grid' }, list.map((b) => brewCard(b, paint)))
      : h('p', { class: 'muted', 'data-testid': 'no-results' }, t('brews.noResults')),
  ];
}

export const renderBrews = makeView(build);
