import { h } from '../dom.js';
import { t } from '../i18n.js';
import { button, pageHeader } from '../ui.js';
import * as M from '../models.js';
import { makeView, emptyState, showArchivedSwitch } from './common.js';
import { beanCard } from './bean-cards.js';
import { openBeanDialog, openBagDialog, openRoasterDialog } from './bean-dialogs.js';
import { icon } from '../icons.js';
import { getState } from '../store.js';
import { inventory } from '../inventory.js';

const ui = { archived: false, open: new Set() };

function roasterRow(r, paint) {
  const link = /^https?:\/\//.test(r.url || '')
    ? h('a', { href: r.url, target: '_blank', rel: 'noopener noreferrer', class: 'stat' }, r.url)
    : null;
  return h('li', { class: 'card roaster-row', 'data-testid': 'roaster-row' },
    h('div', { class: 'roaster-row__main' },
      h('span', { class: 'roaster-row__name' }, r.name),
      h('span', { class: 'stat' }, t('roaster.leadValue', { n: r.leadTimeDays ?? 3 })),
      link),
    h('button', {
      type: 'button', class: 'btn btn--ghost btn--icon', 'data-testid': 'roaster-edit',
      'aria-label': t('roaster.editAria', { name: r.name }),
      onClick: () => openRoasterDialog({ item: r, onDone: paint }),
    }, icon('edit')));
}

function build(state, paint) {
  const total = M.beansWithBags({ includeArchived: true }).length;
  const roasters = M.listRoasters();
  const addBean = () => openBeanDialog({ onDone: paint });

  if (total === 0) {
    return [
      pageHeader(t('screen.beans')),
      emptyState({ iconName: 'bag', title: t('beans.empty.title'), text: t('beans.empty.text'), actionLabel: t('beans.addBean'), onAction: addBean }),
      roasters.length ? roastersSection(roasters, paint) : null,
    ];
  }

  const entries = M.beansWithBags({ includeArchived: ui.archived });
  const inv = new Map(inventory(getState(), new Date()).map((x) => [x.bean.id, x]));
  const toggle = (id) => () => { ui.open.has(id) ? ui.open.delete(id) : ui.open.add(id); paint(); };
  return [
    pageHeader(t('screen.beans'),
      h('div', { class: 'btn-row' },
        button({ label: t('beans.addBag'), testid: 'add-bag', iconName: 'plus', onClick: () => openBagDialog({ onDone: paint }) }),
        button({ label: t('beans.addBean'), variant: 'secondary', testid: 'add-bean', onClick: addBean }),
        button({ label: t('beans.addRoaster'), variant: 'secondary', testid: 'add-roaster', onClick: () => openRoasterDialog({ onDone: paint }) }))),
    h('div', { class: 'list-bar list-bar--end' }, showArchivedSwitch(ui.archived, (v) => { ui.archived = v; paint(); })),
    entries.length
      ? h('div', { class: 'card-grid' }, entries.map((e) => beanCard(e, state, paint, ui.open.has(e.bean.id), toggle(e.bean.id), inv.get(e.bean.id))))
      : h('p', { class: 'muted' }, t('beans.noneVisible')),
    roasters.length ? roastersSection(roasters, paint) : null,
  ];
}

function roastersSection(roasters, paint) {
  return h('section', { 'aria-labelledby': 'roasters-title' },
    h('h2', { class: 'section-title', id: 'roasters-title' }, t('beans.roasters')),
    h('ul', { class: 'roaster-list' }, roasters.map((r) => roasterRow(r, paint))));
}

export const renderBeans = makeView(build);
