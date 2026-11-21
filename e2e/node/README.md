# booklist

Lists the books of `data/books.json`, page by page.

```
node src/cli.js --page 1 --size 2
1. Dune (1965)
2. Emma (1815)
```

Rules: pages are numbered from 1; page 1 shows the first `size` books in file order; a page past the end is empty.

Tests: `node --test test/` (unit tests and `test/cli.test.js`, which runs the CLI end to end). No UI, no dependencies.
