import 'package:flutter/foundation.dart';

import '../features/beans/domain/bean.dart';
import '../features/beans/domain/pack.dart';
import '../features/beans/domain/rest_calculator.dart';
import '../features/brews/data/brews_repository.dart';
import '../features/brews/domain/brew.dart';
import '../features/brews/domain/brew_exception.dart';
import '../features/brews/domain/brew_method.dart';
import '../features/brews/domain/espresso_advisor.dart';
import '../features/brews/domain/purge_advice.dart';
import '../features/brews/domain/recommendation.dart';
import '../features/brews/domain/taste.dart';
import '../features/equipment/domain/grinder.dart';
import '../features/equipment/domain/machine.dart';
import '../features/water/domain/water_checker.dart';
import '../features/water/domain/water_profile.dart';

/// Brew part of `AppData`: logging brews, stock deduction, purge advice and
/// espresso recommendations.
mixin AppDataBrews on ChangeNotifier {
  /// Repository holding the brews.
  BrewsRepository get brewsRepository;

  /// The espresso dial-in advisor.
  EspressoAdvisor get advisor;

  /// Water assessment rules.
  WaterChecker get checker;

  /// Resting and stale date rules.
  RestCalculator get rest;

  /// Today's local date (date-only).
  DateTime get today;

  /// Grinder with [id] (also if soft-deleted), or null.
  Grinder? grinderById(String id);

  /// Machine with [id] (also if soft-deleted), or null.
  Machine? machineById(String id);

  /// Water profile with [id] (also if soft-deleted), or null.
  WaterProfile? waterProfileById(String id);

  /// Bean with [id] (also if soft-deleted), or null.
  Bean? beanById(String id);

  /// Pack with [id] (also if soft-deleted), or null.
  Pack? packById(String id);

  /// Saves changes to [pack].
  Future<Pack> updatePack(Pack pack);

  /// Live brews, newest first.
  List<Brew> get brews => brewsRepository.brews;

  /// Brew with [id] (also if soft-deleted), or null.
  Brew? brewById(String id) => brewsRepository.byId(id);

  /// Logs a brew and deducts dose plus purge from the pack.
  ///
  /// Throws [BrewException] and changes nothing if the grinder, machine
  /// (espresso) or pack is missing or the pack holds too little coffee.
  Future<Brew> addBrew({
    required BrewMethod method,
    String? machineId,
    required String grinderId,
    required String packId,
    required double grindSetting,
    required double doseG,
    double purgeG = 0,
    double? yieldG,
    int? shotTimeS,
    double? waterTempC,
    String? waterProfileId,
    Taste? taste,
    int? rating,
    String note = '',
    DateTime? startedAt,
  }) async {
    final grinder = grinderById(grinderId);
    if (grinder == null || grinder.isDeleted) {
      throw const BrewException(BrewFailure.noGrinder);
    }
    final machine = machineId == null ? null : machineById(machineId);
    if (method.isEspresso && (machine == null || machine.isDeleted)) {
      throw const BrewException(BrewFailure.noMachine);
    }
    final pack = packById(packId);
    if (pack == null || pack.isDeleted) {
      throw const BrewException(BrewFailure.packMissing);
    }
    final used = doseG + purgeG;
    if (used > pack.remainingG) {
      throw BrewException(
        BrewFailure.notEnoughBeans,
        remainingG: pack.remainingG,
      );
    }
    final brew = await brewsRepository.add(
      (id, now) => Brew(
        id: id,
        createdAt: now,
        updatedAt: now,
        method: method,
        machineId: machineId,
        grinderId: grinderId,
        packId: packId,
        grindSetting: grindSetting,
        doseG: doseG,
        purgeG: purgeG,
        yieldG: yieldG,
        shotTimeS: shotTimeS,
        waterTempC: waterTempC,
        waterProfileId: waterProfileId,
        taste: taste,
        rating: rating,
        note: note,
        startedAt: (startedAt ?? now).toUtc(),
      ),
    );
    await updatePack(pack.copyWith(remainingG: pack.remainingG - used));
    return brew;
  }

  /// Soft-deletes brew [id]; the stock is not refunded.
  Future<void> deleteBrew(String id) async {
    await brewsRepository.delete(id);
    notifyListeners();
  }

  /// Advice to purge grinder [grinderId] before brewing bean [beanId].
  PurgeAdvice? purgeAdvice({
    required String grinderId,
    required String beanId,
  }) {
    final grinder = grinderById(grinderId);
    if (grinder == null) return null;
    return brewsRepository.purgeAdvice(
      grinder: grinder,
      beanId: beanId,
      now: brewsRepository.now,
    );
  }

  /// Live espresso shots of [machineId], optionally started at or after
  /// [since].
  int shotsOfMachine(String machineId, {DateTime? since}) =>
      brewsRepository.shotsOfMachine(machineId, since: since);

  /// Next dial-in step for [brew]; its grinder, pack and bean must exist.
  Recommendation recommendFor(Brew brew) {
    final pack = packById(brew.packId)!;
    final waterId =
        brew.waterProfileId ??
        (brew.machineId == null
            ? null
            : machineById(brew.machineId!)?.defaultWaterProfileId);
    final water = waterId == null ? null : waterProfileById(waterId);
    return advisor.advise(
      brew: brew,
      grinder: grinderById(brew.grinderId)!,
      water: water,
      assessment: water == null ? null : checker.assess(water),
      readiness: rest.readiness(pack, beanById(pack.beanId)!, today),
    );
  }
}
