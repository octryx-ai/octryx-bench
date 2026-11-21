import { t } from '../i18n.js';
import { openFormDialog } from '../forms.js';
import * as M from '../models.js';
import { fmtNum } from './common.js';

export const MACHINE_TYPES = ['espresso', 'filter'];
export const GRINDER_TYPES = ['stepped', 'stepless', 'numbered', 'hand'];

function defaultStep(type, min, max) {
  if (type !== 'stepless') return 1;
  const r = (max - min) * 0.05;
  return Number.isFinite(r) && r > 0 ? Math.round(r * 1000) / 1000 : undefined;
}

function openMachineDialog({ item, onDone }) {
  return openFormDialog({
    title: t(item ? 'dev.dialog.editMachine' : 'dev.dialog.addMachine'),
    build: (f) => [
      f.text('name', t('dev.field.name'), { value: item?.name ?? '', maxlength: 80 }),
      f.select('type', t('dev.field.type'), MACHINE_TYPES.map((k) => [k, t('dev.machine.' + k)]), item?.type ?? 'espresso'),
    ],
    submit: (f) => {
      const patch = { name: f.str('name'), type: f.val('type') };
      return item ? M.updateMachine(item.id, patch) : M.createMachine(patch);
    },
    onSaved: onDone,
  });
}

function openGrinderDialog({ item, onDone }) {
  const initType = item?.type ?? 'stepped';
  let unitAuto = !item;
  let stepAuto = !item;
  const { dlg, form } = openFormDialog({
    title: t(item ? 'dev.dialog.editGrinder' : 'dev.dialog.addGrinder'),
    build: (f) => {
      const minV = item?.rangeMin ?? 0;
      const maxV = item?.rangeMax ?? 10;
      return [
        f.text('name', t('dev.field.name'), { value: item?.name ?? '', maxlength: 80 }),
        f.select('grinderType', t('dev.field.grinderType'), GRINDER_TYPES.map((k) => [k, t('dev.grinder.' + k)]), initType),
        f.text('settingUnit', t('dev.field.settingUnit'), { value: item?.settingUnit ?? t('dev.unit.' + initType) }),
        f.text('rangeMin', t('dev.field.rangeMin'), { value: fmtNum(minV), inputmode: 'decimal', hidden: initType !== 'stepless' }),
        f.text('rangeMax', t('dev.field.rangeMax'), { value: fmtNum(maxV), inputmode: 'decimal', hidden: initType !== 'stepless' }),
        f.text('stepSize', t('dev.field.stepSize'), { value: fmtNum(item?.stepSize ?? defaultStep(initType, minV, maxV)), inputmode: 'decimal' }),
        f.text('retentionG', t('dev.field.retentionG'), { value: fmtNum(item?.retentionG ?? 0.5), type: 'number', unit: 'g' }),
        f.checkbox('higherIsFiner', t('dev.field.higherIsFiner'), !!item?.higherIsFiner),
      ];
    },
    submit: (f) => {
      const type = f.val('grinderType');
      const patch = {
        name: f.str('name'), type, settingUnit: f.str('settingUnit'),
        stepSize: f.num('stepSize'), retentionG: f.num('retentionG'), higherIsFiner: f.val('higherIsFiner'),
      };
      if (type === 'stepless') { patch.rangeMin = f.num('rangeMin'); patch.rangeMax = f.num('rangeMax'); }
      for (const k of Object.keys(patch)) if (patch[k] === undefined) delete patch[k];
      return item ? M.updateGrinder(item.id, patch) : M.createGrinder(patch);
    },
    onSaved: onDone,
  });
  const c = form.controls;
  c.retentionG.min = '0'; c.retentionG.max = '5'; c.retentionG.step = '0.1';
  // number input needs a dot value
  c.retentionG.value = String(item?.retentionG ?? 0.5);

  function refreshAuto() {
    const type = c.grinderType.value;
    const isLess = type === 'stepless';
    form.wrappers.rangeMin.hidden = !isLess;
    form.wrappers.rangeMax.hidden = !isLess;
    if (unitAuto) c.settingUnit.value = t('dev.unit.' + type);
    if (stepAuto) c.stepSize.value = fmtNum(defaultStep(type, form.num('rangeMin') ?? 0, form.num('rangeMax') ?? 10));
  }
  c.grinderType.addEventListener('change', refreshAuto);
  c.rangeMin.addEventListener('input', refreshAuto);
  c.rangeMax.addEventListener('input', refreshAuto);
  c.settingUnit.addEventListener('input', () => { unitAuto = false; });
  c.stepSize.addEventListener('input', () => { stepAuto = false; });
  return dlg;
}

export function openDeviceDialog({ kind, item, onDone }) {
  return kind === 'machine' ? openMachineDialog({ item, onDone }) : openGrinderDialog({ item, onDone });
}
