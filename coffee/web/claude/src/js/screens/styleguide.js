import { h } from '../dom.js';
import { icon } from '../icons.js';
import { t } from '../i18n.js';
import { formatTimer } from '../format.js';
import { pageHeader, button, chip, field, stepper, recommendation, toastElement, showToast } from '../ui.js';

const cell = (stateKey, ...kids) => h('div', { class: 'sg__cell' }, h('span', { class: 'sg__state' }, t(stateKey)), ...kids);
const section = (id, titleKey, ...kids) =>
  h('section', { class: 'sg__section', 'data-testid': 'sg-' + id }, h('h2', null, t(titleKey)), ...kids);

function colors() {
  const sw = (cls, key) => h('div', { class: 'swatch' }, h('div', { class: 'swatch__color swatch__color--' + cls }), t(key));
  return section('colors', 'sg.colors', h('div', { class: 'swatches' },
    sw('bg', 'sg.color.bg'), sw('surface', 'sg.color.surface'), sw('text', 'sg.color.text'), sw('muted', 'sg.color.muted'),
    sw('accent', 'sg.color.accent'), sw('ok', 'sg.color.ok'), sw('warn', 'sg.color.warn'), sw('error', 'sg.color.error')));
}

function buttons() {
  const label = t('sg.button.label');
  const row = (variant) => h('div', { class: 'sg__grid', 'data-testid': 'sg-button-' + variant },
    [['default', 'sg.state.default', {}], ['hover', 'sg.state.hover', { state: 'hover' }], ['focus', 'sg.state.focus', { state: 'focus' }],
      ['pressed', 'sg.state.pressed', { state: 'pressed' }], ['disabled', 'sg.state.disabled', { disabled: true }],
      ['loading', 'sg.state.loading', { loading: true, label: t('sg.button.loadingLabel') }]]
      .map(([, key, o]) => cell(key, button({ label, variant, ...o }))));
  return section('buttons', 'sg.buttons',
    ['primary', 'secondary', 'ghost'].map((v) => h('div', { class: 'sg__section' }, h('h3', null, t('sg.button.' + v)), row(v))));
}

function inputs() {
  const lbl = t('sg.input.label');
  return section('inputs', 'sg.inputs', h('div', { class: 'sg__grid' },
    cell('sg.state.default', field({ label: lbl, placeholder: t('sg.input.placeholder'), unit: 'g', inputmode: 'decimal' })),
    cell('sg.state.focus', field({ label: lbl, value: '18', unit: 'g', state: 'focus' })),
    cell('sg.state.filled', field({ label: lbl, value: '18', unit: 'g' })),
    cell('sg.state.error', field({ label: lbl, value: '80', unit: 'g', state: 'error', error: t('sg.input.error') })),
    cell('sg.state.disabled', field({ label: lbl, value: '18', unit: 'g', disabled: true })),
    cell('sg.input.stepperLabel', stepper({ label: lbl, value: '18.0', unit: 'g' }))));
}

function cards() {
  const sample = (extra = '') => h('article', { class: 'card card--interactive ' + extra },
    h('h3', { class: 'card__title' }, t('sg.card.title')),
    h('p', { class: 'card__meta' }, t('sg.card.text')),
    h('div', { class: 'card__row' }, chip('ok', t('sg.chip.ok'), 'check')));
  return section('cards', 'sg.cards', h('div', { class: 'sg__grid' },
    cell('sg.state.default', sample()),
    cell('sg.state.hover', sample('is-hover')),
    cell('sg.state.selected', sample('is-selected')),
    cell('sg.state.loading', h('div', { class: 'card card--state', 'aria-busy': 'true', 'aria-label': t('loading') },
      h('div', { class: 'skeleton' }, h('div', { class: 'skeleton__line' }), h('div', { class: 'skeleton__line' }), h('div', { class: 'skeleton__line' })))),
    cell('sg.state.empty', h('div', { class: 'card card--state card--empty' },
      icon('brews', 'icon--illustration'), h('h3', { class: 'card__title' }, t('sg.card.emptyTitle')),
      button({ label: t('sg.card.emptyAction'), iconName: 'plus' }))),
    cell('sg.state.error', h('div', { class: 'card card--state card--error', role: 'alert' },
      icon('alert', 'icon--illustration'), h('h3', { class: 'card__title' }, t('sg.card.errorTitle')),
      button({ label: t('sg.card.retry'), variant: 'secondary' })))));
}

