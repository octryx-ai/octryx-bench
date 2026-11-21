#!/usr/bin/env node
// CLI: node src/cli.js [--page N] [--size N]
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { formatBook, paginate } from './books.js';

const BOOKS = fileURLToPath(new URL('../data/books.json', import.meta.url));

export function parseArgs(argv) {
  const options = { page: 1, size: 10 };
  for (let i = 0; i < argv.length; i += 2) {
    const name = argv[i].replace(/^--/, '');
    if (!(name in options)) throw new Error(`unknown option ${argv[i]}`);
    options[name] = Number(argv[i + 1]);
  }
  return options;
}

export function run(argv, books) {
  const { page, size } = parseArgs(argv);
  return paginate(books, page, size).map((book, i) => formatBook(book, (page - 1) * size + i + 1));
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    const books = JSON.parse(readFileSync(BOOKS, 'utf8'));
    for (const line of run(process.argv.slice(2), books)) console.log(line);
  } catch (error) {
    console.error(`error: ${error.message}`);
    process.exit(2);
  }
}
