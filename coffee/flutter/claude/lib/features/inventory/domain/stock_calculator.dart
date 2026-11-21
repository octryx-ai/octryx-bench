import '../../beans/domain/bean.dart';
import '../../beans/domain/pack.dart';
import '../../beans/domain/pack_readiness.dart';
import '../../beans/domain/rest_calculator.dart';
import '../../brews/domain/brew.dart';
import 'stock_status.dart';

/// Computes consumption, order point and stock reach (SPEC R4, R5).
class StockCalculator {
  /// Creates a calculator using [rest] for resting and stale dates.
  const StockCalculator(this.rest);

  /// Length of the consumption window in days.
  static const int windowDays = 28;

  /// Minimum stock if neither the bean nor the consumption gives one.
  static const double defaultMinStockG = 100;

  /// Resting and stale dates.
  final RestCalculator rest;

  /// Average daily use: dose plus purge of [brews] started from `today - 27`
  /// to `today` (local calendar days, both inclusive) divided by 28, not
  /// rounded. The caller passes live brews of the bean's packs.
  double consumptionPerDay(Iterable<Brew> brews, DateTime today) {
    final from = RestCalculator.dateOnly(today)
        .subtract(const Duration(days: windowDays - 1));
    final to = RestCalculator.dateOnly(today);
    var sum = 0.0;
    for (final b in brews) {
      final day = RestCalculator.dateOnly(b.startedAt.toLocal());
      if (day.isBefore(from) || day.isAfter(to)) continue;
      sum += b.doseG + b.purgeG;
    }
    return sum / windowDays;
  }

  /// Status of [bean] on [today]; [packs] are its live packs and [brews]
  /// the live brews of any of its packs.
  StockStatus status({
    required Bean bean,
    required Iterable<Pack> packs,
    required Iterable<Brew> brews,
    required DateTime today,
  }) {
    final c = consumptionPerDay(brews, today);
    final minStock = bean.minStockG ?? (c == 0 ? defaultMinStockG : 2 * c);
    final restDays = rest.restDays(bean.kind.restMethod, bean.roastLevel);
    final orderPoint = c * (bean.leadTimeDays + restDays) + minStock;
    var total = 0.0;
    for (final p in packs) {
      if (p.isDeleted) continue;
      if (rest.readiness(p, bean, today).status == ReadinessStatus.tooOld) {
        continue;
      }
      total += p.remainingG;
    }
    return StockStatus(
      consumptionPerDay: c,
      minStockG: minStock,
      orderPoint: orderPoint,
      totalStockG: total,
      daysOfCover: c == 0 ? null : total / c,
      restDays: restDays,
      orderNow: total <= orderPoint,
    );
  }
}
