/// Why a brew form field is invalid.
enum BrewFieldError {
  /// Dose is missing.
  doseRequired,

  /// Dose outside 5..40 g.
  doseOutOfRange,

  /// Yield is missing.
  yieldRequired,

  /// Yield outside 1 to 4 times the dose.
  yieldOutOfRange,

  /// Shot time is missing.
  shotTimeRequired,

  /// Shot time outside 1..120 s.
  shotTimeOutOfRange,

  /// Rating outside 1..5.
  ratingOutOfRange,

  /// Grind setting is missing.
  grindRequired,

  /// Purge amount outside 0..50 g.
  purgeOutOfRange,

  /// Drawdown time is missing.
  drawdownRequired,

  /// Drawdown time outside 1..600 s.
  drawdownOutOfRange,
}
