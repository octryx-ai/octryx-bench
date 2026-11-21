import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/today/domain/warning_kind.dart';

import '../features/brews/brew_test_helpers.dart';

void main() {
  test('a fresh setup warns about due care, nothing else', () async {
    final s = await seedBrewData();
    final kinds = s.data.warnings.map((w) => w.kind).toSet();
    expect(kinds, {WarningKind.careDue});
  });

  test('water outside the SCA range is warned about', () async {
    final s = await seedBrewData(hardnessPpm: 300);
    final water = s.data.warnings.where((w) => w.kind == WarningKind.water);
    expect(water.single.water!.name, 'Tap');
  });

  test('ready beans and the last brew are exposed for Heute', () async {
    final s = await seedBrewData();
    expect(s.data.lastBrew, isNull);
    expect(s.data.readyNowSummaries.map((e) => e.bean.id), [s.bean.id]);
    await s.brew(at: DateTime.utc(2026, 11, 15, 8));
    final newest = await s.brew(at: DateTime.utc(2026, 11, 16, 8));
    expect(s.data.lastBrew!.id, newest.id);
  });

  test('a resting bean is not ready now', () async {
    final s = await seedBrewData(roast: '2026-11-14');
    expect(s.data.readyNowSummaries, isEmpty);
  });

  test('consumption feeds stock status of the bean', () async {
    final s = await seedBrewData();
    await s.brew(at: DateTime.utc(2026, 11, 10, 8));
    final status = s.data.stockStatus(s.bean.id);
    expect(status.consumptionPerDay, closeTo(18 / 28, 1e-9));
    expect(s.data.consumptionOf(s.bean.id), closeTo(18 / 28, 1e-9));
  });
}
