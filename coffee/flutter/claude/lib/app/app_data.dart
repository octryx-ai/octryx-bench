import 'package:flutter/foundation.dart';

import '../core/data/clock.dart';
import '../core/data/in_memory_record_store.dart';
import '../core/data/record_store.dart';
import '../core/data/system_clock.dart';
import '../core/rules/rule_set.dart';
import '../features/beans/data/beans_repository.dart';
import '../features/beans/domain/bean.dart';
import '../features/beans/domain/bean_kind.dart';
import '../features/beans/domain/bean_summaries.dart';
import '../features/beans/domain/bean_summary.dart';
import '../features/beans/domain/pack.dart';
import '../features/beans/domain/rest_calculator.dart';
import '../features/beans/domain/roast_level.dart';
import '../features/brews/data/brews_repository.dart';
import '../features/brews/domain/brew.dart';
import '../features/brews/domain/espresso_advisor.dart';
import '../features/equipment/domain/finer_direction.dart';
import '../features/equipment/domain/grinder.dart';
import '../features/equipment/domain/machine.dart';
import '../features/settings/data/app_settings.dart';
import '../features/settings/domain/hardness_unit.dart';
import '../features/water/domain/water_checker.dart';
import '../features/water/domain/water_profile.dart';
import 'app_data_brews.dart';
import 'record_collection.dart';

/// In-memory application state: equipment, water profiles and settings.
///
/// All mutations notify listeners. Deleting is a soft delete: the record
/// leaves the list getters but stays resolvable through the `...ById`
/// lookups.
class AppData extends ChangeNotifier with AppDataBrews {
  /// Creates the state; stores default to in-memory ones using [clock]. The
  /// [checker] defaults to one without ranges (everything in range).
  AppData({
    RecordStore<Grinder>? grinderStore,
    RecordStore<Machine>? machineStore,
    RecordStore<WaterProfile>? waterProfileStore,
    Clock? clock,
    WaterChecker? checker,
    RestCalculator? rest,
    RuleSet? brewRules,
    RuleSet? careRules,
    RecordStore<Brew>? brewStore,
  }) : checker = checker ?? WaterChecker(RuleSet(const [])),
       rest = rest ?? RestCalculator.defaults(),
       _clock = _c(clock),
       advisor = EspressoAdvisor(brewRules ?? RuleSet(const [])),
       _beansRepo = BeansRepository(clock: _c(clock)),
       _grinders = RecordCollection(
         grinderStore ?? InMemoryRecordStore<Grinder>(clock: _c(clock)),
       ),
       _machines = RecordCollection(
         machineStore ?? InMemoryRecordStore<Machine>(clock: _c(clock)),
       ),
       _waters = RecordCollection(
         waterProfileStore ??
             InMemoryRecordStore<WaterProfile>(clock: _c(clock)),
       ) {
    brewsRepository = BrewsRepository(
      clock: _clock,
      packOf: _beansRepo.packById,
      store: brewStore,
      idleHours:
          careRules?.maybeEntry('grinder.idleHours')?.value as num? ?? 24,
    );
  }

  static Clock _c(Clock? clock) => clock ?? const SystemClock();

  @override
  final WaterChecker checker;
  @override
  final RestCalculator rest;
  @override
  final EspressoAdvisor advisor;

  @override
  late final BrewsRepository brewsRepository;

  final Clock _clock;
  final BeansRepository _beansRepo;
  final RecordCollection<Grinder> _grinders;
  final RecordCollection<Machine> _machines;
  final RecordCollection<WaterProfile> _waters;
  AppSettings _settings = const AppSettings();

  /// Loads records of injected stores into the synchronous caches.
  Future<void> load() async {
    await Future.wait([
      _grinders.refresh(),
      _machines.refresh(),
      _waters.refresh(),
      _beansRepo.load(),
      brewsRepository.load(),
    ]);
    notifyListeners();
  }

  /// Live grinders, oldest first.
  List<Grinder> get grinders => _grinders.live;

  /// Live machines, oldest first.
  List<Machine> get machines => _machines.live;

  /// Live water profiles, oldest first.
  List<WaterProfile> get waterProfiles => _waters.live;

  /// Live beans.
  List<Bean> get beans => _beansRepo.beans;

  /// Live packs.
  List<Pack> get packs => _beansRepo.packs;

  /// Live packs of bean [beanId].
  List<Pack> packsOf(String beanId) => _beansRepo.packsOf(beanId);

  /// Bean with [id] (also if soft-deleted), or null.
  @override
  Bean? beanById(String id) => _beansRepo.beanById(id);

  /// Pack with [id] (also if soft-deleted), or null.
  @override
  Pack? packById(String id) => _beansRepo.packById(id);

  /// Today's local calendar date as a date-only (UTC midnight) value.
  @override
  DateTime get today => RestCalculator.dateOnly(_clock.now().toLocal());

  /// Beans with readiness, earliest ready date first (SPEC R3).
  List<BeanSummary> get beanSummaries =>
      BeanSummaries.build(beans: beans, packs: packs, calc: rest, today: today);

