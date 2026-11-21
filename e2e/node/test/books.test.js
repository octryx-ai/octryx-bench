import assert from 'node:assert/strict';
import { test } from 'node:test';
import { formatBook, paginate } from '../src/books.js';
import { parseArgs } from '../src/cli.js';

test('a page past the end is empty', () => {
  assert.deepEqual(paginate([1, 2, 3], 5, 2), []);
});

test('page and size must be positive integers', () => {
  assert.throws(() => paginate([1], 0, 2), RangeError);
  assert.throws(() => paginate([1], 1, 0), RangeError);
});

test('a book line shows position, title and year', () => {
  assert.equal(formatBook({ title: 'Emma', year: 1815 }, 2), '2. Emma (1815)');
});

test('options default to page 1 and size 10', () => {
  assert.deepEqual(parseArgs([]), { page: 1, size: 10 });
  assert.throws(() => parseArgs(['--colour', 'red']));
});
