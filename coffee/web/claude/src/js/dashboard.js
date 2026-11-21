import { getState } from './store.js';
import { dueTasks } from './care.js';
import { orderNeeds, restingBags } from './inventory.js';
import { listBrews } from './brews.js';

// "Heute": due cleaning tasks (overdue only), beans to order, resting bags, newest 3 brews.
export function todayData(now = new Date()) {
  const state = getState();
  const data = {
    dueTasks: dueTasks(state, now),
    orderNeeds: orderNeeds(state, now),
    restingBags: restingBags(now, state),
    lastBrews: listBrews().slice(0, 3),
  };
  data.empty = !data.dueTasks.length && !data.orderNeeds.length && !data.restingBags.length && !data.lastBrews.length;
  return data;
}
