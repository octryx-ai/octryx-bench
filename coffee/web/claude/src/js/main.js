import { loadState, getState, subscribe } from './store.js';
import { getLang, setLang, onLangChange } from './i18n.js';
import { startRouter } from './router.js';
import { buildShell } from './shell.js';
import { renderScreen } from './screens/index.js';

let match = null;
let moreOpen = false;
let queued = false;
let navVariant = 'sidebar';

const root = () => document.getElementById('app');

// Breakpoints live in tokens.css (--bp-tablet, --bp-desktop); read them so no px literal is needed here.
function breakpoint(name) {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
}
function variantNow() {
  if (window.matchMedia(`(min-width: ${breakpoint('--bp-desktop')})`).matches) return 'sidebar';
  if (window.matchMedia(`(min-width: ${breakpoint('--bp-tablet')})`).matches) return 'rail';
  return 'tabbar';
}

function applyPreferences() {
  const { language, theme } = getState().settings;
  if (language !== getLang()) setLang(language);
  document.documentElement.dataset.theme = theme || 'system';
  document.documentElement.lang = getLang();
}

function render() {
  queued = false;
  if (!match) return;
  applyPreferences();
  navVariant = variantNow();
  const focusId = document.activeElement?.getAttribute?.('data-testid');
  const shell = buildShell({
    focus: match.route.name === 'guided',
    activeNav: match.route.nav,
    variant: navVariant,
    moreOpen,
    onToggleMore: () => { moreOpen = !moreOpen; scheduleRender(); },
    content: renderScreen(match),
  });
  root().replaceChildren(shell);
  document.title = `${document.querySelector('h1')?.textContent || ''} · Coffee Companion`;
  if (focusId) document.querySelector(`[data-testid="${focusId}"]`)?.focus();
}

export function scheduleRender() {
  if (queued) return;
  queued = true;
  queueMicrotask(render);
}

function start() {
  loadState();
  applyPreferences();
  subscribe(scheduleRender);
  onLangChange(scheduleRender);
  for (const bp of ['--bp-desktop', '--bp-tablet']) {
    window.matchMedia(`(min-width: ${breakpoint(bp)})`).addEventListener('change', scheduleRender);
  }
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && moreOpen) { moreOpen = false; scheduleRender(); }
  });
  startRouter((m) => {
    const changed = !match || match.route.name !== m.route.name || match.params.id !== m.params.id;
    match = m;
    moreOpen = false;
    render();
    if (changed) window.scrollTo(0, 0);
  });
}

start();
