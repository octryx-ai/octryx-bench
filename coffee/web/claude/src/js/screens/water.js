// Wasser (SPEC UI screen 7): profile cards with per-value status chips and target ranges, add/edit dialog.
import { h } from '../dom.js';
import { icon } from '../icons.js';
import { t } from '../i18n.js';
import { getState } from '../store.js';
import { button, pageHeader, showToast } from '../ui.js';
import { openFormDialog } from '../forms.js';
import { blockedDialog } from '../dialog.js';
import * as M from '../models.js';
import { evaluateWater, waterRanges } from '../rules/index.js';
import { makeView, emptyState, fmtNum } from './common.js';

const FIELDS = ['tdsMgL', 'hardnessPpm', 'alkalinityPpm', 'ph', 'chlorineMgL'];
const UNIT_KEY = { tdsMgL: 'unit.mgL', hardnessPpm: 'unit.ppm', alkalinityPpm: 'unit.ppm', ph: null, chlorineMgL: 'unit.mgL' };
const unitOf = (f) => (UNIT_KEY[f] ? t(UNIT_KEY[f]) : '');

function rangeText(f, ranges) {
  const r = ranges[f];
  const unit = unitOf(f);
  const u = unit ? ' ' + unit : '';
  if (!r.min && !r.max) return t('water.rangeZero', { unit: u });
  return t('water.range', { target: fmtNum(r.target), min: fmtNum(r.min), max: fmtNum(r.max), unit: u });
}

/** Chip kind, text and message key of one evaluated value. */
function statusView(f, water, ev) {
  const v = water[f];
  const status = ev?.status || 'none';
  if (status === 'none') return { status, kind: 'neutral', text: t('water.status.none') };
  if (status === 'ok') return { status, kind: 'ok', text: t('water.status.ok'), icon: 'check' };
  const high = ev.messageKey?.endsWith('.high') || (ev.messageKey == null && v > 0);
  return {
    status, kind: status === 'error' ? 'error' : 'warn', icon: 'alert', message: ev.messageKey ? t(ev.messageKey) : null,
    text: t(high ? 'water.status.high' : 'water.status.low'),
  };
}

function valueRow(f, water, ev, ranges) {
  const view = statusView(f, water, ev);
  const v = water[f];
  const unit = unitOf(f);
  return h('li', { class: 'water-value', 'data-field': f },
    h('div', { class: 'water-value__main' },
      h('span', { class: 'water-value__label' }, t('water.field.' + f)),
      h('span', { class: 'water-value__num', 'data-testid': 'water-value' }, v === null || v === undefined ? '–' : `${fmtNum(v)}${unit ? ' ' + unit : ''}`),
      h('span', { class: 'water-range', 'data-testid': 'water-range' }, rangeText(f, ranges))),
    h('span', { class: 'chip chip--' + view.kind, 'data-testid': 'water-chip', 'data-field': f, 'data-status': view.status },
      view.icon ? icon(view.icon, 'icon--sm') : null, view.text),
    view.message ? h('p', { class: 'water-value__note' }, view.message) : null);
}

function openWaterDialog({ item, onDone }) {
  const ranges = waterRanges(getState().settings);
  openFormDialog({
    title: t(item ? 'water.edit' : 'water.add'),
    build(f) {
      const num = (name) => f.text(name, t('water.field.' + name), {
        value: item?.[name] == null ? '' : fmtNum(item[name]), unit: unitOf(name) || undefined, inputmode: 'decimal', hint: rangeText(name, ranges),
      });
      const nodes = [
        f.text('name', t('water.field.name'), { value: item?.name ?? '', maxlength: 60 }),
        ...FIELDS.map(num),
      ];
      for (const name of FIELDS) f.wrappers[name].querySelector('.field__hint')?.classList.add('water-range');
      for (const name of FIELDS) f.wrappers[name].querySelector('.field__hint')?.setAttribute('data-testid', 'water-range');
      return nodes;
    },
    submit(f) {
      const values = { name: f.str('name') };
      for (const name of FIELDS) values[name] = f.val(name).trim() === '' ? null : f.num(name);
      return item ? M.updateWater(item.id, values) : M.createWater(values);
    },
    onSaved: onDone,
  });
}

function waterCard(water, paint, ranges) {
  const ev = evaluateWater(water);
  const remove = () => {
    const res = M.removeItem('water', water.id);
    if (res.ok) { showToast('success', t('toast.deleted')); paint(); }
    else if (res.reason === 'inUse') blockedDialog({ result: { ...res, canArchive: false } });
  };
  return h('article', { class: 'card water-card', 'data-testid': 'water-card' },
    h('div', { class: 'water-card__head' },
      h('h2', { class: 'water-card__name card__title', 'data-testid': 'water-name' }, water.name),
      h('div', { class: 'btn-row' },
        h('button', { type: 'button', class: 'btn btn--ghost btn--icon', 'data-testid': 'water-edit', 'aria-label': t('water.editAria', { name: water.name }), onClick: () => openWaterDialog({ item: water, onDone: paint }) }, icon('edit')),
        h('button', { type: 'button', class: 'btn btn--ghost btn--icon', 'data-testid': 'water-delete', 'aria-label': t('water.deleteAria', { name: water.name }), onClick: remove }, icon('trash')))),
    h('ul', { class: 'water-values' }, FIELDS.map((f) => valueRow(f, water, ev[f], ranges))));
}

function build(_state, paint) {
  const waters = M.listWaters();
  const add = () => openWaterDialog({ onDone: paint });
  if (!waters.length) {
    return [
      pageHeader(t('screen.water')),
      emptyState({ iconName: 'drop', title: t('water.empty.title'), text: t('water.empty.text'), actionLabel: t('water.add'), onAction: add }),
    ];
  }
  const ranges = waterRanges(getState().settings);
  return [
    pageHeader(t('screen.water'), button({ label: t('water.add'), testid: 'add-water', iconName: 'plus', onClick: add })),
    h('div', { class: 'card-grid' }, waters.map((w) => waterCard(w, paint, ranges))),
  ];
}

export const renderWater = makeView(build);
