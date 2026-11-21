import { h } from '../dom.js';
import { t } from '../i18n.js';
import { openFormDialog } from '../forms.js';
import * as M from '../models.js';
import { fmtNum, todayIso } from './common.js';

export const ROAST_LEVELS = ['light', 'medium', 'dark'];
const NEW_ROASTER = '__new';

export function openRoasterDialog({ item, onDone }) {
  return openFormDialog({
    title: t(item ? 'roaster.edit' : 'beans.addRoaster'),
    build: (f) => [
      f.text('name', t('roaster.name'), { value: item?.name ?? '', maxlength: 80 }),
      f.text('url', t('roaster.url'), { value: item?.url ?? '', type: 'url', inputmode: 'url', placeholder: 'https://' }),
      f.text('leadTimeDays', t('roaster.leadTime'), { value: String(item?.leadTimeDays ?? 3), inputmode: 'numeric' }),
    ],
    submit: (f) => {
      const patch = { name: f.str('name'), url: f.str('url'), leadTimeDays: f.num('leadTimeDays') };
      if (patch.leadTimeDays === undefined) delete patch.leadTimeDays;
      return item ? M.updateRoaster(item.id, patch) : M.createRoaster(patch);
    },
    onSaved: onDone,
  });
}

export function openBeanDialog({ item, onDone }) {
  const roasters = M.listRoasters();
  const initial = item?.roasterId ?? roasters[0]?.id ?? NEW_ROASTER;
  const { form } = openFormDialog({
    title: t(item ? 'bean.edit' : 'beans.addBean'),
    build: (f) => [
      f.text('name', t('bean.name'), { value: item?.name ?? '', maxlength: 80 }),
      f.select('roasterId', t('bean.roaster'), [...roasters.map((r) => [r.id, r.name]), [NEW_ROASTER, t('bean.newRoaster')]], initial),
      f.text('newRoaster', t('bean.newRoasterName'), { hidden: initial !== NEW_ROASTER }),
      f.text('origin', t('bean.origin'), { value: item?.origin ?? '' }),
      f.select('roastLevel', t('bean.roastLevel'), ROAST_LEVELS.map((k) => [k, t('roast.' + k)]), item?.roastLevel ?? 'medium'),
      f.textarea('notes', t('bean.notes'), { value: item?.notes ?? '' }),
    ],
    submit: (f) => {
      let roasterId = f.val('roasterId');
      if (roasterId === NEW_ROASTER) {
        const r = M.createRoaster({ name: f.str('newRoaster') });
        if (!r.ok) {
          const { name, ...rest } = r.errors || {};
          return { ok: false, errors: { ...rest, ...(name ? { newRoaster: name } : {}) } };
        }
        roasterId = r.item.id;
        const sel = f.controls.roasterId;
        sel.insertBefore(h('option', { value: roasterId }, r.item.name), sel.querySelector(`option[value="${NEW_ROASTER}"]`));
        sel.value = roasterId;
        f.wrappers.newRoaster.hidden = true;
      }
      const patch = { roasterId, name: f.str('name'), origin: f.str('origin'), roastLevel: f.val('roastLevel'), notes: f.str('notes') };
      return item ? M.updateBean(item.id, patch) : M.createBean(patch);
    },
    onSaved: onDone,
  });
  const sel = form.controls.roasterId;
  sel.addEventListener('change', () => { form.wrappers.newRoaster.hidden = sel.value !== NEW_ROASTER; });
}

export function openBagDialog({ item, beanId, onDone }) {
  const roasterName = new Map(M.listRoasters().map((r) => [r.id, r.name]));
  const beans = M.listBeans();
  const options = beans.map((b) => [b.id, roasterName.get(b.roasterId) ? `${b.name} · ${roasterName.get(b.roasterId)}` : b.name]);
  if (item && !beans.some((b) => b.id === item.beanId)) {
    const b = M.listBeans({ includeArchived: true }).find((x) => x.id === item.beanId);
    if (b) options.push([b.id, b.name]);
  }
  let remainingAuto = !item;
  const { form } = openFormDialog({
    title: t(item ? 'bag.edit' : 'beans.addBag'),
    build: (f) => [
      f.select('beanId', t('bag.bean'), options, item?.beanId ?? beanId ?? options[0]?.[0]),
      f.text('roastDate', t('bag.roastDate'), { type: 'date', value: item?.roastDate ?? todayIso() }),
      f.text('weightG', t('bag.weightG'), { value: fmtNum(item?.weightG ?? 250), inputmode: 'decimal', unit: 'g' }),
      f.text('remainingG', t('bag.remainingG'), { value: fmtNum(item?.remainingG ?? 250), inputmode: 'decimal', unit: 'g' }),
      f.text('price', t('bag.price'), { value: item?.price != null ? fmtNum(item.price) : '', inputmode: 'decimal', unit: '€' }),
      f.text('openedOn', t('bag.openedOn'), { type: 'date', value: item?.openedOn ?? '' }),
    ],
    submit: (f) => {
      const patch = {
        beanId: f.val('beanId'), roastDate: f.val('roastDate'), weightG: f.num('weightG'), remainingG: f.num('remainingG'),
        price: f.num('price') ?? null, openedOn: f.val('openedOn') || null,
      };
      return item ? M.updateBag(item.id, patch) : M.createBag(patch);
    },
    onSaved: onDone,
  });
  const c = form.controls;
  c.weightG.addEventListener('input', () => { if (remainingAuto) c.remainingG.value = c.weightG.value; });
  c.remainingG.addEventListener('input', () => { remainingAuto = false; });
}
