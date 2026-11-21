import '../../../app/record_collection.dart';
import '../../../core/data/clock.dart';
import '../../../core/data/in_memory_record_store.dart';
import '../../../core/data/record_store.dart';
import '../../beans/domain/pack.dart';
import '../../equipment/domain/grinder.dart';
import '../domain/brew.dart';
import '../domain/brew_method.dart';
import '../domain/purge_advice.dart';

/// Brews with soft delete; notification is up to the owner.
class BrewsRepository {
  /// Creates a repository; the store defaults to a device one.
  BrewsRepository({
    required Clock clock,
    required this._packOf,
    RecordStore<Brew>? store,
    this.idleHours = 24,
  }) : _clock = clock,
       _brews = RecordCollection(
         store ??
             InMemoryRecordStore.device('brews', Brew.fromJson, clock: clock),
       );

  /// Hours after which an idle grinder should be purged.
  final num idleHours;

  final Clock _clock;
  final Pack? Function(String) _packOf;
  final RecordCollection<Brew> _brews;
  List<Brew> _sorted = const [];

  /// Collection of all brews (including soft-deleted ones); call [load]
  /// after replacing its content to rebuild the sorted view.
  RecordCollection<Brew> get collection => _brews;

  /// Reloads the cache from the store.
  Future<void> load() async {
    await _brews.refresh();
    _resort();
  }

  void _resort() {
    _sorted = List.unmodifiable(
      _brews.live.toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt)),
    );
  }

  /// Live brews, newest first.
  List<Brew> get brews => _sorted;

  /// Brew with [id] (also if soft-deleted), or null.
  Brew? byId(String id) => _brews.byId(id);

  /// Creates a brew record (stock handling is up to the caller).
  Future<Brew> add(Brew Function(String id, DateTime now) build) async {
    final brew = await _brews.create(build);
    _resort();
    return brew;
  }

  /// Soft-deletes brew [id].
  Future<void> delete(String id) async {
    await _brews.delete(id);
    _resort();
  }

  /// Number of live espresso brews on [machineId], optionally started at or
  /// after [since].
  int shotsOfMachine(String machineId, {DateTime? since}) => _sorted
      .where(
        (b) =>
            b.method == BrewMethod.espresso &&
            b.machineId == machineId &&
            (since == null || !b.startedAt.isBefore(since)),
      )
      .length;

  /// Advice to purge [grinder] before brewing bean [beanId] at [now].
  PurgeAdvice? purgeAdvice({
    required Grinder grinder,
    required String beanId,
    required DateTime now,
  }) {
    if (grinder.deadSpaceG <= 0) return null;
    Brew? last;
    for (final b in _sorted) {
      if (b.grinderId == grinder.id) {
        last = b;
        break;
      }
    }
    if (last == null) return null;
    final lastBean = _packOf(last.packId)?.beanId;
    if (lastBean != beanId) {
      return PurgeAdvice(
        reason: PurgeReason.beanChange,
        purgeG: grinder.deadSpaceG,
      );
    }
    final idle = now.difference(last.startedAt);
    if (idle >= Duration(minutes: (idleHours * 60).round())) {
      return PurgeAdvice(reason: PurgeReason.idle, purgeG: grinder.deadSpaceG);
    }
    return null;
  }

  /// Current clock instant (UTC).
  DateTime get now => _clock.now().toUtc();
}
