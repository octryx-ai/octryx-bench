import { h } from '../dom.js';
import { icon } from '../icons.js';
import { t } from '../i18n.js';
import { showToast } from '../ui.js';
import { formatDate } from '../format.js';
import { blockedDialog } from '../dialog.js';
import * as M from '../models.js';
import { cardMenu, fmtG, fmtNum } from './common.js';
import { openBeanDialog, openBagDialog } from './bean-dialogs.js';

export function restChip(rest) {
  const status = rest?.status || 'ready';
  const map = {
    resting: ['chip--accent', 'hourglass', t('rest.readyOn', { date: formatDate(rest?.readyOn) })],
    ready: ['chip--ok', 'check', t('rest.ready')],
    past_peak: ['chip--warn', 'clock', t('rest.pastPeak')],
  };
  const [cls, ic, text] = map[status] || map.ready;
  return h('span', { class: 'chip ' + cls, 'data-testid': 'rest-chip', 'data-status': status }, icon(ic, 'icon--sm'), text);
}

export function orderText(bags) {
  return bags === 1 ? t('order.nowOne') : t('order.now', { n: bags });
}

const BEAN_ICON = { light: 'beanLight', medium: 'beanMedium', dark: 'beanDark' };

export function beanAnchor(entry) {
  const a = h('div', { class: 'anchor bean-anchor', 'data-testid': 'bean-anchor' }, icon(BEAN_ICON[entry.bean.roastLevel] || 'beanMedium', 'icon--lg'));
  a.style.setProperty('--h', String(entry.hue));
  return a;
}

function bagRow(bag, entry, paint) {
  const rest = bag.rest || M.bagRest(bag, entry.bean);
  return h('li', { class: 'bag-row', 'data-testid': 'bag-row' },
    h('div', { class: 'bag-row__main' },
      h('span', null, t('bag.roasted', { date: formatDate(bag.roastDate) })),
      h('span', { class: 'stat' }, t('bag.amount', { remaining: fmtG(bag.remainingG), total: fmtG(bag.weightG) }))),
    h('div', { class: 'bag-row__side' },
      restChip(rest),
      h('button', {
        type: 'button', class: 'btn btn--ghost btn--icon', 'data-testid': 'bag-edit', 'aria-label': t('bag.editAria'),
        onClick: () => openBagDialog({ item: bag, onDone: paint }),
      }, icon('edit'))));
}

export function beanCard(entry, state, paint, expanded, toggle, inv = null) {
  const { bean, roaster } = entry;
  const bags = [...entry.bags].sort((a, b) => String(a.roastDate).localeCompare(String(b.roastDate)));
  const metaParts = [roaster?.name, bean.origin].filter(Boolean);
  const edit = () => openBeanDialog({ item: bean, onDone: paint });
  const setArchived = (flag) => () => {
    (flag ? M.archiveItem : M.restoreItem)('bean', bean.id);
    showToast('success', t(flag ? 'toast.archived' : 'toast.restored'));
    paint();
  };
  const remove = () => {
    const res = M.removeItem('bean', bean.id);
    if (res.ok) { showToast('success', t('toast.deleted')); paint(); }
    else if (res.reason === 'inUse') blockedDialog({ result: res, onArchive: setArchived(true) });
  };
  const panelId = 'bags-' + bean.id;
  return h('article', {
    class: 'card item-card' + (expanded ? ' is-open' : '') + (bean.archived ? ' is-archived' : '') + (state.menu === bean.id ? ' has-menu-open' : ''),
    'data-testid': 'bean-card',
  },
    h('div', { class: 'item-card__top' },
      beanAnchor(entry),
      h('div', { class: 'item-card__body' },
        h('h3', { class: 'item-card__head', 'data-testid': 'bean-name' }, bean.name),
        h('p', { class: 'card__meta', 'data-testid': 'bean-roaster' }, metaParts.join(' · ')),
        h('p', { class: 'stat', 'data-testid': 'bean-stock' }, t('beans.stock'), ' ', h('strong', null, fmtG(entry.stockG ?? 0))),
        h('p', { class: 'stat', 'data-testid': 'bean-shots' }, t('beans.shotsLeft'), ' ', h('strong', null, inv?.shotsLeft == null ? '–' : fmtNum(inv.shotsLeft))),
        h('p', { class: 'stat', 'data-testid': 'bean-cover' }, t('beans.cover'), ' ', h('strong', null, inv?.coverDays == null ? '–' : t(inv.coverDays === 1 ? 'beans.coverOne' : 'beans.coverValue', { n: inv.coverDays }))),
        inv?.reorder?.order
          ? h('div', { class: 'item-card__chips' }, h('span', { class: 'chip chip--accent', 'data-testid': 'order-chip' }, icon('bag', 'icon--sm'), orderText(inv.reorder.bags)))
          : null,
        bean.archived ? h('div', { class: 'item-card__chips' }, h('span', { class: 'chip chip--neutral' }, t('chip.archived'))) : null,
        h('button', {
          type: 'button', class: 'btn btn--ghost expand-btn', 'data-testid': 'bean-expand',
          'aria-expanded': expanded ? 'true' : 'false', 'aria-controls': panelId, onClick: toggle,
        }, h('span', null, t('beans.bags', { n: bags.length })), icon('chevron', 'icon--sm')))),
    cardMenu({ key: bean.id, name: bean.name, archived: !!bean.archived, state, paint, onEdit: edit, onArchive: setArchived(true), onRestore: setArchived(false), onDelete: remove }),
    expanded
      ? h('ul', { class: 'bag-list', id: panelId }, bags.length ? bags.map((b) => bagRow(b, entry, paint)) : h('li', { class: 'bag-list__empty' }, t('beans.noBags')))
      : null);
}
