import '../domain/hardness_unit.dart';

/// User settings.
class AppSettings {
  /// Creates settings; hardness defaults to French degrees.
  const AppSettings({this.hardnessUnit = HardnessUnit.fH});

  /// Unit for displaying water hardness.
  final HardnessUnit hardnessUnit;

  /// Returns a copy with the given fields replaced.
  AppSettings copyWith({HardnessUnit? hardnessUnit}) =>
      AppSettings(hardnessUnit: hardnessUnit ?? this.hardnessUnit);
}
