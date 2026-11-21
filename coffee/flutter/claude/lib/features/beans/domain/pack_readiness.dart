/// Readiness of a pack for brewing.
enum ReadinessStatus {
  /// Rested long enough and not yet stale.
  ready,

  /// Still resting.
  resting,

  /// Older than the stale limit.
  tooOld,
}

/// Result of [RestCalculator.readiness].
class PackReadiness {
  /// Creates a result.
  const PackReadiness({
    required this.status,
    required this.readyDate,
    required this.staleDate,
    required this.daysLeft,
  });

  /// Current status.
  final ReadinessStatus status;

  /// First day the pack is ready (date-only, UTC).
  final DateTime readyDate;

  /// First day the pack counts as too old (date-only, UTC).
  final DateTime staleDate;

  /// Days until ready; 0 when ready or too old.
  final int daysLeft;
}
