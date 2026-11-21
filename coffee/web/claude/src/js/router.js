// Hash router. Pure helpers (parsePath, matchRoute) plus a thin browser binding.
export const ROUTES = [
  { name: 'today', pattern: '/', testid: 'screen-today', titleKey: 'screen.today', nav: 'heute' },
  { name: 'brews', pattern: '/brews', testid: 'screen-brews', titleKey: 'screen.brews', nav: 'brews' },
  { name: 'brew-new', pattern: '/brews/new', testid: 'screen-brew-new', titleKey: 'screen.brewNew', nav: 'brews' },
  { name: 'brew-detail', pattern: '/brews/:id', testid: 'screen-brew-detail', titleKey: 'screen.brewDetail', nav: 'brews' },
  { name: 'guided', pattern: '/guided', testid: 'screen-guided', titleKey: 'screen.guided', nav: 'heute' },
  { name: 'beans', pattern: '/beans', testid: 'screen-beans', titleKey: 'screen.beans', nav: 'beans' },
  { name: 'equipment', pattern: '/equipment', testid: 'screen-equipment', titleKey: 'screen.equipment', nav: 'equipment' },
  { name: 'water', pattern: '/water', testid: 'screen-water', titleKey: 'screen.water', nav: 'water' },
  { name: 'care', pattern: '/care', testid: 'screen-care', titleKey: 'screen.care', nav: 'care' },
  { name: 'settings', pattern: '/settings', testid: 'screen-settings', titleKey: 'screen.settings', nav: 'settings' },
  { name: 'styleguide', pattern: '/styleguide', testid: 'screen-styleguide', titleKey: 'screen.styleguide', nav: 'settings' },
];

/** '#/brews/12?x=1' -> '/brews/12' ; '' or '#' -> '/' */
export function parsePath(hash) {
  let p = String(hash || '').replace(/^#/, '').split('?')[0];
  if (!p.startsWith('/')) p = '/' + p;
  if (p.length > 1) p = p.replace(/\/+$/, '');
  return p || '/';
}

/** Returns { route, params } or null for unknown paths. Static patterns win over :params. */
export function matchRoute(path) {
  const segs = path.split('/').filter(Boolean);
  let dynamic = null;
  for (const route of ROUTES) {
    const ps = route.pattern.split('/').filter(Boolean);
    if (ps.length !== segs.length) continue;
    const params = {};
    let ok = true;
    let isDynamic = false;
    ps.forEach((p, i) => {
      if (p.startsWith(':')) { params[p.slice(1)] = decodeURIComponent(segs[i]); isDynamic = true; }
      else if (p !== segs[i]) ok = false;
    });
    if (!ok) continue;
    if (!isDynamic) return { route, params };
    dynamic = dynamic || { route, params };
  }
  return dynamic;
}

/** Query parameter of the current hash ('#/brews/new?brew=12' -> queryParam('brew') = '12'). */
export function queryParam(name) {
  const q = String(window.location.hash).split('?')[1] || '';
  return new URLSearchParams(q).get(name);
}

export function currentMatch() {
  return matchRoute(parsePath(window.location.hash));
}

export function navigate(path) {
  window.location.hash = '#' + path;
}

/** Calls onChange({route, params}) now and on every hash change; unknown paths redirect to #/. */
export function startRouter(onChange) {
  const handle = () => {
    const m = currentMatch();
    if (!m) { window.location.replace('#/'); return; }
    onChange(m);
  };
  window.addEventListener('hashchange', handle);
  handle();
}
