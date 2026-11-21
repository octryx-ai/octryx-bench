/// Brewing method of a [Brew] (SPEC section 3).
enum BrewMethod {
  /// Espresso machine shot.
  espresso('espresso'),

  /// Hario V60.
  v60('v60'),

  /// Chemex.
  chemex('chemex'),

  /// Kalita Wave.
  kalita('kalita'),

  /// AeroPress.
  aeropress('aeropress'),

  /// Batch brewer.
  batch('batch');

  const BrewMethod(this.code);

  /// Stable code used in JSON.
  final String code;

  /// Whether this is an espresso shot.
  bool get isEspresso => this == BrewMethod.espresso;

  /// Whether this is a filter method (everything except espresso).
  bool get isFilter => this != BrewMethod.espresso;

  /// Parses [code]; throws [FormatException] if unknown.
  static BrewMethod parse(String code) => values.firstWhere(
    (v) => v.code == code,
    orElse: () => throw FormatException('Unknown brew method', code),
  );
}
