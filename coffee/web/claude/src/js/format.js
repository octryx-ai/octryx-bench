import { getLang } from './i18n.js';

const EN_MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export function formatNumber(n, decimals = 1, lang = getLang()) {
  const s = Number(n).toFixed(decimals);
  return lang === 'de' ? s.replace('.', ',') : s;
}

export function formatGrams(n, lang = getLang()) {
  return `${formatNumber(n, 1, lang)} g`;
}

export function formatSeconds(n, lang = getLang()) {
  return `${formatNumber(n, Number.isInteger(n) ? 0 : 1, lang)} s`;
}

export function formatDate(iso, lang = getLang()) {
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(iso);
  const d = m ? new Date(+m[1], m[2] - 1, +m[3]) : new Date(iso);
  if (Number.isNaN(d.getTime())) return '';
  return lang === 'de' ? `${d.getDate()}.${d.getMonth() + 1}.` : `${d.getDate()} ${EN_MONTHS[d.getMonth()]}`;
}

export function formatTimer(ms) {
  const tenths = Math.floor(Math.max(0, ms) / 100);
  const mm = String(Math.floor(tenths / 600)).padStart(2, '0');
  const ss = String(Math.floor(tenths / 10) % 60).padStart(2, '0');
  return `${mm}:${ss}.${tenths % 10}`;
}
