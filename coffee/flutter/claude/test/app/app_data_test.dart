import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/app/app_scope.dart';
import 'package:kaffee_begleiter/core/data/fixed_clock.dart';
import 'package:kaffee_begleiter/features/equipment/domain/finer_direction.dart';
import 'package:kaffee_begleiter/features/settings/domain/hardness_unit.dart';

void main() {
  late FixedClock clock;
  late AppData data;
  var notified = 0;

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 11, 16, 8));
    data = AppData(clock: clock)..addListener(() => notified++);
    notified = 0;
  });

  Future<String> addGrinder(String name) async {
    clock.advance(const Duration(minutes: 1));
    return (await data.addGrinder(
      name: name,
      scaleMin: 1,
      scaleMax: 30,
      scaleStep: 0.5,
      finerDirection: FinerDirection.up,
      deadSpaceG: 0.5,
    )).id;
  }

  test('grinder soft delete: disappears from list, stays resolvable', () async {
    final id = await addGrinder('A');
    expect(data.grinders.map((g) => g.name), ['A']);
    clock.advance(const Duration(minutes: 1));
    await data.deleteGrinder(id);
    expect(data.grinders, isEmpty);
    final g = data.grinderById(id)!;
    expect(g.deletedAt, isNotNull);
    expect(g.updatedAt, g.deletedAt);
    expect(notified, 2);
  });

  test('lists are sorted by createdAt ascending', () async {
    await addGrinder('first');
    await addGrinder('second');
    expect(data.grinders.map((g) => g.name), ['first', 'second']);
  });

  test('updateGrinder persists and notifies', () async {
    final id = await addGrinder('A');
    clock.advance(const Duration(minutes: 1));
    await data.updateGrinder(data.grinderById(id)!.copyWith(name: 'B'));
    expect(data.grinders.single.name, 'B');
    expect(
      data.grinders.single.updatedAt.isAfter(data.grinders.single.createdAt),
      isTrue,
    );
    expect(notified, 2);
  });

  test('water profile used as machine default survives deletion', () async {
    final w = await data.addWaterProfile(name: 'Tap', hardnessPpm: 150);
    final m = await data.addMachine(
      name: 'M',
      brewTempC: 93,
      preinfusionS: 5,
      pressureProfile: 'flat',
      defaultWaterProfileId: w.id,
    );
    await data.deleteWaterProfile(w.id);
    expect(data.waterProfiles, isEmpty);
    expect(data.machines.single.id, m.id);
    expect(data.waterProfileById(m.defaultWaterProfileId!)!.name, 'Tap');
  });

  test('machine and water profile update/delete', () async {
    final w = await data.addWaterProfile(name: 'T', hardnessPpm: 100, ph: 7);
    await data.updateWaterProfile(w.copyWith(hardnessPpm: 120, ph: null));
    expect(data.waterProfiles.single.hardnessPpm, 120);
    expect(data.waterProfiles.single.ph, isNull);
    final m = await data.addMachine(
      name: 'M',
      brewTempC: 93,
      preinfusionS: 5,
      pressureProfile: 'flat',
    );
    await data.updateMachine(m.copyWith(brewTempC: 94));
    expect(data.machines.single.brewTempC, 94);
    await data.deleteMachine(m.id);
    expect(data.machines, isEmpty);
    expect(data.machineById(m.id), isNotNull);
  });

  test('hardness unit change keeps stored ppm', () async {
    expect(data.hardnessUnit, HardnessUnit.fH);
    final w = await data.addWaterProfile(name: 'T', hardnessPpm: 150);
    await data.setHardnessUnit(HardnessUnit.dH);
    expect(data.hardnessUnit, HardnessUnit.dH);
    expect(data.waterProfileById(w.id)!.hardnessPpm, 150);
    expect(data.hardnessUnit.displayValue(150), 8.4);
  });

  testWidgets('AppScope provides and rebuilds on change', (tester) async {
    var builds = 0;
    await tester.pumpWidget(
      AppScope(
        data: data,
        child: Builder(
          builder: (context) {
            builds++;
            AppScope.of(context).grinders;
            return const SizedBox();
          },
        ),
      ),
    );
    await addGrinder('A');
    await tester.pump();
    expect(builds, 2);
  });
}
