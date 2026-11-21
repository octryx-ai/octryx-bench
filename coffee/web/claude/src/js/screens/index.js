import { h } from '../dom.js';
import { icon } from '../icons.js';
import { t } from '../i18n.js';
import { pageHeader } from '../ui.js';
import { renderSettings } from './settings.js';
import { renderStyleguide } from './styleguide.js';
import { renderEquipment } from './equipment.js';
import { renderBeans } from './beans.js';
import { renderBrews } from './brews.js';
import { renderBrewForm } from './brew-form.js';
import { renderCare } from './care.js';
import { renderWater } from './water.js';
import { renderToday } from './today.js';
import { renderGuided, resetGuided } from './guided.js';
import { renderBrewDetail } from './brew-detail.js';

export function comingSoon(route) {
  return h('div', { class: 'page', 'data-testid': route.testid },
    pageHeader(t(route.titleKey)),
    h('section', { class: 'card notice', 'data-testid': 'coming-soon' },
      icon('hourglass'),
      h('h2', null, t('comingSoon.title')),
      h('p', { class: 'notice__text' }, t('comingSoon.text'))));
}

export function renderScreen({ route, params }) {
  if (route.name !== 'guided') resetGuided();
  if (route.name === 'today') return renderToday(route);
  if (route.name === 'guided') return renderGuided(route);
  if (route.name === 'settings') return renderSettings(route);
  if (route.name === 'equipment') return renderEquipment(route);
  if (route.name === 'beans') return renderBeans(route);
  if (route.name === 'brews') return renderBrews(route);
  if (route.name === 'brew-new') return renderBrewForm(route);
  if (route.name === 'brew-detail') return renderBrewDetail(route, params);
  if (route.name === 'care') return renderCare(route);
  if (route.name === 'water') return renderWater(route);
  if (route.name === 'styleguide') return renderStyleguide(route);
  return comingSoon(route, params);
}
