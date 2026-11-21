/// One data-driven rule value with its source (SPEC sections 5 and 6).
class RuleEntry {
  /// Creates a rule entry.
  const RuleEntry({
    required this.key,
    required this.value,
    required this.source,
    required this.retrieved,
  });

  /// Unique rule key, e.g. `rest.espresso.medium`.
  final String key;

  /// Rule value (number, string, ...).
  final Object? value;

  /// Source URL, or `none` for a default value without a researched source.
  final String source;

  /// Date the source was retrieved (`YYYY-MM-DD`).
  final String retrieved;

  /// Whether a researched source exists.
  bool get hasSource => source != 'none';
}
