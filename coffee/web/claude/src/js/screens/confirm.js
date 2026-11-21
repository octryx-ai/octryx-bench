// Small confirmation dialog: testids confirm-dialog (via dialog), confirm-ok, confirm-cancel.
import { h } from '../dom.js';
import { t } from '../i18n.js';
import { button } from '../ui.js';
import { openDialog, dialogActions } from '../dialog.js';

export function confirmDialog({ title, text, confirmLabel = t('action.confirm'), onConfirm }) {
  let dlg;
  const ok = button({ label: confirmLabel, variant: 'primary', testid: 'confirm-ok', onClick: () => { dlg.close(); onConfirm(); } });
  const cancel = button({ label: t('action.cancel'), variant: 'secondary', testid: 'confirm-cancel', onClick: () => dlg.close() });
  dlg = openDialog({
    title,
    content: h('div', { class: 'dialog__form', 'data-testid': 'confirm-dialog' }, h('p', { class: 'dialog__message' }, text), dialogActions(cancel, ok)),
    focus: cancel,
  });
  return dlg;
}
