import '../../../core/rules/rule_asset_loader.dart';
import '../../../core/rules/rule_source.dart';
import '../domain/rule_source_group.dart';

/// Loads every rule asset file (water, rest, care, brew) for the sources list.
class RuleSourcesLoader {
  /// Creates a loader reading from [source].
  const RuleSourcesLoader(this.source);

  /// Asset files in display order.
  static const List<String> assets = [
    'assets/water_rules.json',
    'assets/rest_rules.json',
    'assets/care_rules.json',
    'assets/brew_rules.json',
  ];

  /// Where asset text comes from.
  final RuleSource source;

  /// Loads all groups; throws [FormatException] for an invalid asset.
  Future<List<RuleSourceGroup>> load() async {
    final loader = RuleAssetLoader(source);
    return [
      for (final asset in assets)
        RuleSourceGroup(asset: asset, entries: await loader.load(asset)),
    ];
  }
}
