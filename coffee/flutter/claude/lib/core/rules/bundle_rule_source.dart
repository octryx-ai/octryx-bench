import 'package:flutter/services.dart';

import 'rule_source.dart';

/// [RuleSource] reading from a Flutter [AssetBundle] (default: `rootBundle`).
class BundleRuleSource implements RuleSource {
  /// Creates a source for [bundle], or `rootBundle` if null.
  BundleRuleSource([AssetBundle? bundle]) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  @override
  Future<String> loadString(String assetName) => _bundle.loadString(assetName);
}
