import 'water_parameter.dart';
import 'water_range.dart';

/// Assessment of one water parameter.
class ParameterResult {
  /// Creates a result; unmeasured parameters count as in range.
  const ParameterResult({
    required this.parameter,
    required this.value,
    required this.range,
  });

  /// The assessed parameter.
  final WaterParameter parameter;

  /// Measured value, or null if not measured.
  final double? value;

  /// Acceptable range.
  final WaterRange range;

  /// Whether a value was entered.
  bool get measured => value != null;

  /// Whether the value is within range (always true if unmeasured).
  bool get inRange => value == null || range.contains(value!);

  /// Amount above max or below min (positive), or null if in range or
  /// unmeasured.
  double? get deviation {
    final v = value;
    if (v == null) return null;
    if (range.max != null && v > range.max!) return v - range.max!;
    if (range.min != null && v < range.min!) return range.min! - v;
    return null;
  }
}
