import 'package:flutter/foundation.dart';

import '../core/data/base_record.dart';
import '../core/data/clock.dart';
import '../core/data/in_memory_record_store.dart';
import '../core/data/record_store.dart';
import '../core/data/system_clock.dart';
import '../core/rules/rule_set.dart';
import '../features/beans/data/beans_repository.dart';
import '../features/beans/domain/bean_summaries.dart';
import '../features/beans/domain/bean_summary.dart';
import '../features/beans/domain/rest_calculator.dart';
import '../features/brews/data/brews_repository.dart';
import '../features/brews/domain/brew.dart';
import '../features/care/data/care_repository.dart';
import '../features/care/domain/care_event.dart';
import '../features/equipment/domain/finer_direction.dart';
import '../features/equipment/domain/grinder.dart';
import '../features/equipment/domain/machine.dart';
import '../features/settings/data/app_settings.dart';
import '../features/settings/domain/hardness_unit.dart';
import '../features/transfer/data/export_service.dart';
import '../features/transfer/data/import_service.dart';
import '../features/transfer/domain/import_result.dart';
import '../features/water/domain/water_checker.dart';
import '../features/water/domain/water_profile.dart';
import 'app_data_beans.dart';
import 'app_data_brews.dart';
import 'app_data_care.dart';
import 'app_data_filter.dart';
import 'app_data_inventory.dart';
import 'app_data_today.dart';
import 'app_data_transfer.dart';
import 'record_collection.dart';

/// In-memory application state: equipment, water profiles and settings.
///
/// All mutations notify listeners. Deleting is a soft delete: the record
/// leaves the list getters but stays resolvable through the `...ById`
/// lookups.
class AppData extends ChangeNotifier
    with
        AppDataBeans,
        AppDataBrews,
        AppDataFilter,
        AppDataInventory,
        AppDataCare,
        AppDataToday,
        AppDataTransfer {
  /// Creates the state; stores default to device ones using [clock]. The
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
    RecordStore<CareEvent>? careStore,
  }) : checker = checker ?? WaterChecker(RuleSet(const [])),
       rest = rest ?? RestCalculator.defaults(),
       _clock = _c(clock),
       brewRules = brewRules ?? RuleSet(const []),
       careRules = careRules ?? RuleSet(const []),
       beansRepository = BeansRepository(clock: _c(clock)),
       _grinders = RecordCollection(
         grinderStore ?? _device('grinders', Grinder.fromJson, clock),
       ),
       _machines = RecordCollection(
         machineStore ?? _device('machines', Machine.fromJson, clock),
       ),
       _waters = RecordCollection(
         waterProfileStore ??
             _device('waterProfiles', WaterProfile.fromJson, clock),
       ) {
    brewsRepository = BrewsRepository(
      clock: _clock,
      packOf: beansRepository.packById,
      store: brewStore,
      idleHours:
          this.careRules.maybeEntry('grinder.idleHours')?.value as num? ?? 24,
    );
    careRepository = CareRepository(clock: _clock, store: careStore);
  }

  static Clock _c(Clock? clock) => clock ?? const SystemClock();

  static RecordStore<T> _device<T extends BaseRecord>(
    String name,
    T Function(Map<String, Object?>) fromJson,
    Clock? clock,
  ) => InMemoryRecordStore.device(name, fromJson, clock: _c(clock));

  @override
  final WaterChecker checker;
  @override
  final RestCalculator rest;
  @override
  final RuleSet brewRules;

  @override
  final RuleSet careRules;

  @override
  late final BrewsRepository brewsRepository;

  @override
  late final CareRepository careRepository;

  final Clock _clock;
  @override
  final BeansRepository beansRepository;
  final RecordCollection<Grinder> _grinders;
  final RecordCollection<Machine> _machines;
  final RecordCollection<WaterProfile> _waters;
  @override
  AppSettings settings = const AppSettings();

  /// Loads records of injected stores into the synchronous caches.
  Future<void> load() async {
    await Future.wait([
      _grinders.refresh(),
      _machines.refresh(),
      _waters.refresh(),
      beansRepository.load(),
      brewsRepository.load(),
      careRepository.load(),
    ]);
    notifyListeners();
  }

  /// Live grinders, oldest first.
  @override
  List<Grinder> get grinders => _grinders.live;

  /// Live machines, oldest first.
  @override
  List<Machine> get machines => _machines.live;

  /// Live water profiles, oldest first.
  @override
  List<WaterProfile> get waterProfiles => _waters.live;

  /// Today's local calendar date as a date-only (UTC midnight) value.
  @override
  DateTime get today => RestCalculator.dateOnly(_clock.now().toLocal());

  /// Beans with readiness, earliest ready date first (SPEC R3).
  List<BeanSummary> get beanSummaries =>
      BeanSummaries.build(beans: beans, packs: packs, calc: rest, today: today);

  @override
  RecordCollection<Grinder> get grinderCollection => _grinders;

  @override
  RecordCollection<Machine> get machineCollection => _machines;

  @override
  RecordCollection<WaterProfile> get waterCollection => _waters;

  /// JSON export of all data including soft-deleted records.
  String exportJson() => const ExportService().exportJson(this);

  /// File name for today's export: `coffee-export-YYYY-MM-DD.json`.
  String get exportFileName => ExportService.fileName(today);

  /// Merges an export file into the data (SPEC section 6); throws
  /// `ImportException` and changes nothing if the file is unusable.
  Future<ImportResult> importJson(String json) =>
      const ImportService().importJson(this, json);

  /// Display unit for water hardness.
  HardnessUnit get hardnessUnit => settings.hardnessUnit;

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

  /// Changes the hardness display unit (stored values stay in ppm).
  Future<void> setHardnessUnit(HardnessUnit unit) async {
    settings = settings.copyWith(hardnessUnit: unit);
    notifyListeners();
  }

  Future<R> _done<R>(Future<R> work) async {
    final result = await work;
    notifyListeners();
    return result;
  }
}
