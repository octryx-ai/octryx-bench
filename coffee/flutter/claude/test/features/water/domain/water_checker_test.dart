import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/water/domain/water_checker.dart';
import 'package:kaffee_begleiter/features/water/domain/water_parameter.dart';
import 'package:kaffee_begleiter/features/water/domain/water_profile.dart';

import '../../../core/test_app_data.dart';

final _t = DateTime.utc(2026, 11, 16);

WaterProfile _p({
  double hardness = 150,
  double? alk,
  double? tds,
  double? ph,
  double? na,
  double? cl,
}) => WaterProfile(
  id: 'w',
  createdAt: _t,
  updatedAt: _t,
  name: 'W',
  hardnessPpm: hardness,
  alkalinityPpm: alk,
  tdsPpm: tds,
  ph: ph,
  sodiumMgL: na,
  chlorineMgL: cl,
);

void main() {
  late WaterChecker checker;
  setUp(() async => checker = await loadTestChecker());

  test('ranges come from the asset', () {
    final tds = checker.rangeOf(WaterParameter.tds);
    expect((tds.min, tds.max, tds.target), (75, 250, 150));
    final alk = checker.rangeOf(WaterParameter.alkalinity);
    expect((alk.min, alk.max, alk.target), (40, 75, 40));
    expect(checker.rangeOf(WaterParameter.sodium).min, isNull);
    expect(checker.rangeOf(WaterParameter.chlorine).max, 0);
  });

  test('30 fH = 300 ppm violates hardness by 125', () {
    final a = checker.assess(_p(hardness: 300));
    expect(a.inScaRange, isFalse);
    expect(a.firstViolation!.parameter, WaterParameter.hardness);
    expect(a.firstViolation!.deviation, 125);
  });

  test('only hardness 150 ppm: in range, 1 of 6 measured', () {
    final a = checker.assess(_p());
    expect(a.results, hasLength(6));
    expect(a.results.map((r) => r.parameter), WaterParameter.values);
    expect(a.measuredCount, 1);
    expect(a.inScaRange, isTrue);
    expect(a.firstViolation, isNull);
    expect(a.results.first.measured, isFalse);
  });

  test('boundaries are inclusive', () {
    final a = checker.assess(
      _p(hardness: 50, tds: 250, alk: 75, ph: 6.5, na: 10, cl: 0),
    );
    expect(a.measuredCount, 6);
    expect(a.inScaRange, isTrue);
    expect(checker.assess(_p(hardness: 175)).inScaRange, isTrue);
    expect(checker.assess(_p(hardness: 49.9)).inScaRange, isFalse);
  });

  test('below min and chlorine deviations', () {
    final low = checker.assess(_p(tds: 60)).firstViolation!;
    expect(low.parameter, WaterParameter.tds);
    expect(low.deviation, 15);
    final cl = checker.assess(_p(cl: 0.5)).firstViolation!;
    expect(cl.parameter, WaterParameter.chlorine);
    expect(cl.deviation, 0.5);
  });
}
