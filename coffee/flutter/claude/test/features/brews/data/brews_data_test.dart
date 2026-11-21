import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/core/data/fixed_clock.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_exception.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_method.dart';
import 'package:kaffee_begleiter/features/brews/domain/purge_advice.dart';
import 'package:kaffee_begleiter/features/brews/domain/recommendation.dart';
import 'package:kaffee_begleiter/features/brews/domain/taste.dart';
import 'package:kaffee_begleiter/features/equipment/domain/finer_direction.dart';

import '../../../core/test_app_data.dart';

void main() {
  late FixedClock clock;
  late AppData data;
  late String grinderId;
  late String machineId;
  late String packId;
  late String beanId;

  setUp(() async {
    clock = FixedClock(DateTime.utc(2026, 11, 16, 8));
    data = await loadTestAppData(clock: clock);
    grinderId = (await data.addGrinder(
      name: 'Niche',
      scaleMin: 1,
      scaleMax: 30,
      scaleStep: 0.5,
      finerDirection: FinerDirection.down,
      deadSpaceG: 2.5,
    )).id;
    machineId = (await data.addMachine(
      name: 'Gaggia',
      brewTempC: 93,
      preinfusionS: 5,
      pressureProfile: 'flat 9 bar',
    )).id;
    beanId = (await data.addBean(
      name: 'Blend',
      roaster: 'Roest',
      roastLevel: RoastLevel.medium,
      kind: BeanKind.espressoBlend,
    )).id;
    packId = (await data.addPack(
      beanId: beanId,
      roastDate: DateTime.utc(2026, 10, 1),
      sizeG: 250,
    )).id;
  });

  Future<Brew> espresso({
    double dose = 17,
    double purge = 0,
    DateTime? at,
    String? machine,
    String? pack,
    String? grinder,
  }) => data.addBrew(
    method: BrewMethod.espresso,
    machineId: machine ?? machineId,
    grinderId: grinder ?? grinderId,
    packId: pack ?? packId,
    grindSetting: 12,
    doseG: dose,
    purgeG: purge,
    yieldG: 36,
    shotTimeS: 27,
    taste: Taste.sour,
    startedAt: at,
  );

  Future<BrewFailure> failure(Future<Brew> f) async {
    try {
      await f;
    } on BrewException catch (e) {
      return e.failure;
    }
    fail('expected BrewException');
  }

  test('deducts dose plus purge: 17 + 2.5 from 250 leaves 230.5', () async {
    final b = await espresso(purge: 2.5);
    expect(data.packById(packId)!.remainingG, 230.5);
    expect(data.brewById(b.id)!.purgeG, 2.5);
    expect(data.brews, hasLength(1));
  });

  test('insufficient stock throws with remainingG and keeps stock', () async {
    await espresso(dose: 20);
    await data.updatePack(data.packById(packId)!.copyWith(remainingG: 18));
    try {
      await espresso(dose: 17, purge: 2.5);
      fail('expected BrewException');
    } on BrewException catch (e) {
      expect(e.failure, BrewFailure.notEnoughBeans);
      expect(e.remainingG, 18);
    }
    expect(data.packById(packId)!.remainingG, 18);
    expect(data.brews, hasLength(1));
    await espresso(dose: 18);
    expect(data.packById(packId)!.remainingG, 0);
  });

  test('missing grinder, machine and pack', () async {
    expect(await failure(espresso(grinder: 'nope')), BrewFailure.noGrinder);
    await data.deleteGrinder(grinderId);
    expect(await failure(espresso()), BrewFailure.noGrinder);
    final g = (await data.addGrinder(
      name: 'G2',
      scaleMin: 1,
      scaleMax: 30,
      scaleStep: 0.5,
      finerDirection: FinerDirection.up,
      deadSpaceG: 0,
    )).id;
    expect(
      await failure(espresso(grinder: g, machine: 'nope')),
      BrewFailure.noMachine,
    );
    expect(
      await failure(espresso(grinder: g, pack: 'x')),
      BrewFailure.packMissing,
    );
    final v60 = await data.addBrew(
      method: BrewMethod.v60,
      grinderId: g,
      packId: packId,
      grindSetting: 14,
      doseG: 15,
    );
    expect(v60.machineId, isNull);
    expect(data.packById(packId)!.remainingG, 235);
  });

  test('brews sorted by startedAt descending; shots per machine', () async {
    final m2 = (await data.addMachine(
      name: 'Other',
      brewTempC: 93,
      preinfusionS: 0,
      pressureProfile: '',
    )).id;
    final a = await espresso(at: DateTime.utc(2026, 11, 10));
    final b = await espresso(at: DateTime.utc(2026, 11, 14));
    final c = await espresso(at: DateTime.utc(2026, 11, 12), machine: m2);
    expect(data.brews.map((x) => x.id), [b.id, c.id, a.id]);
    expect(data.shotsOfMachine(machineId), 2);
    expect(data.shotsOfMachine(m2), 1);
    expect(
      data.shotsOfMachine(machineId, since: DateTime.utc(2026, 11, 11)),
      1,
    );
    expect(data.shotsOfMachine('none'), 0);
  });

  test('deleteBrew is soft and does not refund', () async {
    final b = await espresso();
    await data.deleteBrew(b.id);
    expect(data.brews, isEmpty);
    expect(data.brewById(b.id)!.isDeleted, isTrue);
    expect(data.packById(packId)!.remainingG, 233);
    expect(data.shotsOfMachine(machineId), 0);
  });

  group('purgeAdvice', () {
    test('first brew has none', () {
      expect(data.purgeAdvice(grinderId: grinderId, beanId: beanId), isNull);
    });

    test('bean change, idle and fresh same bean', () async {
      await espresso(at: DateTime.utc(2026, 11, 16, 7));
      clock.set(DateTime.utc(2026, 11, 16, 9));
      expect(data.purgeAdvice(grinderId: grinderId, beanId: beanId), isNull);
      final other = await data.addBean(
        name: 'Other',
        roaster: 'R',
        roastLevel: RoastLevel.dark,
        kind: BeanKind.espressoBlend,
      );
      final change = data.purgeAdvice(grinderId: grinderId, beanId: other.id)!;
      expect(change.reason, PurgeReason.beanChange);
      expect(change.purgeG, 2.5);
      clock.set(DateTime.utc(2026, 11, 17, 6, 59));
      expect(data.purgeAdvice(grinderId: grinderId, beanId: beanId), isNull);
      clock.set(DateTime.utc(2026, 11, 17, 7));
      final idle = data.purgeAdvice(grinderId: grinderId, beanId: beanId)!;
      expect(idle.reason, PurgeReason.idle);
    });

    test('none without dead space', () async {
      final g = await data.addGrinder(
        name: 'Zero',
        scaleMin: 1,
        scaleMax: 30,
        scaleStep: 1,
        finerDirection: FinerDirection.down,
        deadSpaceG: 0,
      );
      await espresso(grinder: g.id);
      final other = await data.addBean(
        name: 'O',
        roaster: 'R',
        roastLevel: RoastLevel.dark,
        kind: BeanKind.filter,
      );
      expect(data.purgeAdvice(grinderId: g.id, beanId: other.id), isNull);
    });
  });

  group('recommendFor', () {
    test('no water profile -> noWater', () async {
      final b = await espresso();
      expect(data.recommendFor(b).reason, ReasonCode.noWater);
    });

    test('machine default water, in range, ready pack -> grind', () async {
      final w = await data.addWaterProfile(name: 'Soft', hardnessPpm: 80);
      await data.updateMachine(
        data.machineById(machineId)!.copyWith(defaultWaterProfileId: w.id),
      );
      final b = await espresso();
      final r = data.recommendFor(b);
      expect(r.reason, ReasonCode.tasteSour);
      expect(r.newSetting, 11.5);
    });

    test('resting pack and out-of-range brew water', () async {
      final w = await data.addWaterProfile(name: 'Soft', hardnessPpm: 80);
      final fresh = await data.addPack(
        beanId: beanId,
        roastDate: DateTime.utc(2026, 11, 15),
        sizeG: 250,
      );
      final b = await data.addBrew(
        method: BrewMethod.espresso,
        machineId: machineId,
        grinderId: grinderId,
        packId: fresh.id,
        grindSetting: 12,
        doseG: 17,
        waterProfileId: w.id,
      );
      expect(data.recommendFor(b).reason, ReasonCode.packResting);
      final hard = await data.addWaterProfile(name: 'Hard', hardnessPpm: 500);
      final b2 = b.copyWith(waterProfileId: hard.id);
      expect(data.recommendFor(b2).reason, ReasonCode.waterOutside);
    });
  });
}
