import '../../beans/domain/bean.dart';
import '../../care/domain/care_task.dart';
import '../../inventory/domain/gap_warning.dart';
import '../../inventory/domain/stock_status.dart';
import '../../water/domain/water_profile.dart';
import 'warning_kind.dart';
import 'warning_severity.dart';

/// One warning of the Today screen; the field matching [kind] is set
/// (gap: [bean] and [gap]; order: [bean] and [stock]; careDue: [care];
/// water: [water]).
class AppWarning {
  /// Creates a warning.
  const AppWarning({
    required this.kind,
    required this.severity,
    this.bean,
    this.gap,
    this.stock,
    this.care,
    this.water,
  });

  /// What the warning is about.
  final WarningKind kind;

  /// How urgent it is.
  final WarningSeverity severity;

  /// Bean concerned (gap and order).
  final Bean? bean;

  /// The gap (kind gap).
  final GapWarning? gap;

  /// The stock status (kind order).
  final StockStatus? stock;

  /// The care task (kind careDue).
  final CareTask? care;

  /// The water profile (kind water).
  final WaterProfile? water;
}
