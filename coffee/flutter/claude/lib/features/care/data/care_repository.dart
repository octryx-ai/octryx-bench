import '../../../app/record_collection.dart';
import '../../../core/data/clock.dart';
import '../../../core/data/in_memory_record_store.dart';
import '../../../core/data/record_store.dart';
import '../domain/care_event.dart';
import '../domain/care_kind.dart';

/// Care events with soft delete; notification is up to the owner.
class CareRepository {
  /// Creates a repository; the store defaults to a device one.
  CareRepository({required Clock clock, RecordStore<CareEvent>? store})
    : _clock = clock,
      _events = RecordCollection(
        store ??
            InMemoryRecordStore.device(
              'careEvents',
              CareEvent.fromJson,
              clock: clock,
            ),
      );

  final Clock _clock;
  final RecordCollection<CareEvent> _events;

  /// Collection of all events (including soft-deleted ones).
  RecordCollection<CareEvent> get collection => _events;

  /// Reloads the cache from the store.
  Future<void> load() => _events.refresh();

  /// Live events, oldest first.
  List<CareEvent> get events => _events.live;

  /// Event with [id] (also if soft-deleted), or null.
  CareEvent? byId(String id) => _events.byId(id);

  /// Records that [kind] was done now on a machine or grinder.
  Future<CareEvent> add({
    required CareKind kind,
    String? machineId,
    String? grinderId,
  }) => _events.create(
    (id, now) => CareEvent(
      id: id,
      createdAt: now,
      updatedAt: now,
      machineId: machineId,
      grinderId: grinderId,
      kind: kind,
      doneAt: _clock.now().toUtc(),
    ),
  );

  /// Soft-deletes event [id].
  Future<void> delete(String id) => _events.delete(id);
}
