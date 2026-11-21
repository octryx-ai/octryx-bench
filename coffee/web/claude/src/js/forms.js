// Form building for dialogs: fields carry data-testid field-<name>; inline errors carry error-<name>.
import { h } from './dom.js';
import { icon } from './icons.js';
import { t } from './i18n.js';
import { button, showToast } from './ui.js';
import { openDialog, dialogActions, cancelButton, errorBox } from './dialog.js';

let uid = 0;
// model error field -> form control name
const ALIASES = { type: 'grinderType', range: 'rangeMax', retention: 'retentionG', leadTime: 'leadTimeDays', roaster: 'roasterId', bean: 'beanId',
  dose: 'doseG', yield: 'yieldG', time: 'timeS', temp: 'tempC', bag: 'bagId', machine: 'machineId', grinder: 'grinderId', setting: 'grinderSetting', water: 'waterG' };

export function parseNum(s) {
  const v = String(s ?? '').trim().replace(',', '.');
  return v === '' ? undefined : Number(v);
}

function messageOf(v) {
  if (typeof v === 'string') return t(v);
  if (v && typeof v === 'object') return t(v.key || v.messageKey || 'err.generic', v.params || { n: v.count });
  return t('err.generic');
}

export function createForm() {
  const controls = {};
  const wrappers = {};
  const errEls = {};

  function wrap(name, label, control, { unit, hint, hidden } = {}) {
    const id = 'ff' + ++uid;
    control.id = id;
    control.setAttribute('data-testid', 'field-' + name);
    controls[name] = control;
    const input = unit
      ? h('div', { class: 'input-wrap input-wrap--unit' }, control, h('span', { class: 'input__unit' }, unit))
      : control;
    const el = h('div', { class: 'field', hidden }, h('label', { class: 'field__label', for: id }, label), input,
      hint && h('p', { class: 'field__hint', id: id + '-hint' }, hint));
    wrappers[name] = el;
    return el;
  }

  const api = {
    controls,
    wrappers,
    text(name, label, { value = '', unit, inputmode, placeholder, type = 'text', hint, hidden, maxlength, autocomplete = 'off' } = {}) {
      const c = h('input', { class: 'input', type, inputmode, placeholder, maxlength, autocomplete });
      c.value = value;
      return wrap(name, label, c, { unit, hint, hidden });
    },
    textarea(name, label, { value = '' } = {}) {
      const c = h('textarea', { class: 'input textarea', rows: 3 });
      c.value = value;
      return wrap(name, label, c);
    },
    select(name, label, options, value, { hidden } = {}) {
      const c = h('select', { class: 'select' }, options.map(([v, text]) => h('option', { value: v }, text)));
      if (value != null) c.value = value;
      return wrap(name, label, c, { hidden });
    },
    checkbox(name, label, checked = false) {
      const c = h('input', { type: 'checkbox' });
      c.checked = checked;
      c.id = 'ff' + ++uid;
      c.setAttribute('data-testid', 'field-' + name);
      controls[name] = c;
      const el = h('div', { class: 'field' }, h('label', { class: 'check', for: c.id }, c, h('span', null, label)));
      wrappers[name] = el;
      return el;
    },
    val(name) {
      const c = controls[name];
      if (!c) return undefined;
      return c.type === 'checkbox' ? c.checked : c.value;
    },
    num(name) { return parseNum(api.val(name)); },
    str(name) { return String(api.val(name) ?? '').trim(); },
    clearErrors() {
      for (const [name, el] of Object.entries(errEls)) {
        el.remove();
        controls[name]?.removeAttribute('aria-invalid');
        controls[name]?.removeAttribute('aria-describedby');
        delete errEls[name];
      }
    },
    clearError(name) {
      const el = errEls[name];
      if (!el) return;
      el.remove();
      controls[name]?.removeAttribute('aria-invalid');
      controls[name]?.removeAttribute('aria-describedby');
      delete errEls[name];
    },
    /** Places errors under their fields; returns messages that have no field (e.g. _limit). */
    setErrors(errors) {
      api.clearErrors();
      const leftover = [];
      let firstBad = null;
      for (const [field, v] of Object.entries(errors || {})) {
        const name = controls[field] ? field : (controls[ALIASES[field]] ? ALIASES[field] : null);
        if (field === '_limit' || !name || wrappers[name].hidden) { leftover.push(messageOf(v)); continue; }
        const id = controls[name].id + '-err';
        const err = h('p', { class: 'field__error', id, role: 'alert', 'data-testid': 'error-' + name }, icon('alert', 'icon--sm'), messageOf(v));
        wrappers[name].append(err);
        errEls[name] = err;
        controls[name].setAttribute('aria-invalid', 'true');
        controls[name].setAttribute('aria-describedby', id);
        firstBad = firstBad || controls[name];
      }
      return { leftover, firstBad };
    },
  };
  return api;
}

/**
 * Opens a dialog with a form. build(form) returns the field elements; submit(form) returns the model result
 * ({ok,item} | {ok:false,errors}). On success the dialog closes, a toast shows and onSaved(item) runs.
 */
export function openFormDialog({ title, build, submit, onSaved }) {
  const form = createForm();
  const box = errorBox();
  let dlg;
  const save = button({ label: t('action.save'), variant: 'primary', type: 'submit', testid: 'dialog-save' });
  const el = h('form', {
    class: 'dialog__form', novalidate: true,
    onSubmit: (e) => {
      e.preventDefault();
      box.clear();
      let res;
      try { res = submit(form); } catch { res = { ok: false, errors: { _form: 'err.generic' } }; }
      if (res?.ok) {
        dlg.close();
        showToast('success', t('toast.saved'));
        onSaved?.(res.item);
        return;
      }
      const { leftover, firstBad } = form.setErrors(res?.errors);
      if (leftover.length) box.show(leftover);
      else if (!firstBad) box.show([t('err.generic')]);
      firstBad?.focus();
    },
  }, build(form), box, dialogActions(cancelButton(() => dlg.close()), save));
  dlg = openDialog({ title, content: el });
  return { dlg, form };
}
