// Inline SVG icons: viewBox only, currentColor, sized through CSS classes (.icon, .icon--sm, .icon--lg).
const PATHS = {
  today: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
  brews: '<path d="M5 9h11v5a5 5 0 0 1-5 5h-1a5 5 0 0 1-5-5z"/><path d="M16 11h2a2.5 2.5 0 0 1 0 5h-2M8 3v3M12 3v3"/>',
  beans: '<ellipse cx="12" cy="12" rx="6" ry="9"/><path d="M12 3c-3 3 3 6 0 9s3 6 0 9"/>',
  equipment: '<path d="M4 6a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v10H4z"/><path d="M4 20h16M9 10h6"/>',
  drop: '<path d="M12 3c4 5 6 8 6 11a6 6 0 0 1-12 0c0-3 2-6 6-11z"/>',
  water: '<path d="M12 3c4 5 6 8 6 11a6 6 0 0 1-12 0c0-3 2-6 6-11z"/>',
  care: '<path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8z"/><path d="M19 16l.7 1.8 1.8.7-1.8.7L19 21l-.7-1.8-1.8-.7 1.8-.7z"/>',
  settings: '<path d="M4 7h10M18 7h2M4 17h2M10 17h10"/><circle cx="16" cy="7" r="2"/><circle cx="8" cy="17" r="2"/>',
  more: '<circle cx="5" cy="12" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/>',
  plus: '<path d="M12 5v14M5 12h14"/>',
  info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>',
  check: '<path d="M5 12l5 5 9-10"/>',
  hourglass: '<path d="M7 3h10M7 21h10M8 3v3l4 6-4 6v3M16 3v3l-4 6 4 6v3"/>',
  clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  alert: '<path d="M12 3l10 18H2z"/><path d="M12 10v5M12 18h.01"/>',
  close: '<path d="M6 6l12 12M18 6L6 18"/>',
  minus: '<path d="M5 12h14"/>',
  chevron: '<path d="M6 9l6 6 6-6"/>',
  edit: '<path d="M4 20h4L19 9l-4-4L4 16z"/><path d="M13.5 6.5l4 4"/>',
  portafilter: '<path d="M3 8h13v2a6.5 6.5 0 0 1-13 0z"/><path d="M16 9h5.5M9.5 16.5v3.5M6 5h7"/>',
  v60: '<path d="M4 4h16l-6 11h-4z"/><path d="M7 8h10M9 15v4h6v-4M8 21h8"/>',
  burr: '<path d="M6 3h12l-2 7H8z"/><path d="M8 10h8v6H8zM6 20h12M12 16v4"/>',
  crank: '<path d="M7 10h10l-1 10H8z"/><path d="M12 10V4h6"/><circle cx="18" cy="4" r="1.5"/>',
  bag: '<path d="M7 3h10l1 4v13a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1V7z"/><path d="M6 7h12"/><ellipse cx="12" cy="14.5" rx="3" ry="4"/><path d="M12 10.5c-1.5 1.5 1.5 2.5 0 4s1.5 2.5 0 4"/>',
  beanLight: '<ellipse cx="12" cy="12" rx="6" ry="9"/><path d="M12 3c-3 3 3 6 0 9s3 6 0 9"/>',
  beanMedium: '<ellipse cx="12" cy="12" rx="6" ry="9"/><path d="M12 3c-3 3 3 6 0 9s3 6 0 9"/><path fill="currentColor" d="M12 3A6 9 0 0 0 12 21C15 18 9 15 12 12C15 9 9 6 12 3z"/>',
  beanDark: '<ellipse cx="12" cy="12" rx="6" ry="9" fill="currentColor"/><path style="stroke:var(--on-accent)" d="M12 3c-3 3 3 6 0 9s3 6 0 9"/>',
  cup: '<path d="M4 10h13v4a6 6 0 0 1-6 6h-1a6 6 0 0 1-6-6z"/><path d="M17 12h1.5a2.5 2.5 0 0 1 0 5H17M3 21h16"/><ellipse cx="10.5" cy="10" rx="6.5" ry="1.6"/>',
  cone: '<path d="M4 4h16l-6 11h-4z"/><path d="M6.5 8h11M9 15v3M15 15v3M7 21h10M9 18h6"/>',
  star: '<path d="M12 3l2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9z"/>',
  arrowLeft: '<path d="M19 12H5M11 6l-6 6 6 6"/>',
  trash: '<path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13M10 11v5M14 11v5"/>',
  play: '<path d="M7 4l13 8-13 8z"/>',
  stop: '<rect x="6" y="6" width="12" height="12" rx="1"/>',
  brush: '<path d="M19 3l-8 8"/><path d="M11 11l-3.5-.5c-2 1-3 3-3.5 5.5 3 .5 6 0 7-2z"/><path d="M17 14l.7 1.8 1.8.7-1.8.7-.7 1.8-.7-1.8-1.8-.7 1.8-.7z"/>',
  logo: '<path d="M4 10h13v4a6 6 0 0 1-6 6h-1a6 6 0 0 1-6-6z"/><path d="M17 12h1.5a2.5 2.5 0 0 1 0 5H17M8 3c-1 1.5 1 2.5 0 4M12 3c-1 1.5 1 2.5 0 4"/>',
};

export function icon(name, cls = '') {
  const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('viewBox', '0 0 24 24');
  svg.setAttribute('class', ('icon ' + cls).trim());
  svg.setAttribute('aria-hidden', 'true');
  svg.setAttribute('focusable', 'false');
  svg.innerHTML = PATHS[name] || '';
  return svg;
}
