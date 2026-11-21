# Kaffeejournal · COF-38

Run the setup commands in `.octryx/environment.json` from this directory, then `npm start`. Vite serves the app with history fallback. The declared unit, system and lint commands run from this same directory. All dependencies, downloads and caches stay here; no global installation is required.

`src/tokens.css` owns themes, visual dimensions, responsive breakpoints and drawing geometry. `style.css` composes those tokens. The living catalogue is `/styleguide` and appears in both navigation menus. `storage.js` exposes envelope-based IndexedDB commands, backup validation, previews and atomic replacement. `schema.js` defines required domain fields, including nullable fields, for later stories to extend.

See [ACCEPTANCE.md](ACCEPTANCE.md) section 7 for actual results and the explicitly incomplete named-browser matrix. Subsequent domain stories should extend the schema, fixtures, tests and acceptance report together. No runtime research or remote account service is needed for S1.
