/// Taste impression of a brew.
enum Taste {
  /// Sour, under-extracted.
  sour('sour'),

  /// Bitter, over-extracted.
  bitter('bitter'),

  /// Weak, thin.
  weak('weak'),

  /// Balanced.
  balanced('balanced');

  const Taste(this.code);

  /// Stable code used in JSON.
  final String code;

  /// Parses [code]; throws [FormatException] if unknown.
  static Taste parse(String code) => values.firstWhere(
    (v) => v.code == code,
    orElse: () => throw FormatException('Unknown taste', code),
  );
}
