import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/rules/rule_set.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_method.dart';
import 'package:kaffee_begleiter/features/brews/domain/filter_recipe_calculator.dart';

import '../../../core/test_app_data.dart';

void main() {
  final calc = FilterRecipeCalculator(loadTestRules('assets/brew_rules.json'));

  List<double> cums(double dose, double ratio) => [
    for (final s in calc.recipe(doseG: dose, ratio: ratio).steps) s.cumulativeG,
  ];

  test('20 g at 1:16 -> 320 g', () {
    final r = calc.recipe(doseG: 20, ratio: 16);
    expect(r.waterG, 320);
    expect(r.bloomG, 40);
    expect(r.bloomSeconds, 45);
    expect(cums(20, 16), [40, 120, 220, 320]);
    expect([for (final s in r.steps) s.atS], [0, 45, 75, 120]);
    expect(
      [for (final s in r.steps) s.key],
      ['bloom', 'pour1', 'pour2', 'pour3'],
    );
    expect(r.targetMinS, 180);
    expect(r.targetMaxS, 210);
    expect(r.tempMinC, 92);
    expect(r.tempMaxC, 96);
    expect(r.pours.length, 4);
    expect(r.pours[1].atS, 45);
    expect(r.pours[1].cumulativeG, 120);
  });

  test('15 g at 1:15 -> 225 g with rounded sums', () {
    final r = calc.recipe(doseG: 15, ratio: 15);
    expect(r.waterG, 225);
    expect(r.bloomG, 30);
    expect(cums(15, 15), [30, 84, 155, 225]);
  });

  test('ratio is clamped and snapped to 0.5', () {
    expect(calc.recipe(doseG: 20, ratio: 13).ratio, 14);
    expect(calc.recipe(doseG: 20, ratio: 19).ratio, 18);
    expect(calc.recipe(doseG: 20, ratio: 18.4).ratio, 18);
    expect(calc.recipe(doseG: 20, ratio: 15.3).ratio, 15.5);
    expect(calc.recipe(doseG: 20, ratio: 15.2).ratio, 15);
    expect(calc.recipe(doseG: 20, ratio: 15.25).ratio, 15.5);
  });

  test('water resolution is 1 g', () {
    expect(calc.recipe(doseG: 17.3, ratio: 16).waterG, 277);
  });

  test('rule getters and defaults', () {
    expect(calc.defaultRatio, 16);
    expect(calc.minRatio, 14);
    expect(calc.maxRatio, 18);
    expect(calc.ratioStep, 0.5);
    final d = FilterRecipeCalculator(RuleSet(const []));
    expect(d.defaultRatio, 16);
    expect(d.recipe(doseG: 20, ratio: 16).waterG, 320);
  });

  test('schemes and sources', () {
    for (final m in [
      BrewMethod.chemex,
      BrewMethod.kalita,
      BrewMethod.aeropress,
      BrewMethod.batch,
      BrewMethod.v60,
    ]) {
      expect(calc.schemeOf(m), BrewMethod.v60);
    }
    expect(calc.sourceOf(BrewMethod.v60), contains('coffeehero'));
    expect(calc.sourceOf(BrewMethod.chemex), 'none');
    expect(calc.sourceOf(BrewMethod.batch), 'none');
  });
}
