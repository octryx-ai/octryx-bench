import '../../beans/domain/bean.dart';
import '../../beans/domain/pack.dart';
import '../../beans/domain/pack_readiness.dart';
import '../../beans/domain/rest_calculator.dart';
import 'gap_action.dart';
import 'gap_warning.dart';

/// Finds the gap between running out and the next ready coffee (SPEC R6).
class GapCalculator {
  /// Creates a calculator using [rest] for readiness.
  const GapCalculator(this.rest);

  /// Resting and stale dates.
  final RestCalculator rest;

  /// The gap of [bean] on [today] or null if there is none.
  ///
  /// Needs a positive [consumptionPerDay]. Ready stock B lasts until
  /// `today + floor(B / consumption) - 1`; the next ready day is the earliest
  /// resting pack, else `today + leadTime + restDays` (a new order). A gap
  /// exists if that day is later than the day after running out.
  GapWarning? gap({
    required Bean bean,
    required Iterable<Pack> packs,
    required double consumptionPerDay,
    required DateTime today,
  }) {
    if (consumptionPerDay <= 0) return null;
    final now = RestCalculator.dateOnly(today);
    final ready = <Pack>[];
    DateTime? nextReady;
    var stock = 0.0;
    for (final p in packs) {
      if (p.isDeleted) continue;
      final r = rest.readiness(p, bean, now);
      switch (r.status) {
        case ReadinessStatus.ready:
          ready.add(p);
          stock += p.remainingG;
        case ReadinessStatus.resting:
          if (nextReady == null || r.readyDate.isBefore(nextReady)) {
            nextReady = r.readyDate;
          }
        case ReadinessStatus.tooOld:
          break;
      }
    }
    final days = (stock / consumptionPerDay).floor();
    final firstEmpty = DateTime.utc(now.year, now.month, now.day + days);
    final restDays = rest.restDays(bean.kind.restMethod, bean.roastLevel);
    final next =
        nextReady ??
        DateTime.utc(
          now.year,
          now.month,
          now.day + bean.leadTimeDays + restDays,
        );
    if (!next.isAfter(firstEmpty)) return null;
    final last = DateTime.utc(next.year, next.month, next.day - 1);
    final x = _sealed(ready);
    final openReady = ready.any((p) => p.openedAt != null && p.remainingG > 0);
    return GapWarning(
      from: firstEmpty,
      to: last,
      days: last.difference(firstEmpty).inDays + 1,
      action: x != null && !openReady ? GapAction.openPack : GapAction.orderNow,
      pack: x != null && !openReady ? x : null,
      readyStockG: stock,
    );
  }

  Pack? _sealed(List<Pack> ready) {
    Pack? best;
    for (final p in ready) {
      if (p.openedAt != null || p.remainingG <= 0) continue;
      if (best == null || p.roastDate.isBefore(best.roastDate)) best = p;
    }
    return best;
  }
}