  /// Display unit for water hardness.
  HardnessUnit get hardnessUnit => _settings.hardnessUnit;

  /// Grinder with [id] (also if soft-deleted), or null.
  @override
  Grinder? grinderById(String id) => _grinders.byId(id);

  /// Machine with [id] (also if soft-deleted), or null.
  @override
  Machine? machineById(String id) => _machines.byId(id);

  /// Water profile with [id] (also if soft-deleted), or null.
  @override
  WaterProfile? waterProfileById(String id) => _waters.byId(id);

  /// Creates a grinder.
  Future<Grinder> addGrinder({
    required String name,
    required double scaleMin,
    required double scaleMax,
    required double scaleStep,
    required FinerDirection finerDirection,
    required double deadSpaceG,
  }) => _done(
    _grinders.create(
      (id, now) => Grinder(
        id: id,
        createdAt: now,
        updatedAt: now,
        name: name,
        scaleMin: scaleMin,
        scaleMax: scaleMax,
        scaleStep: scaleStep,
        finerDirection: finerDirection,
        deadSpaceG: deadSpaceG,
      ),
    ),
  );

  /// Saves changes to [grinder].
  Future<Grinder> updateGrinder(Grinder grinder) =>
      _done(_grinders.update(grinder));

  /// Soft-deletes the grinder [id].
  Future<void> deleteGrinder(String id) => _done(_grinders.delete(id));

  /// Creates a machine.
  Future<Machine> addMachine({
    required String name,
    required double brewTempC,
    required double preinfusionS,
    required String pressureProfile,
    String? defaultWaterProfileId,
  }) => _done(
    _machines.create(
      (id, now) => Machine(
        id: id,
        createdAt: now,
        updatedAt: now,
        name: name,
        brewTempC: brewTempC,
        preinfusionS: preinfusionS,
        pressureProfile: pressureProfile,
        defaultWaterProfileId: defaultWaterProfileId,
      ),
    ),
  );

  /// Saves changes to [machine].
  Future<Machine> updateMachine(Machine machine) =>
      _done(_machines.update(machine));

  /// Soft-deletes the machine [id].
  Future<void> deleteMachine(String id) => _done(_machines.delete(id));

  /// Creates a water profile; hardness is stored in ppm.
  Future<WaterProfile> addWaterProfile({
    required String name,
    required double hardnessPpm,
    double? alkalinityPpm,
    double? tdsPpm,
    double? ph,
    double? sodiumMgL,
    double? chlorineMgL,
  }) => _done(
    _waters.create(
      (id, now) => WaterProfile(
        id: id,
        createdAt: now,
        updatedAt: now,
        name: name,
        hardnessPpm: hardnessPpm,
        alkalinityPpm: alkalinityPpm,
        tdsPpm: tdsPpm,
        ph: ph,
        sodiumMgL: sodiumMgL,
        chlorineMgL: chlorineMgL,
      ),
    ),
  );

  /// Saves changes to [profile].
  Future<WaterProfile> updateWaterProfile(WaterProfile profile) =>
      _done(_waters.update(profile));

  /// Soft-deletes the water profile [id]; machines keep their reference.
  Future<void> deleteWaterProfile(String id) => _done(_waters.delete(id));

  /// Creates a bean.
  Future<Bean> addBean({
    required String name,
    required String roaster,
    required RoastLevel roastLevel,
    required BeanKind kind,
    double? minStockG,
    int leadTimeDays = 3,
  }) => _done(
    _beansRepo.addBean(
      name: name,
      roaster: roaster,
      roastLevel: roastLevel,
      kind: kind,
      minStockG: minStockG,
      leadTimeDays: leadTimeDays,
    ),
  );

  /// Saves changes to [bean].
  Future<Bean> updateBean(Bean bean) => _done(_beansRepo.updateBean(bean));

  /// Soft-deletes bean [id] together with its packs.
  Future<void> deleteBean(String id) => _done(_beansRepo.deleteBean(id));

  /// Creates a full pack of bean [beanId].
  Future<Pack> addPack({
    required String beanId,
    required DateTime roastDate,
    required double sizeG,
  }) => _done(
    _beansRepo.addPack(beanId: beanId, roastDate: roastDate, sizeG: sizeG),
  );

  /// Saves changes to [pack].
  @override
  Future<Pack> updatePack(Pack pack) => _done(_beansRepo.updatePack(pack));

  /// Soft-deletes the pack [id].
  Future<void> deletePack(String id) => _done(_beansRepo.deletePack(id));

  /// Marks pack [id] as opened now (no change if already opened).
  Future<Pack> openPack(String id) => _done(_beansRepo.openPack(id));

  /// Changes the hardness display unit (stored values stay in ppm).
  Future<void> setHardnessUnit(HardnessUnit unit) async {
    _settings = _settings.copyWith(hardnessUnit: unit);
    notifyListeners();
  }

  Future<R> _done<R>(Future<R> work) async {
    final result = await work;
    notifyListeners();
    return result;
  }
}
