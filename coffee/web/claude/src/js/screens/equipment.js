import { h } from '../dom.js';
import { icon } from '../icons.js';
import { t } from '../i18n.js';
import { button, pageHeader, showToast } from '../ui.js';
import { formatGrams } from '../format.js';
import { blockedDialog } from '../dialog.js';
import * as M from '../models.js';
import { makeView, emptyState, showArchivedSwitch, cardMenu } from './common.js';
import { openDeviceDialog } from './device-dialogs.js';

const ui = { tab: 'machines', archived: false };

function deviceIcon(kind, item) {
  if (kind === 'machine') return item.type === 'filter' ? 'v60' : 'portafilter';
  return item.type === 'hand' ? 'crank' : 'burr';
}

function deviceCard(kind, item, state, paint) {
  const name = item.name;
  const chips = [];
  if (kind === 'grinder') {
    chips.push(h('span', { class: 'chip chip--neutral', 'data-testid': 'device-retention' }, t('dev.retention', { value: formatGrams(item.retentionG ?? 0.5) })));
    if (item.settingUnit) chips.push(h('span', { class: 'chip chip--neutral', 'data-testid': 'device-unit' }, item.settingUnit));
  }
  if (item.archived) chips.push(h('span', { class: 'chip chip--neutral' }, t('chip.archived')));

  const edit = () => openDeviceDialog({ kind, item, onDone: paint });
  const setArchived = (flag) => () => {
    (flag ? M.archiveItem : M.restoreItem)(kind, item.id);
    showToast('success', t(flag ? 'toast.archived' : 'toast.restored'));
    paint();
  };
  const remove = () => {
    const res = M.removeItem(kind, item.id);
    if (res.ok) { showToast('success', t('toast.deleted')); paint(); }
    else if (res.reason === 'inUse') blockedDialog({ result: res, onArchive: setArchived(true) });
  };

  return h('article', { class: 'card item-card' + (item.archived ? ' is-archived' : '') + (state.menu === item.id ? ' has-menu-open' : ''), 'data-testid': 'device-card', 'data-kind': kind },
    h('div', { class: 'item-card__top' },
      h('div', { class: 'anchor device-anchor', 'data-testid': 'device-anchor' }, icon(deviceIcon(kind, item), 'icon--lg')),
      h('div', { class: 'item-card__body' },
        h('h3', { class: 'item-card__head', 'data-testid': 'device-name' }, name),
        h('p', { class: 'card__meta', 'data-testid': 'device-type' }, t((kind === 'machine' ? 'dev.machine.' : 'dev.grinder.') + item.type)),
        chips.length ? h('div', { class: 'item-card__chips' }, chips) : null)),
    cardMenu({ key: item.id, name, archived: !!item.archived, state, paint, onEdit: edit, onArchive: setArchived(true), onRestore: setArchived(false), onDelete: remove }));
}

function build(state, paint) {
  const kind = ui.tab === 'machines' ? 'machine' : 'grinder';
  const list = (k, archived) => (k === 'machine' ? M.listMachines : M.listGrinders)({ includeArchived: archived });
  const everything = list('machine', true).length + list('grinder', true).length;
  const items = list(kind, ui.archived);
  const add = () => openDeviceDialog({ kind, onDone: paint });
  const showEmpty = items.length === 0;

  const nodes = [pageHeader(t('screen.equipment'), showEmpty ? null : button({ label: t('dev.add'), testid: 'add-device', iconName: 'plus', onClick: add }))];
  {
    const tab = (id, key) => h('button', {
      type: 'button', role: 'tab', class: 'tab', id: 'tab-' + id, 'aria-selected': ui.tab === id ? 'true' : 'false',
      'aria-controls': 'device-panel', 'data-testid': 'tab-' + id, tabindex: ui.tab === id ? false : '-1',
      onClick: () => { ui.tab = id; state.menu = null; paint(); },
      onKeydown: (e) => {
        if (e.key === 'ArrowRight' || e.key === 'ArrowLeft') { ui.tab = id === 'machines' ? 'grinders' : 'machines'; paint(); document.getElementById('tab-' + ui.tab)?.focus(); }
      },
    }, t(key));
    nodes.push(
      h('div', { class: 'tabs', role: 'tablist', 'aria-label': t('dev.tabs') }, tab('machines', 'dev.tab.machines'), tab('grinders', 'dev.tab.grinders')),
      everything > 0 ? h('div', { class: 'list-bar list-bar--end' }, showArchivedSwitch(ui.archived, (v) => { ui.archived = v; paint(); })) : null);
  }
  nodes.push(h('div', { id: 'device-panel', role: 'tabpanel', 'aria-labelledby': 'tab-' + ui.tab },
    showEmpty
      ? emptyState({ iconName: 'portafilter', title: t('dev.empty.title'), text: t('dev.empty.text'), actionLabel: t('dev.add'), onAction: add })
      : h('div', { class: 'card-grid' }, items.map((it) => deviceCard(kind, it, state, paint)))));
  return nodes;
}

export const renderEquipment = makeView(build);