function chips() {
  return section('chips', 'sg.chips', h('div', { class: 'sg__row' },
    chip('ok', t('sg.chip.ok'), 'check'), chip('warn', t('sg.chip.warn'), 'clock'),
    chip('error', t('sg.chip.error'), 'alert'), chip('neutral', t('sg.chip.neutral'))));
}

function recommendations() {
  return section('recommendation', 'sg.recommendation', h('div', { class: 'sg__grid' },
    cell('sg.state.shown', recommendation({ headline: t('sg.rec.headline'), steps: [t('sg.rec.step1'), t('sg.rec.step2')] })),
    cell('sg.state.keep', recommendation({ headline: t('sg.rec.keepHeadline'), steps: [t('sg.rec.keepStep')], keep: true })),
    cell('sg.state.none', h('p', { class: 'sg__hint', 'data-testid': 'sg-reco-none' }, t('sg.state.hidden')))));
}

function timerBox(state, text, testid) {
  return h('div', { class: 'timer timer--' + state, 'data-testid': testid },
    h('span', { class: 'timer__value num', 'aria-live': 'polite', 'aria-atomic': 'true', 'data-testid': testid + '-value' }, text));
}

function interactiveTimer() {
  const box = timerBox('idle', formatTimer(0), 'sg-timer-live');
  const value = box.querySelector('.timer__value');
  let startedAt = 0, raf = 0;
  const btn = button({ label: t('sg.timer.start'), testid: 'sg-timer-toggle' });
  const label = btn.querySelector('span');
  const tick = () => { value.textContent = formatTimer(Date.now() - startedAt); raf = setTimeout(tick, 100); };
  btn.addEventListener('click', () => {
    if (!startedAt) {
      startedAt = Date.now();
      value.setAttribute('aria-live', 'off'); // no announcement every 100 ms
      box.className = 'timer timer--running';
      label.textContent = t('sg.timer.stop');
      tick();
    } else {
      clearTimeout(raf);
      value.textContent = formatTimer(Date.now() - startedAt);
      value.setAttribute('aria-live', 'polite');
      box.className = 'timer timer--stopped';
      label.textContent = t('sg.timer.start');
      startedAt = 0;
    }
  });
  return h('div', { class: 'sg__cell' }, box, btn);
}

function timers() {
  return section('timer', 'sg.timer', h('div', { class: 'sg__grid' },
    cell('sg.state.idle', timerBox('idle', '00:00.0', 'sg-timer-idle')),
    cell('sg.state.running', timerBox('running', '00:12.4', 'sg-timer-running')),
    cell('sg.state.stopped', timerBox('stopped', '00:27.3', 'sg-timer-stopped')),
    cell('sg.timer.label', interactiveTimer())));
}

function staticToast(kind, text) {
  const el = toastElement(kind, text, { role: 'presentation' });
  el.classList.add('toast--static');
  return el;
}

function toasts() {
  return section('toast', 'sg.toast', h('div', { class: 'sg__grid' },
    cell('sg.chip.ok', staticToast('success', t('sg.toast.success'))),
    cell('sg.state.error', staticToast('error', t('sg.toast.error')))),
  h('div', { class: 'sg__row' },
    button({ label: t('sg.toast.show') + ': ' + t('sg.toast.success'), variant: 'secondary', testid: 'sg-toast-success', onClick: () => showToast('success', t('sg.toast.success')) }),
    button({ label: t('sg.toast.show') + ': ' + t('sg.toast.error'), variant: 'secondary', testid: 'sg-toast-error', onClick: () => showToast('error', t('sg.toast.error')) })),
  h('p', { class: 'sg__hint' }, t('sg.toast.hint')));
}

export function renderStyleguide(route) {
  return h('div', { class: 'page', 'data-testid': route.testid },
    pageHeader(t(route.titleKey)),
    h('p', { class: 'page-lead' }, t('sg.intro')),
    h('div', { class: 'sg' }, colors(), buttons(), inputs(), cards(), chips(), recommendations(), timers(), toasts()));
}
