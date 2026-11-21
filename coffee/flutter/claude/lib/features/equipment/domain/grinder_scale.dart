import 'grinder.dart';

/// Why a grind setting is invalid.
enum GrindSettingError {
  /// Outside `scaleMin..scaleMax`.
  outOfRange,

  /// Not a multiple of `scaleStep` counted from `scaleMin`.
  notOnStep,
}

/// Validation of grind settings against a grinder's dial scale (SPEC R1).
class GrinderScale {
  const GrinderScale._();

  static const double _tolerance = 1e-9;

  /// Returns the error for [value] on [g]'s scale, or null if valid.
  static GrindSettingError? validate(Grinder g, double value) {
    if (value < g.scaleMin - _tolerance || value > g.scaleMax + _tolerance) {
      return GrindSettingError.outOfRange;
    }
    if (g.scaleStep > 0) {
      final steps = (value - g.scaleMin) / g.scaleStep;
      if ((steps - steps.roundToDouble()).abs() > _tolerance) {
        return GrindSettingError.notOnStep;
      }
    }
    return null;
  }

  /// Grind setting a new brew starts at (OE-72).
  static const double defaultSetting = 15;

  /// Starting setting on [g]'s scale: [defaultSetting] when it is valid
  /// there (or no grinder is chosen), else the scale minimum.
  static double initial(Grinder? g) {
    if (g == null || validate(g, defaultSetting) == null) {
      return defaultSetting;
    }
    return g.scaleMin;
  }
}
