import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/care/domain/care_kind.dart';

import '../brews/brew_test_helpers.dart';

void main() {
  test(
    'marking a backflush done shows 7 days and deleting it reverts',
    () async {
      final s = await seedBrewData();
      var task = s.data.careTasks.firstWhere(
        (t) => t.kind == CareKind.backflush,
      );
      expect(task.due, isTrue);
      final event = await s.data.markCareDone(task);
      task = s.data.careTasks.firstWhere((t) => t.kind == CareKind.backflush);
      expect(task.daysLeft, 7);
      expect(task.ringFraction, 1);
      expect(task.due, isFalse);
      await s.data.deleteCareEvent(event.id);
      task = s.data.careTasks.firstWhere((t) => t.kind == CareKind.backflush);
      expect(task.due, isTrue);
    },
  );

  test('shots are counted per machine', () async {
    final s = await seedBrewData();
    await s.brew();
    await s.brew();
    expect(s.data.shotsOfMachine(s.machine.id), 2);
    final task = s.data.careTasks.firstWhere(
      (t) => t.kind == CareKind.backflush,
    );
    expect(task.shotsSince, 2);
  });
}
