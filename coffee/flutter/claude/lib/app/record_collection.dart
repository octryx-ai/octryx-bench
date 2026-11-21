import '../core/data/base_record.dart';
import '../core/data/record_store.dart';

/// In-memory view over a [RecordStore] for synchronous reads by the UI.
class RecordCollection<T extends BaseRecord> {
  /// Creates a collection backed by [store].
  RecordCollection(this.store);

  /// The backing store.
  final RecordStore<T> store;

  List<T> _live = const [];
  Map<String, T> _byId = const {};

  /// Live records sorted by `createdAt` ascending.
  List<T> get live => _live;

  /// Looks up [id], also resolving soft-deleted records.
  T? byId(String id) => _byId[id];

  /// Reloads the cache from the store.
  Future<void> refresh() async {
    final all = await store.list(includeDeleted: true);
    _byId = {for (final r in all) r.id: r};
    _live = List.unmodifiable(
      all.where((r) => !r.isDeleted).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
    );
  }

  /// Creates a record and refreshes.
  Future<T> create(T Function(String id, DateTime now) build) async {
    final record = await store.create(build);
    await refresh();
    return record;
  }

  /// Replaces record [next] (matched by id) and refreshes.
  Future<T> update(T next) async {
    final saved = await store.update(next.id, (_, _) => next);
    await refresh();
    return saved;
  }

  /// Soft-deletes [id] and refreshes.
  Future<void> delete(String id) async {
    await store.softDelete(id);
    await refresh();
  }
}
