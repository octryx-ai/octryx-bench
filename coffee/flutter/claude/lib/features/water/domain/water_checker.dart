import '../../../core/rules/rule_asset_loader.dart';
import '../../../core/rules/rule_set.dart';
import '../../../core/rules/rule_source.dart';
import 'parameter_result.dart';
import 'water_assessment.dart';
import 'water_parameter.dart';
import 'water_profile.dart';
import 'water_range.dart';

/// Checks water profiles against ranges from `assets/water_rules.json`.
class WaterChecker {
  /// Creates a checker reading `<param>.min|max|target` from [rules];
  /// missing keys mean an open bound.
  WaterChecker(RuleSet rules)
    : _ranges = {
        for (final p in WaterParameter.values) p: _rangeFor(rules, p.ruleKey),
      };

  /// Asset holding the water rules.
  static const String assetName = 'assets/water_rules.json';

  /// Loads the water rules from [source] and builds a checker.
  static Future<WaterChecker> load(RuleSource source) async =>
      WaterChecker(await RuleAssetLoader(source).loadSet(assetName));

  final Map<WaterParameter, WaterRange> _ranges;

  /// The configured range for [p].
  WaterRange rangeOf(WaterParameter p) => _ranges[p]!;

  /// Assesses [profile]; unmeasured parameters never count as violations.
  WaterAssessment assess(WaterProfile profile) => WaterAssessment([
    for (final p in WaterParameter.values)
      ParameterResult(
        parameter: p,
        value: p.valueOf(profile),
        range: _ranges[p]!,
      ),
  ]);

  static WaterRange _rangeFor(RuleSet rules, String key) {
    double? get(String s) => rules.maybeEntry('$key.$s') == null
        ? null
        : rules.number('$key.$s').toDouble();
    return WaterRange(min: get('min'), max: get('max'), target: get('target'));
  }
}
