/// Unit in which water hardness is displayed; storage is always ppm.
enum HardnessUnit {
  /// French degrees (1 fH = 10 ppm).
  fH,

  /// German degrees (1 dH = 17.848 ppm).
  dH,

  /// Parts per million CaCO3.
  ppm;

  double get _factor => switch (this) {
    HardnessUnit.fH => 10,
    HardnessUnit.dH => 17.848,
    HardnessUnit.ppm => 1,
  };

  /// Converts [v] in this unit to ppm (unrounded).
  double toPpm(double v) => v * _factor;

  /// Converts [ppm] to this unit (unrounded).
  double fromPpm(double ppm) => ppm / _factor;

  /// [ppm] in this unit, rounded half-up to one decimal.
  double displayValue(double ppm) => (fromPpm(ppm) * 10).round() / 10;

  /// Stable code used for persistence: `fH`, `dH` or `ppm`.
  String get code => name;

  /// Parses a [code]; throws [ArgumentError] if unknown.
  static HardnessUnit parse(String code) => values.firstWhere(
    (u) => u.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unknown unit'),
  );
}
