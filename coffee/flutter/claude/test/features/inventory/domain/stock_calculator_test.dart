import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew.dart';
import 'package:kaffee_begleiter/features/inventory/domain/stock_calculator.dart';

import '../../../core/test_app_data.dart';
import '../inventory_helpers.dart';

void main() {
  final calc = StockCalculator(loadTestRest());
  // 504 g within 28 days: 28 brews of 18 g, one per day.
  final brews504 = [for (var i = 0; i < 28; i++) testBrew(18, daysAgo: i)];

  test('504 g in 28 days is 18 g per day, not rounded', () {
    expect(calc.consumptionPerDay(brews504, today), 18);
    expect(calc.consumptionPerDay([testBrew(10)], today), 10 / 28);
  });

  test('window is today-27 to today inclusive', () {
    expect(calc.consumptionPerDay([testBrew(28, daysAgo: 27)], today), 1);
    expect(calc.consumptionPerDay([testBrew(28, daysAgo: 28)], today), 0);
    expect(calc.consumptionPerDay([testBrew(28, daysAgo: -1)], today), 0);
  });

  test('purge counts as consumption', () {
    expect(calc.consumptionPerDay([testBrew(18, purgeG: 10)], today), 1);
  });

  StockStatusArgs args(double stock) =>
      (packs: [testPack('p1', '2026-11-04', stock)], brews: brews504);

  test('min stock 36 and order point 270 (lead 3 + rest 10)', () {
    final s = calc.status(
      bean: testBean(),
      packs: args(250).packs,
      brews: brews504,
      today: today,
    );
    expect(s.minStockG, 36);
    expect(s.restDays, 10);
    expect(s.orderPoint, 270);
  });

  test('stock 250 orders now with 13.9 days of cover, 300 does not', () {
    final low = calc.status(
      bean: testBean(),
      packs: args(250).packs,
      brews: brews504,
      today: today,
    );
    expect(low.orderNow, isTrue);
    expect(low.daysOfCover!.toStringAsFixed(1), '13.9');
    final high = calc.status(
      bean: testBean(),
      packs: args(300).packs,
      brews: brews504,
      today: today,
    );
    expect(high.orderNow, isFalse);
    final edge = calc.status(
      bean: testBean(),
      packs: args(270).packs,
      brews: brews504,
      today: today,
    );
    expect(edge.orderNow, isTrue);
  });

  test('no consumption and no min stock: order point 100, cover null', () {
    final s = calc.status(
      bean: testBean(),
      packs: [testPack('p1', '2026-11-04', 250)],
      brews: const [],
      today: today,
    );
    expect(s.consumptionPerDay, 0);
    expect(s.minStockG, 100);
    expect(s.orderPoint, 100);
    expect(s.daysOfCover, isNull);
    expect(s.orderNow, isFalse);
  });

  test('bean min stock wins; too old and deleted packs are not stock', () {
    final old = testPack('p2', '2026-09-01', 500);
    final s = calc.status(
      bean: testBean(minStockG: 50),
      packs: [testPack('p1', '2026-11-04', 80), old],
      brews: brews504,
      today: today,
    );
    expect(s.minStockG, 50);
    expect(s.orderPoint, 18 * 13 + 50);
    expect(s.totalStockG, 80);
  });

  test('resting packs count towards the total', () {
    final s = calc.status(
      bean: testBean(),
      packs: [testPack('p1', '2026-11-15', 250)],
      brews: const [],
      today: today,
    );
    expect(s.totalStockG, 250);
  });
}

typedef StockStatusArgs = ({List<Pack> packs, List<Brew> brews});
