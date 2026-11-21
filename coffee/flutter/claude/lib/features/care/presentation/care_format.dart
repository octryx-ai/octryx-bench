import '../../../core/format/app_format.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/care_kind.dart';
import '../domain/care_task.dart';

/// Localized texts of care tasks.
abstract final class CareFormat {
  /// Name of a kind: Backflush, Descale or Grinder cleaning.
  static String kind(AppLocalizations l, CareKind kind) => switch (kind) {
    CareKind.backflush => l.careBackflush,
    CareKind.descale => l.careDescale,
    CareKind.grinderClean => l.careGrinderClean,
  };

  /// Title with the machine or grinder name, e.g. "Backflush Linea".
  static String title(AppLocalizations l, CareTask task) =>
      l.careTaskTitle(kind(l, task.kind), task.name);

  /// "Due" for a due task, else "In N days".
  static String status(AppLocalizations l, CareTask task) =>
      task.due ? l.careDue : l.careInDays(task.daysLeft);

  /// Last done date or "Never done".
  static String lastDone(AppLocalizations l, AppFormat format, CareTask task) {
    final done = task.lastDone;
    return done == null
        ? l.careNeverDone
        : l.careLastDone(format.date(done.toLocal()));
  }

  /// Whether the shot counter is shown (machine tasks only).
  static bool showsShots(CareTask task) => task.kind != CareKind.grinderClean;
}
