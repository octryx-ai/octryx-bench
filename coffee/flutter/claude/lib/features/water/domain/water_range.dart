/// Acceptable range of a water parameter; null bounds are open.
class WaterRange {
  /// Creates a range.
  const WaterRange({this.min, this.max, this.target});

  /// Lower bound (inclusive), or null for none.
  final double? min;

  /// Upper bound (inclusive), or null for none.
  final double? max;

  /// Ideal value, if defined.
  final double? target;

  /// Whether [v] lies within the inclusive bounds.
  bool contains(double v) =>
      (min == null || v >= min!) && (max == null || v <= max!);
}
