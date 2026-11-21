// Shot timer (SPEC 6): Start/Stop button, display mm:ss.s, polite status line. Stop reports timeS with 1 decimal.
import { h } from './dom.js';
import { t } from './i18n.js';
import { button } from './ui.js';
import { formatTimer, formatNumber } from './format.js';

const TICK_MS = 100;

export function createTimer({ onStop, compact = false } = {}) {
  let state = 'idle';
  let startedAt = 0;
  let handle = null;

  const display = h('div', { class: 'timer__value', role: 'timer', 'aria-label': t('timer.label'), 'data-testid': 'timer-display' }, formatTimer(0));
  const live = h('p', { class: 'timer__status', role: 'status', 'aria-live': 'polite', 'data-testid': 'timer-live' }, t('timer.idle'));
  const toggle = button({ label: t('timer.start'), variant: 'secondary', iconName: 'play', testid: 'timer-toggle', onClick: () => (state === 'running' ? stop() : start()) });
  const el = h('div', { class: 'timer timer--idle' + (compact ? ' timer--compact' : ''), 'data-testid': 'timer' },
    display, h('div', { class: 'timer__side' }, toggle, live));

  const paintToggle = (label, iconName) => {
    toggle.replaceChildren(...button({ label, iconName }).childNodes);
  };
  const setState = (s) => { state = s; el.className = el.className.replace(/timer--(idle|running|stopped)/, 'timer--' + s); };
  const elapsed = () => performance.now() - startedAt;

  function tick() {
    if (!el.isConnected) { clearInterval(handle); handle = null; return; }
    display.textContent = formatTimer(elapsed());
  }

  function start() {
    startedAt = performance.now();
    display.textContent = formatTimer(0);
    setState('running');
    paintToggle(t('timer.stop'), 'stop');
    live.textContent = t('timer.running');
    clearInterval(handle);
    handle = setInterval(tick, TICK_MS);
  }

  function stop() {
    clearInterval(handle);
    handle = null;
    const ms = elapsed();
    const timeS = Math.round(ms / 100) / 10;
    display.textContent = formatTimer(ms);
    setState('stopped');
    paintToggle(t('timer.start'), 'play');
    live.textContent = t('timer.stopped', { time: formatNumber(timeS, 1) });
    onStop?.(timeS);
  }

  return { el, start, stop, get state() { return state; } };
}
