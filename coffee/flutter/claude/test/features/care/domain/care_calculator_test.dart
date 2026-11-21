import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/care/domain/care_calculator.dart';
import 'package:kaffee_begleiter/features/care/domain/care_event.dart';
import 'package:kaffee_begleiter/features/care/domain/care_kind.dart';
import 'package:kaffee_begleiter/features/care/domain/care_status.dart';
import 'package:kaffee_begleiter/features/care/domain/care_task.dart';
import 'package:kaffee_begleiter/features/equipment/domain/finer_direction.dart';
import 'package:kaffee_begleiter/features/equipment/domain/grinder.dart';
import 'package:kaffee_begleiter/features/equipment/domain/machine.dart';
import 'package:kaffee_begleiter/features/water/domain/water_profile.dart';

import '../../../core/test_app_data.dart';
import '../../inventory/inventory_helpers.dart';

void main() {
  final calc = CareCalculator(loadTestRules('assets/care_rules.json'));
  final stamp = DateTime.utc(2026);
  final machine = Machine(
    id: 'm',
    createdAt: stamp,
    updatedAt: stamp,
    name: 'Linea',
    brewTempC: 93,
    preinfusionS: 5,
    pressureProfile: '9 bar',
    defaultWaterProfileId: 'w',
  );
  final grinder = Grinder(
    id: 'g',
    createdAt: stamp,
    updatedAt: stamp,
    name: 'M1',
    scaleMin: 1,
    scaleMax: 30,
    scaleStep: 0.5,
    finerDirection: FinerDirection.down,
    deadSpaceG: 2.5,
  );
  WaterProfile water(double ppm) => WaterProfile(
    id: 'w',
    createdAt: stamp,
    updatedAt: stamp,
    name: 'Tap',
    hardnessPpm: ppm,
  );
  CareEvent event(CareKind kind, DateTime doneAt, {bool grind = false}) =>
      CareEvent(
        id: 'e${doneAt.microsecondsSinceEpoch}${kind.name}',
        createdAt: stamp,
        updatedAt: stamp,
        machineId: grind ? null : 'm',
        grinderId: grind ? 'g' : null,
        kind: kind,
        doneAt: doneAt,
      );

  List<CareTask> tasks({
    List<CareEvent> events = const [],
    DateTime? now,
    double ppm = 120,
    int shots = 0,
  }) => calc.tasks(
    machines: [machine],
    grinders: [grinder],
    waterProfilesById: {'w': water(ppm)},
    events: events,
    brews: [for (var i = 0; i < shots; i++) testBrew(18, id: 'b$i')],
    today: now ?? today,
  );

  CareTask pick(List<CareTask> all, CareKind k) =>
      all.firstWhere((t) => t.kind == k);

  test('without any event a task is due today', () {
    final t = pick(tasks(), CareKind.backflush);
    expect(t.due, isTrue);
    expect(t.daysLeft, 0);
    expect(t.hintKey, 'never');
  });

  test('backflush 10 Nov: 6 days not due on 16 Nov, due on 17 Nov', () {
    final done = [event(CareKind.backflush, DateTime.utc(2026, 11, 10, 9))];
    final sixDays = pick(tasks(events: done, shots: 90), CareKind.backflush);
    expect(sixDays.due, isFalse);
    expect(sixDays.daysLeft, 1);
    expect(sixDays.shotsSince, 90);
    final sevenDays = pick(
      tasks(events: done, now: DateTime.utc(2026, 11, 17)),
      CareKind.backflush,
    );
    expect(sevenDays.due, isTrue);
  });

  test('200 shots make the backflush due early', () {
    final done = [event(CareKind.backflush, DateTime.utc(2026, 11, 15))];
    final t = pick(tasks(events: done, shots: 200), CareKind.backflush);
    expect(t.due, isTrue);
    expect(t.hintKey, 'backflush.shots');
    expect(
      pick(tasks(events: done, shots: 199), CareKind.backflush).due,
      isFalse,
    );
  });

  test('descale interval follows the water hardness', () {
    expect(calc.descaleDays(151), 30);
    expect(calc.descaleDays(150), 60);
    expect(calc.descaleDays(100), 60);
    expect(calc.descaleDays(99), 90);
    expect(calc.descaleDays(null), 60);
  });

  test('descale at 120 ppm, last 2026-10-01, is due 2026-11-30', () {
    final done = [event(CareKind.descale, DateTime.utc(2026, 10, 1, 8))];
    final t = pick(tasks(events: done, ppm: 120), CareKind.descale);
    expect(t.dueDate, DateTime.utc(2026, 11, 30));
  });

  test('grinder cleaning is due after 28 days', () {
    final done = [
      event(CareKind.grinderClean, DateTime.utc(2026, 10, 19, 8), grind: true),
    ];
    final t = pick(tasks(events: done), CareKind.grinderClean);
    expect(t.dueDate, DateTime.utc(2026, 11, 16));
    expect(t.due, isTrue);
  });

  test('status: more than 2 days ok, 1-2 soon, 0 or less due', () {
    CareStatus statusFor(int daysAgo) {
      final done = [
        event(CareKind.backflush, DateTime.utc(2026, 11, 16 - daysAgo, 8)),
      ];
      return pick(tasks(events: done), CareKind.backflush).status;
    }

    expect(statusFor(4), CareStatus.ok);
    expect(statusFor(5), CareStatus.soon);
    expect(statusFor(6), CareStatus.soon);
    expect(statusFor(7), CareStatus.due);
    expect(statusFor(9), CareStatus.due);
  });

  test('ring fraction is the remaining share of 7 days', () {
    final done = [event(CareKind.backflush, DateTime.utc(2026, 11, 16, 8))];
    expect(pick(tasks(events: done), CareKind.backflush).ringFraction, 1);
    final old = [event(CareKind.backflush, DateTime.utc(2026, 11, 13, 8))];
    expect(
      pick(tasks(events: old), CareKind.backflush).ringFraction,
      closeTo(4 / 7, 1e-9),
    );
  });

  test('tasks are sorted with due ones first', () {
    final done = [event(CareKind.backflush, DateTime.utc(2026, 11, 16, 8))];
    final all = tasks(events: done);
    expect(all.first.due, isTrue);
    expect(all.last.dueDate.isBefore(all.first.dueDate), isFalse);
  });

  test('only shots after the last backflush count towards the 200', () {
    final done = [event(CareKind.backflush, DateTime.utc(2026, 11, 14, 12))];
    List<CareTask> withShots(int before, int after) => calc.tasks(
      machines: [machine],
      grinders: const [],
      waterProfilesById: {'w': water(120)},
      events: done,
      brews: [
        for (var i = 0; i < before; i++) testBrew(18, id: 'old$i', daysAgo: 3),
        for (var i = 0; i < after; i++) testBrew(18, id: 'new$i'),
      ],
      today: today,
    );
    final few = pick(withShots(150, 60), CareKind.backflush);
    expect(few.shotsSince, 60);
    expect(few.due, isFalse);
    final many = pick(withShots(150, 200), CareKind.backflush);
    expect(many.shotsSince, 200);
    expect(many.due, isTrue);
    expect(many.hintKey, 'backflush.shots');
  });
}
