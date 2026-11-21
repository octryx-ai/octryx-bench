import 'package:flutter/foundation.dart';

import '../core/data/clock.dart';
import '../core/data/in_memory_record_store.dart';
import '../core/data/record_store.dart';
import '../core/data/system_clock.dart';
import '../core/rules/rule_set.dart';
import '../features/equipment/domain/finer_direction.dart';
import '../features/equipment/domain/grinder.dart';
import '../features/equipment/domain/machine.dart';
import '../features/settings/data/app_settings.dart';
import '../features/settings/domain/hardness_unit.dart';
import '../features/water/domain/water_checker.dart';
import '../features/water/domain/water_profile.dart';
import 'record_collection.dart';

/// In-memory application state: equipment, water profiles and settings.
///
/// All mutations notify listeners. Deleting is a soft delete: the record
/// leaves the list getters but stays resolvable through the `...ById`
/// lookups.
class AppData extends ChangeNotifier {
  /// Creates the state; stores default to in-memory ones using [clock]. The
  /// [checker] defaults to one without ranges (everything in range).
  AppData({
    RecordStore<Grinder>? grinderStore,
    RecordStore<Machine>? machineStore,
    RecordStore<WaterProfile>? waterProfileStore,
    Clock? clock,
    WaterChecker? checker,
  }) : checker = checker ?? WaterChecker(RuleSet(const [])),
       _grinders = RecordCollection(
         grinderStore ?? InMemoryRecordStore<Grinder>(clock: _c(clock)),
       ),
       _machines = RecordCollection(
         machineStore ?? InMemoryRecordStore<Machine>(clock: _c(clock)),
       ),
       _waters = RecordCollection(
         waterProfileStore ??
             InMemoryRecordStore<WaterProfile>(clock: _c(clock)),
       );

  static Clock _c(Clock? clock) => clock ?? const SystemClock();

  /// Water assessment rules.
  final WaterChecker checker;

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
    ]);
    notifyListeners();
  }

  /// Live grinders, oldest first.
  List<Grinder> get grinders => _grinders.live;

  /// Live machines, oldest first.
  List<Machine> get machines => _machines.live;

  /// Live water profiles, oldest first.
  List<WaterProfile> get waterProfiles => _waters.live;

  /// Display unit for water hardness.
  HardnessUnit get hardnessUnit => _settings.hardnessUnit;

  /// Grinder with [id] (also if soft-deleted), or null.
  Grinder? grinderById(String id) => _grinders.byId(id);

  /// Machine with [id] (also if soft-deleted), or null.
  Machine? machineById(String id) => _machines.byId(id);

  /// Water profile with [id] (also if soft-deleted), or null.
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
    _settings = _settings.copyWith(hardnessUnit: unit);
    notifyListeners();
  }

  Future<R> _done<R>(Future<R> work) async {
    final result = await work;
    notifyListeners();
    return result;
  }
}
