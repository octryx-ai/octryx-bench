import 'dart:convert';

import 'rule_entry.dart';
import 'rule_set.dart';
import 'rule_source.dart';

/// Loads and validates rule assets (`{"version":1,"rules":[...]}`).
class RuleAssetLoader {
  /// Creates a loader reading from [source].
  const RuleAssetLoader(this.source);

  /// Where asset text comes from.
  final RuleSource source;

  /// Loads [assetName] and returns its entries.
  ///
  /// Throws [FormatException] for malformed JSON, an unsupported version, or
  /// an entry missing `key`, `source` or `retrieved`.
  Future<List<RuleEntry>> load(String assetName) async =>
      parse(await source.loadString(assetName), assetName);

  /// Loads [assetName] as a [RuleSet].
  Future<RuleSet> loadSet(String assetName) async =>
      RuleSet(await load(assetName));

  /// Parses rule JSON [text]; [name] is only used in error messages.
  static List<RuleEntry> parse(String text, [String name = 'rules']) {
    final Object? decoded = jsonDecode(text);
    if (decoded is! Map<String, Object?> || decoded['version'] != 1) {
      throw FormatException('$name: expected object with version 1');
    }
    final rules = decoded['rules'];
    if (rules is! List) {
      throw FormatException('$name: "rules" must be a list');
    }
    final keys = <String>{};
    return [
      for (var i = 0; i < rules.length; i++) _entry(rules[i], i, name, keys),
    ];
  }

  static RuleEntry _entry(Object? raw, int i, String name, Set<String> keys) {
    if (raw is! Map<String, Object?>) {
      throw FormatException('$name: rule #$i is not an object');
    }
    String field(String f) {
      final v = raw[f];
      if (v is! String || v.isEmpty) {
        throw FormatException('$name: rule #$i is missing "$f"');
      }
      return v;
    }

    final key = field('key');
    if (!keys.add(key)) {
      throw FormatException('$name: duplicate key "$key"');
    }
    return RuleEntry(
      key: key,
      value: raw['value'],
      source: field('source'),
      retrieved: field('retrieved'),
    );
  }
}
