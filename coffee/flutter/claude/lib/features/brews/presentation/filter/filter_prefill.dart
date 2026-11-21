import '../../../../app/app_data.dart';
import '../../domain/brew.dart';
import '../../domain/brew_method.dart';
import '../../domain/recommendation.dart';

/// Starting values of the filter setup: first live grinder, pack and water
/// profile with the default dose and ratio, or the values of a [source] brew
/// ("Next try") whose grind setting follows its recommendation.
class FilterPrefill {
  /// Resolves the values for [source], which may be null.
  FilterPrefill(AppData data, Brew? source)
    : method = source != null && source.method.isFilter
          ? source.method
          : BrewMethod.v60,
      grinderId = _live([
        for (final g in data.grinders) g.id,
      ], source?.grinderId),
      packId = _live([
        for (final s in data.filterPackSuggestions()) s.pack.id,
      ], source?.packId),
      waterId = _live([
        for (final w in data.waterProfiles) w.id,
      ], source?.waterProfileId),
      dose = source?.doseG ?? _defaultDose,
      ratio = _ratio(data, source),
      grind = source == null || !source.method.isFilter
          ? null
          : _grind(data, source);

  static const double _defaultDose = 20;

  /// Method to preselect.
  final BrewMethod method;

  /// Grinder to preselect, or null if none exists.
  final String? grinderId;

  /// Pack to preselect, or null if none is ready.
  final String? packId;

  /// Water profile to preselect, or null if none exists.
  final String? waterId;

  /// Dose in grams.
  final double dose;

  /// Ratio (water per gram coffee).
  final double ratio;

  /// Grind setting, or null to start at the grinder's scale minimum.
  final double? grind;

  static String? _live(List<String> ids, String? wanted) =>
      ids.contains(wanted) ? wanted : ids.firstOrNull;

  static double _ratio(AppData data, Brew? source) {
    final calc = data.filterRecipes;
    final water = source?.waterTotalG;
    if (source == null || water == null || source.doseG <= 0) {
      return calc.defaultRatio;
    }
    return calc.normalizeRatio(water / source.doseG);
  }

  static double _grind(AppData data, Brew source) {
    final rec = data.recommendFor(source);
    final changed =
        rec.variable == RecommendationVariable.grind && rec.newSetting != null;
    return changed ? rec.newSetting! : source.grindSetting;
  }
}
