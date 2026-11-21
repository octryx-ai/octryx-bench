import '../../../core/format/app_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/domain/hardness_unit.dart';
import '../domain/water_parameter.dart';
import '../domain/water_range.dart';

/// Texts and units of water values; numbers always use a decimal point.
abstract final class WaterFormat {
  static const _axisBase = {
    WaterParameter.tds: 500.0,
    WaterParameter.hardness: 400.0,
    WaterParameter.alkalinity: 150.0,
    WaterParameter.ph: 14.0,
    WaterParameter.sodium: 50.0,
    WaterParameter.chlorine: 5.0,
  };

  static const _axisHeadroom = 1.1;

  /// Display name of [p].
  static String label(AppLocalizations l, WaterParameter p) => switch (p) {
    WaterParameter.tds => l.paramTds,
    WaterParameter.hardness => l.paramHardness,
    WaterParameter.alkalinity => l.paramAlkalinity,
    WaterParameter.ph => l.paramPh,
    WaterParameter.sodium => l.paramSodium,
    WaterParameter.chlorine => l.paramChlorine,
  };

  /// Name of [p] inside a sentence: English lowercases common nouns (not TDS
  /// or pH); German nouns keep their capital.
  static String inlineLabel(AppLocalizations l, WaterParameter p) {
    final name = label(l, p);
    final keepCase =
        l.localeName == 'de' ||
        p == WaterParameter.tds ||
        p == WaterParameter.ph;
    return keepCase ? name : name.toLowerCase();
  }

  /// Unit of [p] (hardness in ppm); empty for pH.
  static String unit(AppLocalizations l, WaterParameter p) => switch (p) {
    WaterParameter.tds ||
    WaterParameter.sodium ||
    WaterParameter.chlorine => l.unitMgL,
    WaterParameter.hardness || WaterParameter.alkalinity => l.unitPpm,
    WaterParameter.ph => '',
  };

  /// [value] of [p] with its unit, e.g. `300 ppm` or `7.2`.
  static String value(AppLocalizations l, WaterParameter p, double value) =>
      '${AppFormat.plain(value)} ${unit(l, p)}'.trim();

  /// SCA range of [p], e.g. `50–175 ppm`, `≤ 10 mg/L` or `0 mg/L`.
  static String range(AppLocalizations l, WaterParameter p, WaterRange r) {
    final min = r.min;
    final max = r.max;
    final u = unit(l, p);
    final String text;
    if (min != null && max != null) {
      text = '${AppFormat.plain(min)}–${AppFormat.plain(max)}';
    } else if (max != null) {
      text = max == 0 ? '0' : '≤ ${AppFormat.plain(max)}';
    } else if (min != null) {
      text = '≥ ${AppFormat.plain(min)}';
    } else {
      text = '';
    }
    return '$text $u'.trim();
  }

  /// Symbol of a hardness [unit]: `°fH`, `°dH` or `ppm`.
  static String hardnessUnit(AppLocalizations l, HardnessUnit unit) =>
      switch (unit) {
        HardnessUnit.fH => l.unitFh,
        HardnessUnit.dH => l.unitDh,
        HardnessUnit.ppm => l.unitPpm,
      };

  /// Hardness [ppm] in [unit]: `30.0 °fH`, `8.4 °dH` or `300 ppm`.
  static String hardness(AppLocalizations l, HardnessUnit unit, double ppm) {
    final shown = unit.displayValue(ppm);
    final number = unit == HardnessUnit.ppm
        ? AppFormat.plain(shown)
        : shown.toStringAsFixed(1);
    return '$number ${hardnessUnit(l, unit)}';
  }

  /// Upper end of the bar axis of [p] that still shows [value].
  static double axisMax(WaterParameter p, double? value) {
    final base = _axisBase[p]!;
    final needed = (value ?? 0) * _axisHeadroom;
    return needed > base ? needed : base;
  }
}
