import '../../../core/format/app_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../equipment/domain/grinder.dart';
import '../../equipment/presentation/grind_setting_error.dart';
import '../domain/brew_validation.dart';
import 'brew_format.dart';

/// Parsed and checked texts of the brew form.
class BrewFormInput {
  /// Parses the field texts for [grinder]'s scale.
  BrewFormInput({
    required this.grinder,
    required String grind,
    required String dose,
    required String yieldG,
    required String purge,
    required String shot,
  }) : grind = AppFormat.parse(grind),
       dose = AppFormat.parse(dose),
       yieldG = AppFormat.parse(yieldG),
       purge = purge.trim().isEmpty ? 0.0 : AppFormat.parse(purge),
       shot = _wholeSeconds(shot);

  /// Grinder whose scale applies to [grind].
  final Grinder grinder;

  /// Grind setting, or null if not a number.
  final double? grind;

  /// Dose in grams, or null.
  final double? dose;

  /// Yield in grams, or null.
  final double? yieldG;

  /// Purge in grams (empty means 0), or null if not a number.
  final double? purge;

  /// Shot time in whole seconds; 0 marks an unusable text, null an empty one.
  final int? shot;

  static int? _wholeSeconds(String text) {
    final v = AppFormat.parse(text);
    if (v == null) return text.trim().isEmpty ? null : 0;
    return v == v.roundToDouble() ? v.toInt() : 0;
  }

  /// Error lines by field key (`grind`, `dose`, `yield`, `shot`, `purge`);
  /// empty if everything is valid.
  Map<String, String> errors(AppLocalizations l) {
    final g = grind;
    final grindError = g == null
        ? l.grindSettingNotOnScale(AppFormat.plain(grinder.scaleStep))
        : grindSettingErrorText(l, grinder, g);
    final checks = {
      'dose': BrewValidation.validateDose(dose),
      'yield': BrewValidation.validateYield(yieldG, dose),
      'shot': BrewValidation.validateShotTime(shot, required: true),
      'purge': BrewValidation.validatePurge(purge ?? -1),
    };
    return {
      'grind': ?grindError,
      for (final e in checks.entries)
        if (e.value != null) e.key: BrewFormat.error(l, e.value!, dose: dose),
    };
  }
}
