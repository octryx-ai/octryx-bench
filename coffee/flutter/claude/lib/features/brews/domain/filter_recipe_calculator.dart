import '../../../core/rules/rule_set.dart';
import 'brew_method.dart';
import 'filter_recipe.dart';
import 'filter_step.dart';

/// Computes filter recipes (SPEC R10) from `brew_rules.json`.
///
/// Missing keys fall back to the spec defaults.
class FilterRecipeCalculator {
  /// Creates a calculator reading the `filter.*` rules of [brewRules].
  FilterRecipeCalculator(this._rules);

  final RuleSet _rules;

  double _n(String key, double fallback) {
    final v = _rules.maybeEntry(key)?.value;
    return v is num ? v.toDouble() : fallback;
  }

  /// Default ratio (1:16).
  double get defaultRatio => _n('filter.ratio.default', 16);

  /// Smallest ratio.
  double get minRatio => _n('filter.ratio.min', 14);

  /// Largest ratio.
  double get maxRatio => _n('filter.ratio.max', 18);

  /// Ratio step.
  double get ratioStep => _n('filter.ratio.step', 0.5);

  /// Clamps [ratio] to the range and snaps it to the nearest step.
  double normalizeRatio(double ratio) {
    final step = ratioStep;
    final snapped = (ratio / step).round() * step;
    return snapped.clamp(minRatio, maxRatio).toDouble();
  }

  /// Recipe for [doseG] at 1:[ratio]; the ratio is clamped and snapped to the
  /// nearest step (halves round up).
  FilterRecipe recipe({required double doseG, required double ratio}) {
    final r = normalizeRatio(ratio);
    final water = (doseG * r).roundToDouble();
    final bloomSeconds = _n('filter.bloom.seconds', 45).round();
    final bloom = doseG * _n('filter.bloom.factor', 2);
    double cum(String k, double f) =>
        (water * _n('filter.$k.factor', f)).roundToDouble();
    int at(String k, int f) => _n('filter.$k.atS', f.toDouble()).round();
    return FilterRecipe(
      doseG: doseG,
      ratio: r,
      waterG: water,
      bloomG: bloom,
      bloomSeconds: bloomSeconds,
      steps: [
        FilterStep(key: 'bloom', atS: 0, cumulativeG: bloom),
        FilterStep(
          key: 'pour1',
          atS: at('pour1', 45),
          cumulativeG: cum('pour1', 0.375),
        ),
        FilterStep(
          key: 'pour2',
          atS: at('pour2', 75),
          cumulativeG: cum('pour2', 0.6875),
        ),
        FilterStep(
          key: 'pour3',
          atS: at('pour3', 120),
          cumulativeG: cum('pour3', 1),
        ),
      ],
      targetMinS: _n('filter.totalTime.min', 180).round(),
      targetMaxS: _n('filter.totalTime.max', 210).round(),
      tempMinC: _n('filter.waterTempC.min', 92),
      tempMaxC: _n('filter.waterTempC.max', 96),
    );
  }

  /// Recipe scheme used for [m]: the other filter methods use V60's.
  BrewMethod schemeOf(BrewMethod m) => m.isFilter ? BrewMethod.v60 : m;

  /// Source URL of the recipe rules for [m]: V60 has one, the others `none`.
  String sourceOf(BrewMethod m) => m == BrewMethod.v60
      ? _rules.maybeEntry('filter.ratio.default')?.source ?? 'none'
      : 'none';
}
