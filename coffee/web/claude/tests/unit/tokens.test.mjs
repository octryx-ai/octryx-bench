import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync, statSync, existsSync } from 'node:fs';
import { join, relative, resolve } from 'node:path';

const root = resolve(import.meta.dirname, '../..');
const tokens = readFileSync(join(root, 'src/css/tokens.css'), 'utf8');

function walk(dir, out = []) {
  if (!existsSync(dir)) return out;
  for (const f of readdirSync(dir)) {
    const p = join(dir, f);
    statSync(p).isDirectory() ? walk(p, out) : out.push(p);
  }
  return out;
}

test('tokens.css has required exact values', () => {
  const t = tokens.toLowerCase();
  const has = (re, msg) => assert.match(t, re, msg);
  for (const [name, light, dark] of [
    ['bg', '#fbf5ec', '#1e1713'],
    ['text', '#2b1d14', '#f3e9dc'],
    ['accent', '#8a4b1f', '#e0a06a'],
  ]) {
    has(new RegExp(`--${name}\\s*:\\s*${light}\\b`), `--${name} light ${light}`);
    has(new RegExp(`--${name}\\s*:\\s*${dark}\\b`), `--${name} dark ${dark}`);
  }
  has(/#1a5fb4/, 'focus light');
  has(/#8ab4f8/, 'focus dark');
  has(/2px/, 'focus width 2px');
});

function stripComments(src, isCss) {
  let s = src.replace(/\/\*[\s\S]*?\*\//g, m => m.replace(/[^\n]/g, ' '));
  if (!isCss) s = s.replace(/(^|[^:'"`\\])\/\/.*$/gm, '$1');
  return s.replace(/<!--[\s\S]*?-->/g, m => m.replace(/[^\n]/g, ' '));
}

// remove @media conditions so px is allowed there
function stripMediaConds(s) {
  return s.replace(/@media[^{]*\{/g, m => m.replace(/[^\n]/g, ' ').slice(0, -1) + '{');
}

const files = [
  ...walk(join(root, 'src/css')).filter(f => !f.endsWith('tokens.css')),
  ...walk(join(root, 'src/js')),
  join(root, 'index.html'),
].filter(f => existsSync(f) && /\.(css|js|mjs|html)$/.test(f));

const patterns = [
  ['hex colour', /#(?:[0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3,4})\b(?![-\w])/g, true],
  ['rgb()/rgba()', /\brgba?\s*\(/g],
  ['hsl()/hsla()', /\bhsla?\s*\(/g],
  ['size literal', /(?<![\w#.-])-?\d*\.?\d+(?:px|rem|em)\b/g],
];

test('no colour or size literals outside tokens.css', () => {
  const problems = [];
  for (const f of files) {
    const isCss = f.endsWith('.css');
    const isHtml = f.endsWith('.html');
    let src = stripMediaConds(stripComments(readFileSync(f, 'utf8'), isCss));
    src.split('\n').forEach((line, i) => {
      for (const [name, re, hexOnly] of patterns) {
        re.lastIndex = 0;
        let m;
        while ((m = re.exec(line))) {
          // hex in JS/HTML: skip href anchors like "#/brews" (not matched) and ids like #main
          if (hexOnly && isHtml && /href\s*=\s*["']#/.test(line)) continue;
          problems.push(`${relative(root, f)}:${i + 1} ${name}: ${m[0]}`);
        }
      }
    });
  }
  assert.deepEqual(problems, [], '\n' + problems.join('\n'));
});
