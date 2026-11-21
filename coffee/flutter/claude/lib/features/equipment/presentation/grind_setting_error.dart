import '../../../core/format/app_format.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/grinder.dart';
import '../domain/grinder_scale.dart';

/// Localized error for grind setting [value] on [grinder]'s scale, or null if
/// it is on the scale (SPEC section 5). Out of range and off-step values give
/// the same text; the step is printed with a decimal point.
String? grindSettingErrorText(
  AppLocalizations l,
  Grinder grinder,
  double value,
) {
  if (GrinderScale.validate(grinder, value) == null) return null;
  return l.grindSettingNotOnScale(AppFormat.plain(grinder.scaleStep));
}
