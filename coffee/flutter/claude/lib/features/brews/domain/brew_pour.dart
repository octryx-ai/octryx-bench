/// One pour of a filter brew: cumulative water at a time.
class BrewPour {
  /// Creates a pour.
  const BrewPour({required this.atS, required this.cumulativeG});

  /// Reads a pour written by [toJson].
  factory BrewPour.fromJson(Map<String, Object?> json) => BrewPour(
    atS: (json['atS']! as num).toInt(),
    cumulativeG: (json['cumulativeG']! as num).toDouble(),
  );

  /// Seconds since brew start.
  final int atS;

  /// Total water poured so far, in grams.
  final double cumulativeG;

  /// Serialises the pour.
  Map<String, Object?> toJson() => {'atS': atS, 'cumulativeG': cumulativeG};

  @override
  bool operator ==(Object other) =>
      other is BrewPour && other.atS == atS && other.cumulativeG == cumulativeG;

  @override
  int get hashCode => Object.hash(atS, cumulativeG);
}
