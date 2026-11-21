import '../../../core/rules/rule_set.dart';
import '../../beans/domain/pack_readiness.dart';
import '../../equipment/domain/grinder.dart';
import '../../water/domain/water_assessment.dart';
import '../../water/domain/water_profile.dart';
import 'brew.dart';
import 'grind_mover.dart';
import 'recommendation.dart';
import 'taste.dart';

/// Gives the single next dial-in step for a filter brew (SPEC R11).
///
/// The drawdown time decides first, then taste; the ratio is never advised.
class FilterAdvisor {
  /// Creates an advisor reading its thresholds from [brewRules].
  FilterAdvisor(RuleSet brewRules)
    : _over = _num(brewRules, 'filter.drawdown.coarserOver', 240),
      _under = _num(brewRules, 'filter.drawdown.finerUnder', 165),
      _twoOver = _num(brewRules, 'filter.drawdown.twoStepOver', 270),
      _twoUnder = _num(brewRules, 'filter.drawdown.twoStepUnder', 150),
      _overSource = _source(brewRules, 'filter.drawdown.coarserOver'),
      _underSource = _source(brewRules, 'filter.drawdown.finerUnder');

  final double _over;
  final double _under;
  final double _twoOver;
  final double _twoUnder;
  final String _overSource;
  final String _underSource;

  static double _num(RuleSet rules, String key, double fallback) {
    final v = rules.maybeEntry(key)?.value;
    return v is num ? v.toDouble() : fallback;
  }

  static String _source(RuleSet rules, String key) =>
      rules.maybeEntry(key)?.source ?? 'none';

  /// Returns the first applicable recommendation for [brew].
  ///
  /// Order: water missing, water outside range, pack resting (the caller
  /// passes the filter rest time), grind (drawdown first, then taste).
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
    if (assessment != null && !assessment.inScaRange) {
      final violation = assessment.firstViolation;
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
    final t = brew.drawdownS;
    if (t != null && t < _under) {
      return _move(
        brew,
        g,
        GrindDirection.finer,
        t < _twoUnder ? 2 : 1,
        ReasonCode.timeTooShort,
        _underSource,
      );
    }
    if (t != null && t > _over) {
      return _move(
        brew,
        g,
        GrindDirection.coarser,
        t > _twoOver ? 2 : 1,
        ReasonCode.timeTooLong,
        _overSource,
      );
    }
    switch (brew.taste) {
      case Taste.sour:
        return _move(
          brew,
          g,
          GrindDirection.finer,
          1,
          ReasonCode.tasteSour,
          _overSource,
        );
      case Taste.weak:
        return _move(
          brew,
          g,
          GrindDirection.finer,
          1,
          ReasonCode.tasteWeak,
          _overSource,
        );
      case Taste.bitter:
        return _move(
          brew,
          g,
          GrindDirection.coarser,
          1,
          ReasonCode.tasteBitter,
          _overSource,
        );
      case Taste.balanced:
      case null:
        return Recommendation(
          variable: RecommendationVariable.none,
          reason: ReasonCode.balancedInWindow,
          currentSetting: brew.grindSetting,
          source: _overSource,
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
  ) => GrindMover.move(
    g: g,
    current: brew.grindSetting,
    dir: dir,
    steps: steps,
    reason: reason,
    source: source,
  );
}
