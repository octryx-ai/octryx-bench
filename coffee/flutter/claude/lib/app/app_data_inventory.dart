import 'package:flutter/foundation.dart';

import '../features/beans/domain/bean_summary.dart';
import '../features/beans/domain/bean_summaries.dart';
import '../features/beans/domain/pack_readiness.dart';
import '../features/brews/domain/brew.dart';
import '../features/inventory/domain/gap_calculator.dart';
import '../features/inventory/domain/gap_warning.dart';
import '../features/inventory/domain/stock_calculator.dart';
import '../features/inventory/domain/stock_status.dart';
import 'app_data_brews.dart';

/// Inventory part of `AppData`: consumption, order point, gaps (SPEC R4-R6)
/// and the "ready now" list of the Today screen.
mixin AppDataInventory on ChangeNotifier, AppDataBrews {
  /// Stock calculator (R4, R5).
  late final StockCalculator stockCalculator = StockCalculator(rest);

  /// Gap calculator (R6).
  late final GapCalculator gapCalculator = GapCalculator(rest);

  /// Live brews that used a pack of bean [beanId] (the pack may have been
  /// deleted since).
  List<Brew> brewsOfBean(String beanId) => [
    for (final b in brews)
      if (packById(b.packId)?.beanId == beanId) b,
  ];

  /// Average grams per day of bean [beanId] over the last 28 days, or null
  /// if the bean is unknown.
  double? consumptionOf(String beanId) => beanById(beanId) == null
      ? null
      : stockCalculator.consumptionPerDay(brewsOfBean(beanId), today);

  /// Stock status of bean [beanId]; the bean must exist.
  StockStatus stockStatus(String beanId) => stockCalculator.status(
    bean: beanById(beanId)!,
    packs: packsOf(beanId),
    brews: brewsOfBean(beanId),
    today: today,
  );

  /// The coming gap of bean [beanId], or null (also without consumption).
  GapWarning? gapWarning(String beanId) {
    final bean = beanById(beanId);
    if (bean == null) return null;
    return gapCalculator.gap(
      bean: bean,
      packs: packsOf(beanId),
      consumptionPerDay: consumptionOf(beanId)!,
      today: today,
    );
  }

  /// Beans with at least one ready pack, earliest ready date among the
  /// ready packs first (ties by lowercase name).
  List<BeanSummary> get readyNowSummaries {
    DateTime? earliest(BeanSummary s) {
      DateTime? best;
      for (final p in s.packs) {
        final r = rest.readiness(p, s.bean, today);
        if (r.status != ReadinessStatus.ready) continue;
        if (best == null || r.readyDate.isBefore(best)) best = r.readyDate;
      }
      return best;
    }

    final entries =
        [
          for (final s in BeanSummaries.build(
            beans: beans,
            packs: packs,
            calc: rest,
            today: today,
          ))
            (s, earliest(s)),
        ].where((e) => e.$2 != null).toList()..sort((a, b) {
          final c = a.$2!.compareTo(b.$2!);
          return c != 0
              ? c
              : a.$1.bean.name.toLowerCase().compareTo(
                  b.$1.bean.name.toLowerCase(),
                );
        });
    return [for (final e in entries) e.$1];
  }

  /// The newest live brew, or null.
  Brew? get lastBrew => brews.isEmpty ? null : brews.first;
}
