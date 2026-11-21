import 'bean.dart';
import 'pack.dart';
import 'pack_readiness.dart';

/// A bean with its live packs and derived stock and readiness (SPEC R3).
class BeanSummary {
  /// Creates a summary.
  const BeanSummary({
    required this.bean,
    required this.packs,
    required this.totalRemainingG,
    this.earliestReadyDate,
    this.bestReadiness,
  });

  /// The bean.
  final Bean bean;

  /// Live packs sorted by roast date.
  final List<Pack> packs;

  /// Remaining grams over all live packs that are not too old.
  final double totalRemainingG;

  /// Earliest ready date among live packs, or null without packs.
  final DateTime? earliestReadyDate;

  /// Readiness of the pack with the earliest ready date among packs that are
  /// not too old; a too-old result if all are; null without packs.
  final PackReadiness? bestReadiness;
}
