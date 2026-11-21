import 'water_profile.dart';

/// Water parameters assessed against the SCA range (SPEC R2).
enum WaterParameter {
  /// Total dissolved solids.
  tds('tds'),

  /// Total hardness.
  hardness('hardness'),

  /// Alkalinity.
  alkalinity('alkalinity'),

  /// pH value.
  ph('ph'),

  /// Sodium.
  sodium('sodium'),

  /// Chlorine.
  chlorine('chlorine');

  const WaterParameter(this.ruleKey);

  /// Key prefix in `water_rules.json` (`<ruleKey>.min|max|target`).
  final String ruleKey;

  /// The measured value of this parameter in [p], or null if not measured.
  double? valueOf(WaterProfile p) => switch (this) {
    WaterParameter.tds => p.tdsPpm,
    WaterParameter.hardness => p.hardnessPpm,
    WaterParameter.alkalinity => p.alkalinityPpm,
    WaterParameter.ph => p.ph,
    WaterParameter.sodium => p.sodiumMgL,
    WaterParameter.chlorine => p.chlorineMgL,
  };
}
