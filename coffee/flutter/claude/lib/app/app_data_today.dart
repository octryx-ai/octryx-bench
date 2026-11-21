import 'package:flutter/foundation.dart';

import '../features/care/domain/care_task.dart';
import '../features/today/domain/app_warning.dart';
import '../features/today/domain/warning_kind.dart';
import '../features/today/domain/warning_severity.dart';
import 'app_data_brews.dart';
import 'app_data_care.dart';
import 'app_data_inventory.dart';

/// Warnings of the Today screen, assembled from stock, care and water.
mixin AppDataToday
    on ChangeNotifier, AppDataBrews, AppDataInventory, AppDataCare {
  /// Warnings in this order: gaps, reorders (per bean), due care tasks, water
  /// profiles outside the SCA range.
  ///
  /// A bean only counts with at least one live pack or some consumption. A
  /// gap is an error if no ready coffee is left, else a warning.
  List<AppWarning> get warnings {
    final relevant = [
      for (final b in beans)
        if (packsOf(b.id).isNotEmpty || (consumptionOf(b.id) ?? 0) > 0) b,
    ];
    final result = <AppWarning>[];
    for (final b in relevant) {
      final gap = gapWarning(b.id);
      if (gap == null) continue;
      result.add(
        AppWarning(
          kind: WarningKind.gap,
          severity: gap.readyStockG <= 0
              ? WarningSeverity.error
              : WarningSeverity.warning,
          bean: b,
          gap: gap,
        ),
      );
    }
    for (final b in relevant) {
      final stock = stockStatus(b.id);
      if (!stock.orderNow) continue;
      result.add(
        AppWarning(
          kind: WarningKind.order,
          severity: WarningSeverity.warning,
          bean: b,
          stock: stock,
        ),
      );
    }
    for (final CareTask t in careTasks) {
      if (!t.due) continue;
      result.add(
        AppWarning(
          kind: WarningKind.careDue,
          severity: WarningSeverity.warning,
          care: t,
        ),
      );
    }
    for (final w in waterProfiles) {
      if (checker.assess(w).inScaRange) continue;
      result.add(
        AppWarning(
          kind: WarningKind.water,
          severity: WarningSeverity.warning,
          water: w,
        ),
      );
    }
    return result;
  }
}
