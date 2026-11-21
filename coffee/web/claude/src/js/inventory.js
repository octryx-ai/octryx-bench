import { getState } from './store.js';
import { restStatus } from './rules/index.js';
import { REST_DAYS } from './rules/data.js';

const DAY_MS = 86400000;
const WINDOW_DAYS = 14;
const MIN_BREW_DAYS = 3;
const iso = (d) => new Date(d).toISOString().slice(0, 10);

// 4.8: inventory entry per non-archived bean (A-Z) with at least one bag.
export function inventory(state = getState(), now = new Date(), method = 'espresso') {
  const today = iso(now);
  const since = new Date(now).getTime() - WINDOW_DAYS * DAY_MS;
  const out = [];
  for (const bean of state.beans.filter((b) => !b.archived).sort((a, b) => a.name.localeCompare(b.name))) {
    const bags = state.bags.filter((b) => b.beanId === bean.id);
    if (!bags.length) continue;
    const roaster = state.roasters.find((r) => r.id === bean.roasterId) ?? null;
    const bagIds = new Set(bags.map((b) => b.id));
    const brews = state.brews.filter((b) => bagIds.has(b.bagId)).sort((a, b) => b.createdAt.localeCompare(a.createdAt));
    const rested = bags.map((bag) => ({ bag, rest: restStatus({ roastDate: bag.roastDate, roastLevel: bean.roastLevel, method }, today) }));
    const stockG = bags.reduce((s, b) => s + b.remainingG, 0);
    const usableStockG = rested.filter((x) => x.rest.status !== 'resting').reduce((s, x) => s + x.bag.remainingG, 0);
    const hasResting = rested.some((x) => x.rest.status === 'resting' && x.bag.remainingG > 0);
    const doseG = brews[0]?.doseG ?? null;

    const recent = brews.filter((b) => new Date(b.createdAt).getTime() >= since);
    const days = new Set(recent.map((b) => iso(b.createdAt)));
    let dailyUseG = 0;
    if (days.size >= MIN_BREW_DAYS) dailyUseG = recent.reduce((s, b) => s + b.doseG + (b.purgeG || 0), 0) / WINDOW_DAYS;
    else if (doseG) dailyUseG = state.settings.plannedShotsPerDay * doseG;

    const shotsLeft = doseG ? Math.floor(usableStockG / doseG) : null;
    const coverDays = dailyUseG > 0 ? Math.floor(usableStockG / dailyUseG) : null;
    const minRestDays = REST_DAYS[bean.roastLevel][method];
    const reorderPointG = dailyUseG * ((roaster?.leadTimeDays ?? 0) + minRestDays);
    const newest = [...bags].sort((a, b) => b.roastDate.localeCompare(a.roastDate))[0];

    let reorder = { order: false };
    if (dailyUseG > 0 && usableStockG <= reorderPointG && !hasResting) {
      const n = Math.max(0, Math.ceil((state.settings.targetCoverDays * dailyUseG - stockG) / newest.weightG));
      if (n > 0) reorder = { order: true, bags: n };
    }
    out.push({ bean, roaster, stockG, usableStockG, doseG, dailyUseG, shotsLeft, coverDays, reorderPointG, hasResting, reorder });
  }
  return out;
}

export const orderNeeds = (state, now) => inventory(state, now).filter((x) => x.reorder.order);

// Bags with stock that are still resting, soonest ready first. readyOn is an ISO date.
export function restingBags(now = new Date(), state = getState(), method = 'espresso') {
  const today = iso(now);
  const out = [];
  for (const bag of state.bags) {
    const bean = state.beans.find((b) => b.id === bag.beanId);
    if (!bean || bean.archived || bag.remainingG <= 0) continue;
    const rest = restStatus({ roastDate: bag.roastDate, roastLevel: bean.roastLevel, method }, today);
    if (rest.status === 'resting') {
      out.push({ bag, bean, roaster: state.roasters.find((r) => r.id === bean.roasterId) ?? null, rest, readyOn: rest.readyOn, daysToGo: rest.daysToGo });
    }
  }
  return out.sort((a, b) => a.readyOn.localeCompare(b.readyOn));
}
