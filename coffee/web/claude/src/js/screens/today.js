// Heute (SPEC UI screen 1): greeting, new brew, Fällig, Bohnen, last three brews. Empty rows are hidden with their heading.
import { h } from '../dom.js';
import { icon } from '../icons.js';
import { t } from '../i18n.js';
import { button, pageHeader } from '../ui.js';
import { formatDate } from '../format.js';
import { todayData } from '../dashboard.js';
import { makeView } from './common.js';
import { brewCard } from './brews.js';
import { taskLabel } from './care.js';
import { orderText } from './bean-cards.js';

function greeting(now = new Date()) {
  const hr = now.getHours();
  return t(hr < 11 ? 'today.greet.morning' : hr < 18 ? 'today.greet.day' : 'today.greet.evening');
}

function row(id, testid, title, ...content) {
  return h('section', { class: 'today__row', 'aria-labelledby': id, 'data-testid': testid },
    h('h2', { id }, title), ...content);
}

function dueRow(tasks) {
  return row('today-due-h', 'today-due', t('today.due'),
    h('div', { class: 'chip-row' }, tasks.map((task) => h('a', {
      class: 'chip chip--error chip--lg', href: '#/care', 'data-testid': 'due-chip', 'data-kind': task.kind, 'data-device': task.device.id,
    }, icon('alert', 'icon--sm'), t('today.dueChip', { task: taskLabel(task.kind), device: task.device.name })))));
}

function beansRow(needs, resting) {
  return row('today-beans-h', 'today-beans', t('today.beans'),
    h('div', { class: 'chip-row' },
      needs.map((n) => h('a', { class: 'chip chip--accent chip--lg', href: '#/beans', 'data-testid': 'today-order' },
        icon('bag', 'icon--sm'), t('today.order', { bean: n.bean.name, order: orderText(n.reorder.bags) }))),
      resting.map((r) => h('a', { class: 'chip chip--neutral chip--lg', href: '#/beans', 'data-testid': 'today-resting' },
        icon('hourglass', 'icon--sm'), `${r.bean.name} · ${t('rest.readyOn', { date: formatDate(r.readyOn) })}`))));
}

function build(_state, paint) {
  const d = todayData(new Date());
  const head = [
    pageHeader(greeting(), button({ label: t('action.newBrew'), iconName: 'plus', href: '#/brews/new', testid: 'today-new-brew' })),
    h('a', { class: 'card start-card', href: '#/guided', 'data-testid': 'start-filter' },
      icon('cone', 'icon--lg'),
      h('span', { class: 'start-card__body' },
        h('span', { class: 'start-card__title heading' }, t('today.filter.title')),
        h('span', { class: 'start-card__text' }, t('today.filter.text')))),
  ];
  if (d.empty) return [...head, h('p', { class: 'muted', 'data-testid': 'today-empty' }, t('today.empty'))];
  return [
    ...head,
    h('div', { class: 'today' },
      d.dueTasks.length ? dueRow(d.dueTasks) : null,
      d.orderNeeds.length || d.restingBags.length ? beansRow(d.orderNeeds, d.restingBags) : null,
      d.lastBrews.length
        ? row('today-recent', 'today-last-brews', t('today.recent'), h('div', { class: 'card-grid' }, d.lastBrews.map((b) => brewCard(b, paint, 'today-brew-card'))))
        : null),
  ];
}

export const renderToday = makeView(build);
