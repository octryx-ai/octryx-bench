// Accessible modal dialog: role=dialog, aria-modal, focus trap, Esc closes, focus returns to the opener.
// Mounted on document.body (outside #app) so screen re-renders never destroy it.
import { h } from './dom.js';
import { icon } from './icons.js';
import { t } from './i18n.js';
import { button } from './ui.js';

const FOCUSABLE = 'button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), a[href], [tabindex]:not([tabindex="-1"])';
let counter = 0;
let open = 0;

function visible(el) {
  return !el.closest('[hidden]') && el.getClientRects().length > 0;
}

export function openDialog({ title, content, focus, onClose }) {
  const opener = document.activeElement;
  const openerId = opener?.getAttribute?.('data-testid');
  const titleId = 'dlg-title-' + ++counter;
  const dlg = h('div', { class: 'dialog', role: 'dialog', 'aria-modal': 'true', 'aria-labelledby': titleId, tabindex: '-1', 'data-testid': 'dialog' },
    h('h2', { id: titleId, class: 'dialog__title' }, title), content);
  const scrim = h('div', { class: 'dialog-scrim', onClick: (e) => { if (e.target === scrim) close(); } }, dlg);
  let closed = false;

  function onKey(e) {
    if (e.key === 'Escape') { e.preventDefault(); e.stopPropagation(); close(); return; }
    if (e.key !== 'Tab') return;
    const items = [...dlg.querySelectorAll(FOCUSABLE)].filter(visible);
    if (!items.length) { e.preventDefault(); dlg.focus(); return; }
    const first = items[0];
    const last = items[items.length - 1];
    if (!dlg.contains(document.activeElement)) { e.preventDefault(); first.focus(); }
    else if (e.shiftKey && (document.activeElement === first || document.activeElement === dlg)) { e.preventDefault(); last.focus(); }
    else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
  }

  function close() {
    if (closed) return;
    closed = true;
    window.removeEventListener('hashchange', close);
    document.removeEventListener('keydown', onKey, true);
    scrim.remove();
    if (--open === 0) document.getElementById('app')?.removeAttribute('inert');
    const back = opener?.isConnected ? opener : (openerId && document.querySelector(`[data-testid="${openerId}"]`));
    back?.focus?.();
    onClose?.();
  }

  open++;
  window.addEventListener('hashchange', close, { once: true });
  document.getElementById('app')?.setAttribute('inert', '');
  document.body.append(scrim);
  document.addEventListener('keydown', onKey, true);
  const target = focus || [...dlg.querySelectorAll(FOCUSABLE)].filter(visible)[0] || dlg;
  target.focus();
  return { close, el: dlg };
}

export function dialogActions(...buttons) {
  return h('div', { class: 'dialog__actions' }, buttons);
}

export function cancelButton(onClick, label = t('action.cancel')) {
  return button({ label, variant: 'secondary', testid: 'dialog-cancel', onClick });
}

export function errorBox() {
  const box = h('p', { class: 'dialog__error', role: 'alert', hidden: true, 'data-testid': 'dialog-error' });
  box.show = (messages) => {
    box.replaceChildren(icon('alert', 'icon--sm'), h('span', null, messages.join(' ')));
    box.hidden = false;
  };
  box.clear = () => { box.hidden = true; box.replaceChildren(); };
  return box;
}

/** Shown when a delete is blocked because brews use the item; offers "Archivieren". */
export function blockedDialog({ result, onArchive }) {
  const message = t(result.messageKey || 'err.inUse.item', { n: result.count ?? 0 });
  const box = errorBox();
  box.show([message]);
  let dlg;
  const buttons = [cancelButton(() => dlg.close(), t('action.close'))];
  let archiveBtn = null;
  if (result.canArchive !== false) {
    archiveBtn = button({ label: t('action.archive'), variant: 'primary', testid: 'archive-instead', onClick: () => { dlg.close(); onArchive(); } });
    buttons.push(archiveBtn);
  }
  dlg = openDialog({
    title: t('del.blockedTitle'),
    content: h('div', { class: 'dialog__form' }, box, dialogActions(...buttons)),
    focus: archiveBtn?.querySelector ? archiveBtn : undefined,
  });
  return dlg;
}
