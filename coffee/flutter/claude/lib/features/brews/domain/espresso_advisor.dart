import '../../../core/rules/rule_set.dart';
import '../../beans/domain/pack_readiness.dart';
import '../../equipment/domain/finer_direction.dart';
import '../../equipment/domain/grinder.dart';
import '../../water/domain/water_assessment.dart';
import '../../water/domain/water_profile.dart';
import 'brew.dart';
import 'recommendation.dart';
import 'taste.dart';

/// Gives the single next dial-in step for an espresso shot (SPEC R9).
///
/// Thresholds come from `brew_rules.json`; missing keys fall back to the
/// spec defaults.
class EspressoAdvisor {
  /// Creates an advisor reading its thresholds from [brewRules].
  EspressoAdvisor(RuleSet brewRules)
    : _min = _num(brewRules, 'espresso.time.min', 25),
      _max = _num(brewRules, 'espresso.time.max', 30),
      _strongMin = _num(brewRules, 'espresso.time.strongMin', 20),
      _strongMax = _num(brewRules, 'espresso.time.strongMax', 35),
      _tasteSteps = _num(brewRules, 'espresso.taste.step', 1).round(),
      _minSource = _source(brewRules, 'espresso.time.min'),
      _maxSource = _source(brewRules, 'espresso.time.max'),
      _tasteSource = _source(brewRules, 'espresso.taste.step');

  final double _min;
  final double _max;
  final double _strongMin;
  final double _strongMax;
  final int _tasteSteps;
  final String _minSource;
  final String _maxSource;
  final String _tasteSource;

  static double _num(RuleSet rules, String key, double fallback) {
    final e = rules.maybeEntry(key);
    return e != null && e.value is num
        ? (e.value! as num).toDouble()
        : fallback;
  }

  static String _source(RuleSet rules, String key) =>
      rules.maybeEntry(key)?.source ?? 'none';

  /// Returns the first applicable recommendation for [brew].
  ///
  /// Order: water missing, water outside range, pack resting, grind (time
  /// first, then taste). [assessment] is null when [water] is null.
  Recommendation advise({
    required Brew brew,
    required Grinder grinder,
    required WaterProfile? water,
    required WaterAssessment? assessment,
    required PackReadiness readiness,
  }) {
    if (water == null) {
      return const Recommendation(
        variable: RecommendationVariable.water,
        reason: ReasonCode.noWater,
      );
    }
    final violation = assessment?.firstViolation;
    if (assessment != null && !assessment.inScaRange) {
      return Recommendation(
        variable: RecommendationVariable.water,
        reason: ReasonCode.waterOutside,
        waterParameter: violation?.parameter,
        waterValue: violation?.value,
      );
    }
    if (readiness.status == ReadinessStatus.resting) {
      return Recommendation(
        variable: RecommendationVariable.rest,
        reason: ReasonCode.packResting,
        restDaysLeft: readiness.daysLeft,
      );
    }
    return _grind(brew, grinder);
  }

  Recommendation _grind(Brew brew, Grinder g) {
    final t = brew.shotTimeS;
    if (t != null && t < _min) {
      return _move(
        brew,
        g,
        GrindDirection.finer,
        t < _strongMin ? 2 : 1,
        ReasonCode.timeTooShort,
        _minSource,
      );
    }
    if (t != null && t > _max) {
      return _move(
        brew,
        g,
        GrindDirection.coarser,
        t > _strongMax ? 2 : 1,
        ReasonCode.timeTooLong,
        _maxSource,
      );
    }
    switch (brew.taste) {
      case Taste.sour:
        return _move(
          brew,
          g,
          GrindDirection.finer,
          _tasteSteps,
          ReasonCode.tasteSour,
          _tasteSource,
        );
      case Taste.weak:
        return _move(
          brew,
          g,
          GrindDirection.finer,
          _tasteSteps,
          ReasonCode.tasteWeak,
          _tasteSource,
        );
      case Taste.bitter:
        return _move(
          brew,
          g,
          GrindDirection.coarser,
          _tasteSteps,
          ReasonCode.tasteBitter,
          _tasteSource,
        );
      case Taste.balanced:
      case null:
        return Recommendation(
          variable: RecommendationVariable.none,
          reason: ReasonCode.balancedInWindow,
          currentSetting: brew.grindSetting,
          source: _tasteSource,
        );
    }
  }

  Recommendation _move(
    Brew brew,
    Grinder g,
    GrindDirection dir,
    int steps,
    ReasonCode reason,
    String source,
  ) {
    final down =
        (dir == GrindDirection.finer) ==
        (g.finerDirection == FinerDirection.down);
    final current = brew.grindSetting;
    final raw = current + (down ? -1 : 1) * steps * g.scaleStep;
    final clamped = raw.clamp(g.scaleMin, g.scaleMax).toDouble();
    final next = (clamped * 1e6).round() / 1e6;
    final moved = (next - current).abs() > 1e-9;
    return Recommendation(
      variable: RecommendationVariable.grind,
      reason: moved ? reason : ReasonCode.scaleEnd,
      newSetting: moved ? next : current,
      currentSetting: current,
      direction: dir,
      steps: moved ? ((next - current).abs() / g.scaleStep).round() : steps,
      source: source,
    );
  }
}
