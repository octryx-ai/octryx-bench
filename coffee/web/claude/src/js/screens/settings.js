// Einstellungen (SPEC UI screen 9): language, theme and rule defaults are edited as pending values and all saved with 'Speichern'; export/import/reset.
import { h } from '../dom.js';
import { t, getLang, setLang } from '../i18n.js';
import { getState, saveSettings, exportJson, exportFilename, importJson, resetState, emptyState } from '../store.js';
import { formatGrams } from '../format.js';
import { button, pageHeader, showToast } from '../ui.js';
import { createForm } from '../forms.js';
import { icon } from '../icons.js';
import { fmtNum } from './common.js';
import { confirmDialog } from './confirm.js';

const RULES = [
  ['espressoTimeMinS', 'unit.s'], ['espressoTimeMaxS', 'unit.s'], ['backflushSeconds', 'unit.s'], ['backflushDays', 'unit.days'],
  ['grinderCleanG', 'unit.g'], ['descaleBaseDays', 'unit.days'], ['hardnessTargetPpm', 'unit.ppm'], ['filterRatio', null],
  ['plannedShotsPerDay', 'unit.perDay'], ['targetCoverDays', 'unit.days'], ['idlePurgeHours', 'unit.h'], ['bloomFactor', 'unit.xDose'],
];

function select(id, label, testid, value, options, onChange) {
  const sel = h('select', { id, class: 'select', 'data-testid': testid, onChange: (e) => onChange(e.target.value) },
    options.map(([v, text]) => h('option', { value: v, selected: v === value }, text)));
  sel.value = value;
  return h('div', { class: 'field' }, h('label', { class: 'field__label', for: id }, label), sel);
}

function download(text, filename) {
  const url = URL.createObjectURL(new Blob([text], { type: 'application/json' }));
  const a = h('a', { href: url, download: filename });
  document.body.append(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

// Cheap structural check so an invalid file is rejected before the confirmation dialog.
function looksValid(text) {
  let raw;
  try { raw = JSON.parse(text); } catch { return false; }
  if (!raw || typeof raw !== 'object' || Array.isArray(raw) || raw.version !== 1) return false;
  const lists = Object.entries(emptyState()).filter(([, v]) => Array.isArray(v)).map(([k]) => k);
  return lists.every((k) => Array.isArray(raw[k])) && (raw.settings === undefined || (typeof raw.settings === 'object' && raw.settings !== null && !Array.isArray(raw.settings)));
}

function rulesForm(settings, pending) {
  const form = createForm();
  const fields = RULES.map(([name, unitKey]) => {
    const el = form.text(name, t('settings.field.' + name), { value: fmtNum(settings[name]), unit: unitKey ? t(unitKey) : undefined, inputmode: 'decimal' });
    form.controls[name].setAttribute('data-testid', 'settings-' + name);
    return el;
  });
  const save = (e) => {
    e?.preventDefault();
    const patch = {};
    for (const [name] of RULES) patch[name] = form.str(name).replace(',', '.');
    patch.theme = pending.theme;
    const res = saveSettings(patch);
    if (res.ok) {
      if (pending.language !== getLang()) setLang(pending.language);
      form.clearErrors();
      showToast('success', t('settings.saved'));
      return;
    }
    const { firstBad } = form.setErrors(res.errors);
    firstBad?.focus();
  };
  return { fields, save };
}

export function renderSettings(route) {
  const lang = getLang();
  const settings = getState().settings;
  const theme = settings.theme || 'system';
  const pending = { language: lang, theme };
  const rules = rulesForm(settings, pending);
  const importError = h('p', { class: 'import-error', role: 'alert', hidden: true, 'data-testid': 'import-error' });
  const fileInput = h('input', {
    type: 'file', accept: 'application/json,.json', class: 'hidden-input', tabindex: '-1', 'aria-hidden': 'true', 'data-testid': 'import-file',
    onChange: async (e) => {
      const file = e.target.files?.[0];
      e.target.value = '';
      importError.hidden = true;
      if (!file) return;
      const text = await file.text();
      if (!looksValid(text)) {
        importError.replaceChildren(icon('alert', 'icon--sm'), h('span', null, t('settings.importInvalid')));
        importError.hidden = false;
        return;
      }
      confirmDialog({
        title: t('settings.importTitle'), text: t('settings.importText'), confirmLabel: t('settings.importConfirm'),
        onConfirm: () => {
          try { importJson(text); showToast('success', t('settings.imported')); } catch {
            importError.replaceChildren(icon('alert', 'icon--sm'), h('span', null, t('settings.importInvalid')));
            importError.hidden = false;
          }
        },
      });
    },
  });

  return h('div', { class: 'page', 'data-testid': route.testid },
    pageHeader(t(route.titleKey)),
    h('div', { class: 'settings-page' },
      h('section', { class: 'card settings-form' },
        h('h2', null, t('settings.appearance')),
        select('set-lang', t('settings.language'), 'settings-language', lang, [
          ['de', t('settings.languageDe')], ['en', t('settings.languageEn')],
        ], (v) => { pending.language = v; }),
        select('set-theme', t('settings.theme'), 'settings-theme', theme, [
          ['light', t('settings.themeLight')], ['dark', t('settings.themeDark')], ['system', t('settings.themeSystem')],
        ], (v) => { pending.theme = v; }),
        h('div', { class: 'settings-row', 'data-testid': 'settings-number-sample' },
          h('span', null, t('settings.numberSample')),
          h('span', { class: 'settings-row__value' }, formatGrams(18, lang))),
        h('a', { class: 'link-touch', href: '#/styleguide', 'data-testid': 'link-styleguide' }, t('settings.styleguideLink'))),
      h('form', { class: 'card settings-form', novalidate: true, onSubmit: rules.save },
        h('h2', null, t('settings.rules')),
        h('p', { class: 'muted' }, t('settings.rulesText')),
        h('div', { class: 'field-grid--settings' }, rules.fields),
        h('div', { class: 'settings-actions' }, button({ label: t('settings.save'), type: 'submit', testid: 'settings-save' }))),
      h('section', { class: 'card settings-form' },
        h('h2', null, t('settings.data')),
        h('div', { class: 'btn-row' },
          button({ label: t('settings.export'), variant: 'secondary', testid: 'export-data', onClick: () => { download(exportJson(), exportFilename(new Date())); showToast('success', t('settings.exported')); } }),
          button({ label: t('settings.import'), variant: 'secondary', testid: 'import-data', onClick: () => fileInput.click() }),
          fileInput,
          button({ label: t('settings.reset'), variant: 'secondary', iconName: 'trash', testid: 'reset-data', onClick: () => confirmDialog({
            title: t('settings.resetTitle'), text: t('settings.resetText'), confirmLabel: t('settings.resetConfirm'),
            onConfirm: () => { resetState(); showToast('success', t('settings.resetDone')); },
          }) })),
        importError)));
}
