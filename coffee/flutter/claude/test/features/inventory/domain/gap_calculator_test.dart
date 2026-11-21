import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/inventory/domain/gap_action.dart';
import 'package:kaffee_begleiter/features/inventory/domain/gap_calculator.dart';

import '../../../core/test_app_data.dart';
import '../inventory_helpers.dart';

void main() {
  final calc = GapCalculator(loadTestRest());
  final bean = testBean();

  DateTime d(int day) => DateTime.utc(2026, 11, day);

  test('B=90 sealed ready pack X, resting pack ready 25 Nov: open pack', () {
    final x = testPack('x', '2026-11-04', 90);
    final g = calc.gap(
      bean: bean,
      packs: [testPack('r', '2026-11-15', 250), x],
      consumptionPerDay: 18,
      today: today,
    )!;
    expect(g.from, d(21));
    expect(g.to, d(24));
    expect(g.days, 4);
    expect(g.action, GapAction.openPack);
    expect(g.pack!.id, 'x');
    expect(g.readyStockG, 90);
  });

  test('B=90 from an opened pack, no resting pack: order now', () {
    final g = calc.gap(
      bean: bean,
      packs: [testPack('o', '2026-11-04', 90, opened: true)],
      consumptionPerDay: 18,
      today: today,
    )!;
    expect(g.from, d(21));
    expect(g.to, d(28));
    expect(g.days, 8);
    expect(g.action, GapAction.orderNow);
    expect(g.pack, isNull);
  });

  test('an opened ready pack wins over a sealed one: order now', () {
    final g = calc.gap(
      bean: bean,
      packs: [
        testPack('o', '2026-11-04', 40, opened: true),
        testPack('x', '2026-11-05', 40),
      ],
      consumptionPerDay: 18,
      today: today,
    )!;
    expect(g.action, GapAction.orderNow);
  });

  test('B=0: gap from today to 28 Nov, order now', () {
    final g = calc.gap(
      bean: bean,
      packs: const [],
      consumptionPerDay: 18,
      today: today,
    )!;
    expect(g.from, d(16));
    expect(g.to, d(28));
    expect(g.days, 13);
    expect(g.action, GapAction.orderNow);
    expect(g.readyStockG, 0);
  });

  test('earliest sealed pack by roast date is X', () {
    final g = calc.gap(
      bean: bean,
      packs: [testPack('b', '2026-11-06', 10), testPack('a', '2026-11-03', 10)],
      consumptionPerDay: 18,
      today: today,
    )!;
    expect(g.pack!.id, 'a');
  });

  test('no consumption: no gap', () {
    expect(
      calc.gap(bean: bean, packs: const [], consumptionPerDay: 0, today: today),
      isNull,
    );
  });

  test('next ready day equal to the day after running out: no gap', () {
    final packs = [
      testPack('o', '2026-11-04', 90, opened: true),
      testPack('r', '2026-11-11', 250),
    ];
    expect(
      calc.gap(bean: bean, packs: packs, consumptionPerDay: 18, today: today),
      isNull,
    );
    final later = [packs.first, testPack('r', '2026-11-12', 250)];
    final g = calc.gap(
      bean: bean,
      packs: later,
      consumptionPerDay: 18,
      today: today,
    )!;
    expect(g.days, 1);
    expect(g.from, d(21));
  });

  test('too old and deleted packs are ignored', () {
    final deleted = testPack(
      'd',
      '2026-11-04',
      500,
    ).copyWithBase(deletedAt: DateTime.utc(2026, 11, 10));
    final g = calc.gap(
      bean: bean,
      packs: [testPack('t', '2026-09-01', 500), deleted],
      consumptionPerDay: 18,
      today: today,
    )!;
    expect(g.from, d(16));
  });
}
