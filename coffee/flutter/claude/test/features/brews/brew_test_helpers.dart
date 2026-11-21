import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/core/data/fixed_clock.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_method.dart';
import 'package:kaffee_begleiter/features/brews/domain/taste.dart';
import 'package:kaffee_begleiter/features/equipment/domain/finer_direction.dart';
import 'package:kaffee_begleiter/features/equipment/domain/grinder.dart';
import 'package:kaffee_begleiter/features/equipment/domain/machine.dart';
import 'package:kaffee_begleiter/features/water/domain/water_profile.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/test_app_data.dart';
import '../beans/bean_test_helpers.dart';

/// Seeded equipment, bean, pack and water used by the brew tests.
class BrewSeed {
  /// Bundles the seeded records.
  const BrewSeed({
    required this.data,
    required this.clock,
    required this.grinder,
    required this.machine,
    required this.bean,
    required this.pack,
    required this.water,
  });

  /// App data holding everything.
  final AppData data;

  /// Clock of [data]; "now" is 16 Nov 2026, 12:00 UTC.
  final FixedClock clock;

  /// Grinder M1: scale 1 to 30, step 0.5, finer is down, dead space 2.5 g.
  final Grinder grinder;

  /// Machine whose default water is [water].
  final Machine machine;

  /// Medium-roast espresso blend.
  final Bean bean;

  /// Pack of [bean], 250 g.
  final Pack pack;

  /// Water profile of 150 ppm hardness (in the SCA range).
  final WaterProfile water;

  /// Logs an espresso brew of 18 g to 36 g on the seeded equipment.
  Future<Brew> brew({
    double setting = 12,
    int? time = 27,
    Taste? taste,
    int? rating,
    DateTime? at,
    String? packId,
    String? waterId,
    double doseG = 18,
  }) => data.addBrew(
    method: BrewMethod.espresso,
    machineId: machine.id,
    grinderId: grinder.id,
    packId: packId ?? pack.id,
    grindSetting: setting,
    doseG: doseG,
    yieldG: 36,
    shotTimeS: time,
    waterProfileId: waterId,
    taste: taste,
    rating: rating,
    startedAt: at,
  );
}

/// Seeds M1, a machine, a bean with one pack roasted on [roast] and a
/// water profile with [hardnessPpm]; [machineWater] makes it the machine's
/// default water.
Future<BrewSeed> seedBrewData({
  String roast = '2026-11-01',
  double hardnessPpm = 150,
  bool machineWater = true,
}) async {
  final clock = FixedClock(DateTime.utc(2026, 11, 16, 12));
  final data = await loadTestAppData(clock: clock);
  final grinder = await data.addGrinder(
    name: 'M1',
    scaleMin: 1,
    scaleMax: 30,
    scaleStep: 0.5,
    finerDirection: FinerDirection.down,
    deadSpaceG: 2.5,
  );
  final water = await data.addWaterProfile(
    name: 'Tap',
    hardnessPpm: hardnessPpm,
  );
  final machine = await data.addMachine(
    name: 'Linea',
    brewTempC: 93,
    preinfusionS: 5,
    pressureProfile: '9 bar',
    defaultWaterProfileId: machineWater ? water.id : null,
  );
  final bean = await seedBean(data, 'Kenya AA', roasts: [roast]);
  return BrewSeed(
    data: data,
    clock: clock,
    grinder: grinder,
    machine: machine,
    bean: bean,
    pack: data.packsOf(bean.id).single,
    water: water,
  );
}

/// Text currently in the TextField inside the AppField `field-[name]`.
String fieldText(WidgetTester tester, String name) => tester
    .widget<TextField>(
      find.descendant(
        of: find.byKey(Key('field-$name')),
        matching: find.byType(TextField),
      ),
    )
    .controller!
    .text;
