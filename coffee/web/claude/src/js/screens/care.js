// Pflege (SPEC UI screen 8): cleaning tasks sorted by overdue ratio, each with progress and its own "Erledigt".
import { h } from '../dom.js';
import { t } from '../i18n.js';
import { getState } from '../store.js';
import { cleaningTasks, markDone } from '../care.js';
import { button, pageHeader, showToast } from '../ui.js';
import { makeView, emptyState, fmtNum } from './common.js';

export const taskLabel = (kind) => t('care.task.' + kind);
export const progressText = (task) => `${fmtNum(task.current)} / ${fmtNum(task.limit)} ${t('unit.' + task.unit)}`;

function taskCard(task, paint) {
  const name = taskLabel(task.kind);
  const pct = Math.max(0, Math.min(100, Math.round(task.ratio * 100)));
  const bar = h('div', {
    class: 'progress', role: 'progressbar', 'data-testid': 'care-progress',
    'aria-valuemin': '0', 'aria-valuemax': String(task.limit), 'aria-valuenow': String(Math.min(task.current, task.limit)),
    'aria-valuetext': progressText(task), 'aria-label': t('care.progressAria', { task: name, device: task.device.name }),
  }, h('div', { class: 'progress__fill' }));
  bar.firstChild.style.setProperty('--pct', String(pct));
  return h('li', {
    class: 'card task' + (task.overdue ? ' is-overdue' : ''), 'data-testid': 'care-task',
    'data-kind': task.kind, 'data-device': task.device.id,
  },
    h('div', { class: 'task__head' },
      h('div', null,
        h('h2', { class: 'task__name heading' }, name),
        h('p', { class: 'task__device', 'data-testid': 'care-device' }, task.device.name)),
      task.overdue ? h('span', { class: 'chip chip--error', 'data-testid': 'care-overdue' }, t('care.overdue')) : null),
    bar,
    h('p', { class: 'task__text', 'data-testid': 'care-progress-text' }, h('strong', null, progressText(task))),
    button({
      label: t('care.done'), variant: task.overdue ? 'primary' : 'secondary', testid: 'care-done', iconName: 'check',
      onClick: () => {
        markDone(task.kind, task.device.id);
        showToast('success', t('care.doneToast'));
        paint();
      },
    }));
}

function build(_state, paint) {
  const tasks = cleaningTasks(getState(), new Date());
  if (!tasks.length) {
    return [
      pageHeader(t('screen.care')),
      emptyState({ iconName: 'brush', title: t('care.empty.title'), text: t('care.empty.text'), actionLabel: t('dev.add'), onAction: () => { window.location.hash = '#/equipment'; } }),
    ];
  }
  return [
    pageHeader(t('screen.care')),
    h('ul', { class: 'task-list' }, tasks.map((task) => taskCard(task, paint))),
  ];
}

export const renderCare = makeView(build);
