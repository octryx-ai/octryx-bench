import de from './locales/de.js';
import en from './locales/en.js';
import { getState, updateSettings } from './store.js';

const DICTS = { de, en };
const listeners = new Set();

export function getLang() {
  const lang = getState().settings.language;
  return lang in DICTS ? lang : 'de';
}

export function t(key, params = {}) {
  const text = DICTS[getLang()][key] ?? de[key] ?? key;
  return text.replace(/\{(\w+)\}/g, (m, name) => (name in params ? params[name] : m));
}

function applyDocumentLang() {
  if (typeof document !== 'undefined') document.documentElement.lang = getLang();
}

export function setLang(lang) {
  if (!(lang in DICTS)) return;
  updateSettings({ language: lang });
  applyDocumentLang();
  for (const fn of [...listeners]) fn(lang);
}

export function onLangChange(fn) {
  listeners.add(fn);
  return () => listeners.delete(fn);
}

applyDocumentLang();
