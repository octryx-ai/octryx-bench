/// Why [AppData.addBrew] refused a brew.
enum BrewFailure {
  /// Grinder unknown or deleted.
  noGrinder,

  /// Espresso without a live machine.
  noMachine,

  /// Not enough beans left in the pack.
  notEnoughBeans,

  /// Pack unknown or deleted.
  packMissing,

  /// Drawdown time outside 1..600 s.
  invalidDrawdown,
}

/// Thrown when a brew cannot be saved.
class BrewException implements Exception {
  /// Creates an exception; [remainingG] is set for
  /// [BrewFailure.notEnoughBeans].
  const BrewException(this.failure, {this.remainingG});

  /// The reason.
  final BrewFailure failure;

  /// Grams left in the pack, if relevant.
  final double? remainingG;

  @override
  String toString() => 'BrewException($failure, remainingG: $remainingG)';
}
