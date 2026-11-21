/// Why purging the grinder is advised.
enum PurgeReason {
  /// The previous brew on this grinder used another bean.
  beanChange,

  /// The grinder has been idle for a long time.
  idle,
}

/// Advice to purge the grinder before dosing.
class PurgeAdvice {
  /// Creates advice.
  const PurgeAdvice({required this.reason, required this.purgeG});

  /// Why.
  final PurgeReason reason;

  /// Suggested purge amount in grams (the grinder's dead space).
  final double purgeG;
}
