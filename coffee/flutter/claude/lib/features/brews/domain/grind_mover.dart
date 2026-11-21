import '../../equipment/domain/finer_direction.dart';
import '../../equipment/domain/grinder.dart';
import 'recommendation.dart';

/// Turns a grind direction into a clamped dial move (shared by the advisors).
class GrindMover {
  const GrindMover._();

  /// Moves [current] by [steps] dial steps of [g] in [dir].
  ///
  /// The result is clamped to the grinder scale; if the scale end blocks the
  /// move the reason becomes [ReasonCode.scaleEnd].
  static Recommendation move({
    required Grinder g,
    required double current,
    required GrindDirection dir,
    required int steps,
    required ReasonCode reason,
    required String source,
  }) {
    final down =
        (dir == GrindDirection.finer) ==
        (g.finerDirection == FinerDirection.down);
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
