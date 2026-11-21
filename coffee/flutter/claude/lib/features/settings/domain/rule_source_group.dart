import '../../../core/rules/rule_entry.dart';

/// The rule entries of one asset file, for the sources list.
class RuleSourceGroup {
  /// Creates a group for [asset] holding [entries].
  const RuleSourceGroup({required this.asset, required this.entries});

  /// Asset path, e.g. `assets/water_rules.json`.
  final String asset;

  /// Entries in file order.
  final List<RuleEntry> entries;
}
