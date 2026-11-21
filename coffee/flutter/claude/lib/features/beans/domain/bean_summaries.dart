import 'bean.dart';
import 'bean_summary.dart';
import 'pack.dart';
import 'pack_readiness.dart';
import 'rest_calculator.dart';

/// Builds the sorted bean list of SPEC R3.
class BeanSummaries {
  const BeanSummaries._();

  /// Summaries of [beans] with their [packs], earliest ready date first;
  /// beans without packs last; ties by lowercase name.
  static List<BeanSummary> build({
    required List<Bean> beans,
    required List<Pack> packs,
    required RestCalculator calc,
    required DateTime today,
  }) {
    final result = [
      for (final b in beans)
        _one(
          b,
          packs.where((p) => p.beanId == b.id && !p.isDeleted).toList(),
          calc,
          today,
        ),
    ];
    result.sort((a, b) {
      final x = a.earliestReadyDate;
      final y = b.earliestReadyDate;
      if (x != null && y != null) {
        final c = x.compareTo(y);
        if (c != 0) return c;
      } else if (x != null || y != null) {
        return x == null ? 1 : -1;
      }
      return a.bean.name.toLowerCase().compareTo(b.bean.name.toLowerCase());
    });
    return result;
  }

  static BeanSummary _one(
    Bean bean,
    List<Pack> packs,
    RestCalculator calc,
    DateTime today,
  ) {
    packs.sort((a, b) => a.roastDate.compareTo(b.roastDate));
    final r = [for (final p in packs) (p, calc.readiness(p, bean, today))];
    final fresh = r.where((e) => e.$2.status != ReadinessStatus.tooOld);
    var total = 0.0;
    for (final e in fresh) {
      total += e.$1.remainingG;
    }
    PackReadiness? best;
    for (final e in (fresh.isEmpty ? r : fresh)) {
      if (best == null || e.$2.readyDate.isBefore(best.readyDate)) best = e.$2;
    }
    DateTime? earliest;
    for (final e in r) {
      if (earliest == null || e.$2.readyDate.isBefore(earliest)) {
        earliest = e.$2.readyDate;
      }
    }
    return BeanSummary(
      bean: bean,
      packs: List.unmodifiable(packs),
      totalRemainingG: total,
      earliestReadyDate: earliest,
      bestReadiness: best,
    );
  }
}
