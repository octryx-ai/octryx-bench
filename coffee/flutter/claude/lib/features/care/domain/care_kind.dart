/// Kind of machine or grinder care (SPEC R8).
enum CareKind {
  /// Backflush the espresso machine.
  backflush,

  /// Descale the espresso machine.
  descale,

  /// Clean the grinder.
  grinderClean;

  /// Stable code used for persistence.
  String get code => name;

  /// Parses a [code]; throws [ArgumentError] if unknown.
  static CareKind parse(String code) => values.firstWhere(
    (k) => k.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unknown care kind'),
  );
}
