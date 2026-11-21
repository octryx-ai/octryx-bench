import 'parameter_result.dart';

/// Result of checking a water profile against the SCA range.
class WaterAssessment {
  /// Creates an assessment from [results] (one per parameter, enum order).
  WaterAssessment(List<ParameterResult> results)
    : results = List.unmodifiable(results);

  /// Always six results, in [WaterParameter] order.
  final List<ParameterResult> results;

  /// Number of parameters with a value.
  int get measuredCount => results.where((r) => r.measured).length;

  /// Whether every measured parameter is in range.
  bool get inScaRange => results.every((r) => r.inRange);

  /// The first measured parameter out of range, or null.
  ParameterResult? get firstViolation {
    for (final r in results) {
      if (!r.inRange) return r;
    }
    return null;
  }
}
