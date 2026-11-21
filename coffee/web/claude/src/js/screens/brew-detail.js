// Brew detail (SPEC UI): all values, ratio, time class, purge, taste, recommendation, favourite, delete.
import { h } from '../dom.js';
import { icon } from '../icons.js';
import { t, getLang } from '../i18n.js';
import { button, pageHeader, showToast } from '../ui.js';
import { openDialog, dialogActions, cancelButton } from '../dialog.js';
import { formatNumber } from '../format.js';
import { navigate } from '../router.js';
import * as B from '../brews.js';
import { makeView, fmtNum } from './common.js';
import { tasteChip, timeClassChip, recommendationPanel, recFor, favButton, favStar, brewContext, brewAnchor, settingText } from './brew-parts.js';

const mmss = (s) => `${String(Math.floor(s / 60)).padStart(2, '0')}:${String(Math.round(s) % 60).padStart(2, '0')}`;

function row(label, value, testid) {
  return h('div', { class: 'detail-row' },
    h('dt', null, label),
    h('dd', { 'data-testid': testid }, value ?? '–'));
}

function confirmDelete(brew) {
  let dlg;
  const del = button({
    label: t('action.delete'), variant: 'primary', testid: 'confirm-delete',
    onClick: () => {
      dlg.close();
      B.removeBrew(brew.id);
      showToast('success', t('toast.deleted'));
      navigate('/brews');
    },
  });
  dlg = openDialog({
    title: t('detail.confirmTitle'),
    content: h('div', { class: 'dialog__form' },
      h('p', { class: 'dialog__message' }, t('detail.confirmText')),
      dialogActions(cancelButton(() => dlg.close()), del)),
  });
}

function notFound() {
  return [
    pageHeader(t('screen.brewDetail')),
    h('section', { class: 'card notice', 'data-testid': 'brew-not-found' },
      icon('alert'),
      h('h2', null, t('detail.notFound')),
      h('p', { class: 'notice__text' }, t('detail.notFoundText')),
      button({ label: t('detail.back'), variant: 'secondary', href: '#/brews', iconName: 'arrowLeft', testid: 'back-to-brews' })),
  ];
}

function build(id) {
  return (state, paint) => {
    const brew = B.getBrew(id);
    if (!brew) return notFound();
    const ctx = brewContext(brew);
    const lang = getLang();
    const espresso = brew.method === 'espresso';
    const tc = B.brewTimeClass(brew);
    const out = espresso ? brew.yieldG : brew.waterG;
    const date = new Date(brew.createdAt).toLocaleString(lang === 'de' ? 'de-DE' : 'en-GB', { dateStyle: 'medium', timeStyle: 'short' });
    const rec = brew.taste ? recFor(brew, ctx.grinder) : null;
    const markFav = favButton({ pressed: brew.favourite, onClick: () => { B.toggleFavourite(brew.id); paint(); } });

    return [
      h('div', { class: 'detail-top' },
        button({ label: t('detail.back'), variant: 'ghost', href: '#/brews', iconName: 'arrowLeft', testid: 'back-to-brews' })),
      pageHeader(t('screen.brewDetail'),
        h('button', {
          type: 'button', class: 'btn btn--secondary btn--icon fav-toggle fav-toggle--static' + (brew.favourite ? ' is-on' : ''), 'data-testid': 'fav-toggle',
          'aria-pressed': brew.favourite ? 'true' : 'false', 'aria-label': t(brew.favourite ? 'brew.fav.remove' : 'brew.fav.add'),
          onClick: () => { B.toggleFavourite(brew.id); paint(); },
        }, favStar(brew.favourite)),
        button({ label: t('action.delete'), variant: 'secondary', iconName: 'trash', testid: 'delete-brew', onClick: () => confirmDelete(brew) })),
      h('section', { class: 'card detail-hero' },
        brewAnchor(brew, ctx.hue),
        h('div', { class: 'detail-hero__body' },
          h('h2', { 'data-testid': 'detail-bean' }, ctx.bean?.name ?? '–'),
          h('p', { class: 'card__meta' }, [ctx.roaster?.name, ctx.bean?.origin].filter(Boolean).join(' · ')),
          h('p', { class: 'brew-card__summary', 'data-testid': 'detail-summary' }, B.brewSummary(brew)),
          h('div', { class: 'item-card__chips' },
            tc.cls ? timeClassChip(tc, 'detail-timeclass') : null,
            brew.taste ? tasteChip(brew.taste, 'detail-taste') : null)),
        h('div', { class: 'brew-bar', 'data-testid': 'detail-bar', 'data-status': tc.status || 'none' })),
      h('section', { class: 'card' },
        h('dl', { class: 'detail-list' },
          row(t('detail.date'), date, 'detail-date'),
          row(t('form.method'), t('method.' + brew.method), 'detail-method'),
          row(t('form.machine'), ctx.machine?.name, 'detail-machine'),
          row(t('form.grinder'), ctx.grinder?.name, 'detail-grinder'),
          row(t('form.setting'), settingText(brew, ctx.grinder), 'detail-setting'),
          row(t('form.bag'), ctx.bean ? [ctx.bean.name, ctx.roaster?.name].filter(Boolean).join(' · ') : null, 'detail-bag'),
          row(t('form.waterProfile'), ctx.water?.name ?? t('form.noWater'), 'detail-water'),
          row(t('form.dose'), `${formatNumber(brew.doseG, 1)} g`, 'detail-dose'),
          row(t(espresso ? 'form.yield' : 'form.waterG'), `${formatNumber(out, espresso ? 1 : 0)} g`, 'detail-out'),
          row(t('detail.ratio'), B.ratioText(brew.doseG, out), 'detail-ratio'),
          row(t('form.time'), espresso ? `${formatNumber(brew.timeS, Number.isInteger(brew.timeS) ? 0 : 1)} s` : `${mmss(brew.timeS)} (${fmtNum(brew.timeS)} s)`, 'detail-time'),
          row(t('form.temp'), brew.tempC != null ? `${fmtNum(brew.tempC)} °C` : null, 'detail-temp'),
          row(t('detail.purge'), brew.purgeG > 0 ? t('preview.purge', { g: formatNumber(brew.purgeG, 1) }) : t('detail.noPurge'), 'detail-purge'),
          row(t('form.taste'), brew.taste ? t('taste.' + brew.taste) : null, 'detail-taste-text'),
          row(t('form.notes'), brew.notes || null, 'detail-notes'))),
      recommendationPanel(rec, brew.favourite ? null : markFav),
    ];
  };
}

let cache = { id: null, render: null };

export function renderBrewDetail(route, params = {}) {
  // one self-repainting view per brew id
  if (cache.id !== params.id) cache = { id: params.id, render: makeView(build(params.id)) };
  return cache.render(route);
}
