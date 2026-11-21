/// One step of a filter recipe: cumulative water at a time.
class FilterStep {
  /// Creates a step.
  const FilterStep({
    required this.key,
    required this.atS,
    required this.cumulativeG,
  });

  /// `bloom`, `pour1`, `pour2` or `pour3`.
  final String key;

  /// Seconds since brew start.
  final int atS;

  /// Total water poured by this step, in grams.
  final double cumulativeG;
}
