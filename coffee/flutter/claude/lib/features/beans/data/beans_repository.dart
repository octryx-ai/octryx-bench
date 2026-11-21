import '../../../app/record_collection.dart';
import '../../../core/data/clock.dart';
import '../../../core/data/in_memory_record_store.dart';
import '../../../core/data/record_store.dart';
import '../domain/bean.dart';
import '../domain/bean_kind.dart';
import '../domain/pack.dart';
import '../domain/rest_calculator.dart';
import '../domain/roast_level.dart';

/// Beans and packs with soft delete; notification is up to the owner.
class BeansRepository {
  /// Creates a repository; stores default to in-memory ones using [clock].
  BeansRepository({
    required Clock clock,
    RecordStore<Bean>? beanStore,
    RecordStore<Pack>? packStore,
  }) : _clock = clock,
       _beans = RecordCollection(
         beanStore ?? InMemoryRecordStore<Bean>(clock: clock),
       ),
       _packs = RecordCollection(
         packStore ?? InMemoryRecordStore<Pack>(clock: clock),
       );

  final Clock _clock;
  final RecordCollection<Bean> _beans;
  final RecordCollection<Pack> _packs;

  /// Reloads both caches from the stores.
  Future<void> load() => Future.wait([_beans.refresh(), _packs.refresh()]);

  /// Live beans.
  List<Bean> get beans => _beans.live;

  /// Live packs.
  List<Pack> get packs => _packs.live;

  /// Live packs of bean [beanId].
  List<Pack> packsOf(String beanId) => [
    for (final p in _packs.live)
      if (p.beanId == beanId) p,
  ];

  /// Bean with [id] (also if soft-deleted), or null.
  Bean? beanById(String id) => _beans.byId(id);

  /// Pack with [id] (also if soft-deleted), or null.
  Pack? packById(String id) => _packs.byId(id);

  /// Creates a bean.
  Future<Bean> addBean({
    required String name,
    required String roaster,
    required RoastLevel roastLevel,
    required BeanKind kind,
    double? minStockG,
    int leadTimeDays = 3,
  }) => _beans.create(
    (id, now) => Bean(
      id: id,
      createdAt: now,
      updatedAt: now,
      name: name,
      roaster: roaster,
      roastLevel: roastLevel,
      kind: kind,
      minStockG: minStockG,
      leadTimeDays: leadTimeDays,
    ),
  );

  /// Saves [bean].
  Future<Bean> updateBean(Bean bean) => _beans.update(bean);

  /// Soft-deletes bean [id] and its live packs.
  Future<void> deleteBean(String id) async {
    for (final p in packsOf(id)) {
      await _packs.store.softDelete(p.id);
    }
    await _packs.refresh();
    await _beans.delete(id);
  }

  /// Creates a full pack; the roast date is reduced to its calendar day.
  Future<Pack> addPack({
    required String beanId,
    required DateTime roastDate,
    required double sizeG,
  }) => _packs.create(
    (id, now) => Pack(
      id: id,
      createdAt: now,
      updatedAt: now,
      beanId: beanId,
      roastDate: RestCalculator.dateOnly(roastDate),
      sizeG: sizeG,
      remainingG: sizeG,
    ),
  );

  /// Saves [pack].
  Future<Pack> updatePack(Pack pack) => _packs.update(pack);

  /// Soft-deletes pack [id].
  Future<void> deletePack(String id) => _packs.delete(id);

  /// Marks pack [id] opened now (UTC) unless already opened.
  Future<Pack> openPack(String id) async {
    final p = _packs.byId(id);
    if (p == null) throw ArgumentError.value(id, 'id', 'Unknown pack');
    if (p.openedAt != null) return p;
    return _packs.update(p.copyWith(openedAt: _clock.now().toUtc()));
  }
}
