import 'brew_pour.dart';
import 'filter_step.dart';

/// A computed filter recipe (SPEC R10).
class FilterRecipe {
  /// Creates a recipe.
  const FilterRecipe({
    required this.doseG,
    required this.ratio,
    required this.waterG,
    required this.bloomG,
    required this.bloomSeconds,
    required this.steps,
    required this.targetMinS,
    required this.targetMaxS,
    required this.tempMinC,
    required this.tempMaxC,
  });

  /// Coffee dose in grams.
  final double doseG;

  /// Water per gram coffee (1:ratio).
  final double ratio;

  /// Total water in grams.
  final double waterG;

  /// Bloom water in grams.
  final double bloomG;

  /// Bloom duration in seconds.
  final int bloomSeconds;

  /// Bloom and the three pours with cumulative water.
  final List<FilterStep> steps;

  /// Lower target total time in seconds.
  final int targetMinS;

  /// Upper target total time in seconds.
  final int targetMaxS;

  /// Lower water temperature in degrees Celsius.
  final double tempMinC;

  /// Upper water temperature in degrees Celsius.
  final double tempMaxC;

  /// The steps as storable [BrewPour]s.
  List<BrewPour> get pours => [
    for (final s in steps) BrewPour(atS: s.atS, cumulativeG: s.cumulativeG),
  ];
}
