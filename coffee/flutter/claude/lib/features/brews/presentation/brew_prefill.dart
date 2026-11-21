import '../../../app/app_data.dart';
import '../../../core/format/app_format.dart';
import '../domain/brew.dart';
import '../domain/recommendation.dart';
import 'brew_format.dart';

/// Starting values of the brew form: the first live machine, grinder and pack,
/// or those of a [source] brew ("Next try") with its field texts.
class BrewPrefill {
  /// Resolves the values for [source], which may be null.
  BrewPrefill(AppData data, Brew? source)
    : machineId = _live([
        for (final m in data.machines) m.id,
      ], source?.machineId),
      grinderId = _live([
        for (final g in data.grinders) g.id,
      ], source?.grinderId),
      packId = _live([for (final p in data.packs) p.id], source?.packId),
      grind = source == null ? null : _grind(data, source),
      dose = source == null ? null : AppFormat.plain(source.doseG),
      purge = source == null ? null : AppFormat.plain(source.purgeG),
      yieldG = source?.yieldG == null ? null : AppFormat.plain(source!.yieldG!);

  /// Machine to preselect, or null if none exists.
  final String? machineId;

  /// Grinder to preselect, or null if none exists.
  final String? grinderId;

  /// Pack to preselect, or null if none exists.
  final String? packId;

  /// Grind setting text (the recommended one if it changes the grind).
  final String? grind;

  /// Dose text.
  final String? dose;

  /// Purge text.
  final String? purge;

  /// Yield text, or null if the source had none.
  final String? yieldG;

  /// Default water profile of machine [machineId] if it still exists.
  static String? machineWater(AppData data, String? machineId) {
    final id = machineId == null
        ? null
        : data.machineById(machineId)?.defaultWaterProfileId;
    return data.waterProfiles.any((w) => w.id == id) ? id : null;
  }

  static String? _live(List<String> ids, String? wanted) =>
      ids.contains(wanted) ? wanted : ids.firstOrNull;

  static String _grind(AppData data, Brew source) {
    final rec = data.recommendFor(source);
    final changed =
        rec.variable == RecommendationVariable.grind && rec.newSetting != null;
    return BrewFormat.setting(changed ? rec.newSetting! : source.grindSetting);
  }
}
