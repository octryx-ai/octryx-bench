import '../../water/domain/water_parameter.dart';

/// Which variable a recommendation changes.
enum RecommendationVariable {
  /// Fix the water first.
  water,

  /// Wait for the beans to rest.
  rest,

  /// Adjust the grind.
  grind,

  /// Nothing to change.
  none,
}

/// Why a recommendation was made.
enum ReasonCode {
  /// No water profile known.
  noWater,

  /// Water outside the SCA range.
  waterOutside,

  /// Pack still resting.
  packResting,

  /// Shot shorter than the window.
  timeTooShort,

  /// Shot longer than the window.
  timeTooLong,

  /// Tastes sour.
  tasteSour,

  /// Tastes weak.
  tasteWeak,

  /// Tastes bitter.
  tasteBitter,

  /// Balanced and inside the time window.
  balancedInWindow,

  /// The grinder scale ends, no further change possible.
  scaleEnd,
}

/// Direction of a grind change.
enum GrindDirection {
  /// Grind finer.
  finer,

  /// Grind coarser.
  coarser,
}

/// The single next-step advice for an espresso brew (SPEC R9).
class Recommendation {
  /// Creates a recommendation.
  const Recommendation({
    required this.variable,
    required this.reason,
    this.newSetting,
    this.currentSetting,
    this.direction,
    this.steps = 0,
    this.waterParameter,
    this.waterValue,
    this.restDaysLeft,
    this.source = 'none',
  });

  /// What to change.
  final RecommendationVariable variable;

  /// Why.
  final ReasonCode reason;

  /// Suggested dial setting (grind), or null.
  final double? newSetting;

  /// Dial setting of the brew (grind), or null.
  final double? currentSetting;

  /// Grind direction, or null.
  final GrindDirection? direction;

  /// Number of dial steps.
  final int steps;

  /// Offending water parameter (water), or null.
  final WaterParameter? waterParameter;

  /// Value of the offending parameter, or null.
  final double? waterValue;

  /// Days until the pack is ready (rest), or null.
  final int? restDaysLeft;

  /// Source URL of the deciding rule, or `none`.
  final String source;
}
