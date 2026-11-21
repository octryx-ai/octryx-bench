/// Minimal source of asset text, compatible with Flutter's `AssetBundle`.
abstract class RuleSource {
  /// Loads the text of [assetName] (e.g. `assets/water_rules.json`).
  Future<String> loadString(String assetName);
}
