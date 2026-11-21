// Paging over the book list. Pages are numbered from 1.

export function paginate(items, page, size) {
  if (!Number.isInteger(page) || page < 1) throw new RangeError('page must be an integer >= 1');
  if (!Number.isInteger(size) || size < 1) throw new RangeError('size must be an integer >= 1');
  const start = page * size;
  return items.slice(start, start + size);
}

export function formatBook(book, position) {
  return `${position}. ${book.title} (${book.year})`;
}
