import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/core/data/fixed_clock.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_exception.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_field_error.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_method.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_pour.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_validation.dart';
import 'package:kaffee_begleiter/features/brews/domain/recommendation.dart';
import 'package:kaffee_begleiter/features/brews/domain/taste.dart';
import 'package:kaffee_begleiter/features/equipment/domain/finer_direction.dart';

import '../../../core/test_app_data.dart';

void main() {
  late AppData data;
  late String grinderId;
  late String waterId;
  late String packId;

  setUp(() async {
    data = await loadTestAppData(
      clock: FixedClock(DateTime.utc(2026, 11, 16, 8)),
    );
    grinderId = (await data.addGrinder(
      name: 'Niche',
      scaleMin: 1,
      scaleMax: 30,
      scaleStep: 0.5,
      finerDirection: FinerDirection.down,
      deadSpaceG: 0,
    )).id;
    waterId = (await data.addWaterProfile(name: 'W', hardnessPpm: 80)).id;
    final bean = await data.addBean(
      name: 'Allround',
      roaster: 'R',
      roastLevel: RoastLevel.medium,
      kind: BeanKind.allround,
    );
    // 6 days: ready for filter (5), still resting for espresso (10).
    packId = (await data.addPack(
      beanId: bean.id,
      roastDate: DateTime.utc(2026, 11, 10),
      sizeG: 250,
    )).id;
  });

  Future<Brew> filter({
    int? drawdown = 200,
    Taste? taste,
    double dose = 20,
    List<BrewPour> pours = const [],
  }) => data.addBrew(
    method: BrewMethod.v60,
    grinderId: grinderId,
    packId: packId,
    grindSetting: 20,
    doseG: dose,
    waterProfileId: waterId,
    taste: taste,
    waterTotalG: 320,
    bloomG: 40,
    pours: pours,
    drawdownS: drawdown,
  );

  test('filter brew needs no machine, deducts stock, stores pours', () async {
    final pours = [
      const BrewPour(atS: 0, cumulativeG: 40),
      const BrewPour(atS: 45, cumulativeG: 120),
    ];
    final b = await filter(pours: pours);
    expect(b.machineId, isNull);
    expect(b.waterTotalG, 320);
    expect(b.bloomG, 40);
    expect(b.pours, pours);
    expect(b.drawdownS, 200);
    expect(b.shotTimeS, isNull);
    expect(b.yieldG, isNull);
    expect(data.packById(packId)!.remainingG, 230);
    expect(data.brews.single.id, b.id);
  });

  test('filter brew ignores espresso-only values', () async {
    final b = await data.addBrew(
      method: BrewMethod.chemex,
      grinderId: grinderId,
      packId: packId,
      grindSetting: 20,
      doseG: 20,
      yieldG: 40,
      shotTimeS: 30,
    );
    expect(b.yieldG, isNull);
    expect(b.shotTimeS, isNull);
  });

  test('espresso still needs a machine; too little stock fails', () async {
    await expectLater(
      data.addBrew(
        method: BrewMethod.espresso,
        grinderId: grinderId,
        packId: packId,
        grindSetting: 12,
        doseG: 18,
      ),
      throwsA(
        isA<BrewException>().having(
          (e) => e.failure,
          'failure',
          BrewFailure.noMachine,
        ),
      ),
    );
    await expectLater(
      filter(dose: 300),
      throwsA(
        isA<BrewException>().having(
          (e) => e.failure,
          'failure',
          BrewFailure.notEnoughBeans,
        ),
      ),
    );
  });

  test('drawdown validation', () {
    BrewFieldError? v(int? s) => BrewValidation.validateDrawdown(s);
    expect(v(null), BrewFieldError.drawdownRequired);
    expect(v(0), BrewFieldError.drawdownOutOfRange);
    expect(v(1), isNull);
    expect(v(600), isNull);
    expect(v(601), BrewFieldError.drawdownOutOfRange);
    expect(BrewValidation.validateDrawdown(null, required: false), isNull);
  });

  test('addBrew rejects an invalid drawdown', () async {
    await expectLater(
      filter(drawdown: 601),
      throwsA(
        isA<BrewException>().having(
          (e) => e.failure,
          'failure',
          BrewFailure.invalidDrawdown,
        ),
      ),
    );
    expect(data.packById(packId)!.remainingG, 250);
  });

  group('recommendFor dispatch', () {
    test('filter uses drawdown thresholds and the filter rest time', () async {
      final b = await filter(drawdown: 200, taste: Taste.sour);
      final r = data.recommendFor(b);
      expect(r.variable, RecommendationVariable.grind);
      expect(r.reason, ReasonCode.tasteSour);
      expect(r.newSetting, 19.5);
      final long = data.recommendFor(await filter(drawdown: 255));
      expect(long.reason, ReasonCode.timeTooLong);
      expect(long.newSetting, 20.5);
    });

    test('espresso uses shot time and the espresso rest time', () async {
      final machine = await data.addMachine(
        name: 'M',
        brewTempC: 93,
        preinfusionS: 5,
        pressureProfile: 'flat',
      );
      final b = await data.addBrew(
        method: BrewMethod.espresso,
        machineId: machine.id,
        grinderId: grinderId,
        packId: packId,
        grindSetting: 12,
        doseG: 18,
        yieldG: 36,
        shotTimeS: 27,
        taste: Taste.sour,
        waterProfileId: waterId,
      );
      final r = data.recommendFor(b);
      expect(r.variable, RecommendationVariable.rest);
      expect(r.reason, ReasonCode.packResting);
      expect(r.restDaysLeft, 4);
    });

    test('espresso 27 s sour on a rested pack is espresso advice', () async {
      final bean = await data.addBean(
        name: 'E',
        roaster: 'R',
        roastLevel: RoastLevel.medium,
        kind: BeanKind.espressoBlend,
      );
      final pack = await data.addPack(
        beanId: bean.id,
        roastDate: DateTime.utc(2026, 10, 20),
        sizeG: 250,
      );
      final machine = await data.addMachine(
        name: 'M',
        brewTempC: 93,
        preinfusionS: 5,
        pressureProfile: 'flat',
      );
      final b = await data.addBrew(
        method: BrewMethod.espresso,
        machineId: machine.id,
        grinderId: grinderId,
        packId: pack.id,
        grindSetting: 12,
        doseG: 18,
        yieldG: 36,
        shotTimeS: 27,
        taste: Taste.sour,
        waterProfileId: waterId,
      );
      expect(data.recommendFor(b).newSetting, 11.5);
    });

    test('missing water gives noWater for filter', () async {
      final b = await data.addBrew(
        method: BrewMethod.v60,
        grinderId: grinderId,
        packId: packId,
        grindSetting: 20,
        doseG: 20,
        drawdownS: 200,
      );
      expect(data.recommendFor(b).reason, ReasonCode.noWater);
    });
  });

  test('filterPackSuggestions uses today and the filter rest', () async {
    final s = data.filterPackSuggestions();
    expect(s.map((e) => e.pack.id), [packId]);
    expect(s.single.fallback, isFalse);
  });

  test('shotsOfMachine counts espresso only', () async {
    await filter();
    expect(data.shotsOfMachine('any'), 0);
  });
}
