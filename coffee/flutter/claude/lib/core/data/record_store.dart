import 'base_record.dart';

/// Persistence interface for one record type.
///
/// The production implementation is meant to be backed by SQLite (drift);
/// see [InMemoryRecordStore] for the pure-Dart implementation.
abstract class RecordStore<T extends BaseRecord> {
  /// Stores a new record built by [build] from a fresh UUIDv4 and timestamp
  /// (`createdAt == updatedAt`) and returns it.
  Future<T> create(T Function(String id, DateTime now) build);

  /// Returns the record with [id], including soft-deleted ones, or null.
  Future<T?> get(String id);

  /// Returns live records; soft-deleted ones only if [includeDeleted].
  Future<List<T>> list({bool includeDeleted = false});

  /// Replaces the record with the result of [change]; the store forces
  /// `updatedAt` to now (keeping `createdAt` and `deletedAt` of the result).
  ///
  /// Throws [StateError] if the id is unknown.
  Future<T> update(String id, T Function(T current, DateTime now) change);

  /// Soft-deletes: `deletedAt = updatedAt = now` (same instant).
  ///
  /// Throws [StateError] if the id is unknown. Returns the deleted record.
  Future<T> softDelete(String id);
}
