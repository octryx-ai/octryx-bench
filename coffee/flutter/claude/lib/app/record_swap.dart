import '../core/data/base_record.dart';
import 'record_collection.dart';

/// Replacement of one collection's content that can be undone.
class RecordSwap<T extends BaseRecord> {
  /// Prepares replacing the content of [_collection] with [_next]; the
  /// current content is remembered for [undo].
  RecordSwap(this._collection, this._next) : _before = _collection.all;

  final RecordCollection<T> _collection;
  final List<T> _next;
  final List<T> _before;

  /// Writes the new content.
  Future<void> apply() => _collection.replaceAll(_next);

  /// Restores the previous content.
  Future<void> undo() => _collection.replaceAll(_before);
}
