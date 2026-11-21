import 'rule_entry.dart';

/// Immutable collection of [RuleEntry] with lookup by key.
class RuleSet {
  /// Creates a set from [entries].
  RuleSet(List<RuleEntry> entries)
    : entries = List.unmodifiable(entries),
      _byKey = {for (final e in entries) e.key: e};

  /// All entries in file order.
  final List<RuleEntry> entries;

  final Map<String, RuleEntry> _byKey;

  /// Returns the entry for [key], or null if absent.
  RuleEntry? maybeEntry(String key) => _byKey[key];

  /// Returns the entry for [key]; throws [ArgumentError] if absent.
  RuleEntry entry(String key) {
    final found = _byKey[key];
    if (found == null) throw ArgumentError.value(key, 'key', 'Unknown rule');
    return found;
  }

  /// Returns the numeric value of [key]; throws if not a number.
  num number(String key) {
    final value = entry(key).value;
    if (value is! num) {
      throw FormatException('Rule $key is not a number', value);
    }
    return value;
  }
}
