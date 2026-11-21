/// Roast level of a bean (SPEC section 3).
enum RoastLevel {
  /// Light roast.
  light('light', 1),

  /// Medium roast.
  medium('medium', 2),

  /// Medium-dark roast.
  mediumDark('mediumDark', 3),

  /// Dark roast.
  dark('dark', 4);

  const RoastLevel(this.code, this.dots);

  /// Stable code used in JSON and rule keys.
  final String code;

  /// Number of dots (1 to 4) drawn for this level.
  final int dots;

  /// Parses [code]; throws [FormatException] if unknown.
  static RoastLevel parse(String code) => values.firstWhere(
    (v) => v.code == code,
    orElse: () => throw FormatException('Unknown roast level', code),
  );
}
