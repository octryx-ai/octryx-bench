import '../../beans/domain/pack.dart';
import 'gap_action.dart';

/// A period without ready coffee for a bean (SPEC R6).
class GapWarning {
  /// Creates a warning.
  const GapWarning({
    required this.from,
    required this.to,
    required this.action,
    required this.days,
    this.pack,
    this.readyStockG = 0,
  });

  /// First day without coffee (date-only, UTC).
  final DateTime from;

  /// Last day without coffee (date-only, UTC).
  final DateTime to;

  /// Recommended action.
  final GapAction action;

  /// Number of days from [from] to [to] inclusive.
  final int days;

  /// The sealed ready pack to open for [GapAction.openPack], else null.
  final Pack? pack;

  /// Grams of ready coffee available today; 0 means nothing to brew now.
  final double readyStockG;
}
