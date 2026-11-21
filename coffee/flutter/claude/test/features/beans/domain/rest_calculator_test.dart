import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack_readiness.dart';
import 'package:kaffee_begleiter/features/beans/domain/rest_calculator.dart';
import 'package:kaffee_begleiter/features/beans/domain/rest_method.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';

import '../../../core/test_app_data.dart';

Bean bean(BeanKind k, RoastLevel l) => Bean(
  id: 'b',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  name: 'X',
  roaster: 'R',
  roastLevel: l,
  kind: k,
);

Pack pack(DateTime roast) => Pack(
  id: 'p',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  beanId: 'b',
  roastDate: roast,
  sizeG: 250,
  remainingG: 250,
);

void main() {
  final calc = loadTestRest();
  final roast = DateTime.utc(2026, 11, 1);

  test('rest table from rules and defaults agree', () {
    const filter = [7, 5, 4, 3];
    const espresso = [14, 10, 7, 5];
    for (final c in [calc, RestCalculator.defaults()]) {
      for (final l in RoastLevel.values) {
        expect(c.restDays(RestMethod.filter, l), filter[l.dots - 1]);
        expect(c.restDays(RestMethod.espresso, l), espresso[l.dots - 1]);
      }
    }
  });

  test('R3 example: medium roast 2026-11-01', () {
    const m = RoastLevel.medium;
    expect(
      calc.readyDate(roast, RestMethod.filter, m),
      DateTime.utc(2026, 11, 6),
    );
    expect(
      calc.readyDate(roast, RestMethod.espresso, m),
      DateTime.utc(2026, 11, 11),
    );
    expect(calc.staleDate(roast), DateTime.utc(2026, 12, 16));
  });

  test('kind maps to rest method', () {
    expect(BeanKind.espressoBlend.restMethod, RestMethod.espresso);
    expect(BeanKind.allround.restMethod, RestMethod.espresso);
    expect(BeanKind.filter.restMethod, RestMethod.filter);
  });

  test('readiness boundaries', () {
    final b = bean(BeanKind.filter, RoastLevel.medium);
    final p = pack(roast);
    var r = calc.readiness(p, b, DateTime.utc(2026, 11, 5));
    expect(r.status, ReadinessStatus.resting);
    expect(r.daysLeft, 1);
    r = calc.readiness(p, b, DateTime.utc(2026, 11, 6));
    expect(r.status, ReadinessStatus.ready);
    expect(r.daysLeft, 0);
    r = calc.readiness(p, b, DateTime.utc(2026, 12, 15));
    expect(r.status, ReadinessStatus.ready);
    r = calc.readiness(p, b, DateTime.utc(2026, 12, 16));
    expect(r.status, ReadinessStatus.tooOld);
  });

  test('date math is DST safe and ignores time of day', () {
    final b = bean(BeanKind.espressoBlend, RoastLevel.light);
    final r = calc.readiness(
      pack(DateTime.utc(2026, 3, 20)),
      b,
      DateTime(2026, 3, 30, 23, 59),
    );
    expect(r.readyDate, DateTime.utc(2026, 4, 3));
    expect(r.daysLeft, 4);
  });
}
