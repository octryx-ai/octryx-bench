import 'package:uuid/uuid.dart';

import 'base_record.dart';
import 'clock.dart';
import 'record_store.dart';
import 'system_clock.dart';

/// Pure-Dart [RecordStore] keeping records in memory (insertion order).
class InMemoryRecordStore<T extends BaseRecord> implements RecordStore<T> {
  /// Creates a store using [clock] (default: device time).
  InMemoryRecordStore({this.clock = const SystemClock()});

  /// Time source for timestamps.
  final Clock clock;
  final Map<String, T> _records = {};
  static const Uuid _uuid = Uuid();

  @override
  Future<T> create(T Function(String id, DateTime now) build) async {
    final record = build(_uuid.v4(), clock.now());
    _records[record.id] = record;
    return record;
  }

  @override
  Future<T?> get(String id) async => _records[id];

  @override
  Future<List<T>> list({bool includeDeleted = false}) async => [
    for (final r in _records.values)
      if (includeDeleted || !r.isDeleted) r,
  ];

  @override
  Future<T> update(
    String id,
    T Function(T current, DateTime now) change,
  ) async {
    final current = _require(id);
    final now = clock.now();
    final next = change(current, now).copyWithBase(updatedAt: now) as T;
    _records[id] = next;
    return next;
  }

  @override
  Future<T> softDelete(String id) async {
    final current = _require(id);
    final now = clock.now();
    final next = current.copyWithBase(updatedAt: now, deletedAt: now) as T;
    _records[id] = next;
    return next;
  }

  @override
  Future<void> replaceAll(List<T> records) async {
    _records
      ..clear()
      ..addEntries([for (final r in records) MapEntry(r.id, r)]);
  }

  T _require(String id) {
    final record = _records[id];
    if (record == null) throw StateError('Unknown record id: $id');
    return record;
  }
}
