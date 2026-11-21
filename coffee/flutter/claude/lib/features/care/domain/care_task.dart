import 'care_kind.dart';
import 'care_status.dart';

/// One care task of a machine or grinder with its due date (SPEC R8).
class CareTask {
  /// Creates a task.
  const CareTask({
    required this.kind,
    this.machineId,
    this.grinderId,
    required this.name,
    this.lastDone,
    required this.shotsSince,
    required this.dueDate,
    required this.daysLeft,
    required this.ringFraction,
    required this.status,
    this.hintKey,
  });

  /// What to do.
  final CareKind kind;

  /// Machine concerned, or null.
  final String? machineId;

  /// Grinder concerned, or null.
  final String? grinderId;

  /// Name of the machine or grinder.
  final String name;

  /// When the task was last done; null if never.
  final DateTime? lastDone;

  /// Espresso shots on the machine since [lastDone] (0 for grinders).
  final int shotsSince;

  /// Day the task is due (date-only, UTC).
  final DateTime dueDate;

  /// Days from today to [dueDate]; 0 or less means due.
  final int daysLeft;

  /// Remaining share of the interval for the progress ring, 0 to 1.
  final double ringFraction;

  /// Urgency: due, soon (1-2 days) or ok.
  final CareStatus status;

  /// Why the task is due early: `backflush.shots` if the shot limit was
  /// reached, `never` if it was never done; otherwise null.
  final String? hintKey;

  /// Whether the task is due now.
  bool get due => status == CareStatus.due;
}
