import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../files/file_transfer_platform.dart';
import 'base_record.dart';
import 'clock.dart';
import 'record_store.dart';
import 'system_clock.dart';

/// [RecordStore] keeping records in memory (insertion order); created with
/// [InMemoryRecordStore.device] it also persists every change on the device
/// under a key. The device copy is read on the first read access (the app's
/// `load()` at start); a write before any read replaces it.
class InMemoryRecordStore<T extends BaseRecord> implements RecordStore<T> {
  /// Creates a store using [clock] (default: device time).
  InMemoryRecordStore({this.clock = const SystemClock()})
    : _key = null,
      _fromJson = null;

  /// Creates a store that keeps its records on the device under [name]
  /// (browser `localStorage` on the web), read back with [fromJson], so they
  /// survive a reload (SPEC decision 2: local storage, offline first).
  InMemoryRecordStore.device(
    String name,
    T Function(Map<String, Object?> json) fromJson, {
    this.clock = const SystemClock(),
  }) : _key = 'kaffee_begleiter.$name',
       _fromJson = fromJson;

  /// Time source for timestamps.
  final Clock clock;
  final String? _key;
  final T Function(Map<String, Object?> json)? _fromJson;
  bool _synced = false;
  final Map<String, T> _records = {};
  static const Uuid _uuid = Uuid();

  void _read() {
    final key = _key;
    final fromJson = _fromJson;
    if (_synced || key == null || fromJson == null) return;
    _synced = true;
    final text = const PlatformKeyValueStorage().read(key);
    if (text == null) return;
    for (final item in jsonDecode(text) as List<Object?>) {
      final record = fromJson((item! as Map).cast<String, Object?>());
      _records.putIfAbsent(record.id, () => record);
    }
  }

  void _save() {
    final key = _key;
    if (key == null) return;
    _synced = true;
    final json = [for (final r in _records.values) r.toJson()];
    const PlatformKeyValueStorage().write(key, jsonEncode(json));
  }

  @override
  Future<T> create(T Function(String id, DateTime now) build) async {
    final record = build(_uuid.v4(), clock.now());
    _records[record.id] = record;
    _save();
    return record;
  }

  @override
  Future<T?> get(String id) async {
    _read();
    return _records[id];
  }

  @override
  Future<List<T>> list({bool includeDeleted = false}) async {
    _read();
    return [
      for (final r in _records.values)
        if (includeDeleted || !r.isDeleted) r,
    ];
  }

  @override
  Future<T> update(
    String id,
    T Function(T current, DateTime now) change,
  ) async {
    final current = _require(id);
    final now = clock.now();
    final next = change(current, now).copyWithBase(updatedAt: now) as T;
    _records[id] = next;
    _save();
    return next;
  }

  @override
  Future<T> softDelete(String id) async {
    final current = _require(id);
    final now = clock.now();
    final next = current.copyWithBase(updatedAt: now, deletedAt: now) as T;
    _records[id] = next;
    _save();
    return next;
  }

  @override
  Future<void> replaceAll(List<T> records) async {
    _records
      ..clear()
      ..addEntries([for (final r in records) MapEntry(r.id, r)]);
    _save();
  }

  T _require(String id) {
    _read();
    final record = _records[id];
    if (record == null) throw StateError('Unknown record id: $id');
    return record;
  }
}
