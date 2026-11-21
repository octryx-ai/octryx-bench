/// Immutable base of all persisted records (SPEC section 3).
///
/// Dates are UTC; JSON uses ISO-8601 with millisecond precision.
abstract class BaseRecord {
  /// Creates a record; [createdAt], [updatedAt] and [deletedAt] must be UTC.
  const BaseRecord({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Stable UUIDv4 identifier.
  final String id;

  /// Creation instant (UTC).
  final DateTime createdAt;

  /// Last modification instant (UTC).
  final DateTime updatedAt;

  /// Soft-delete instant (UTC), or null if the record is live.
  final DateTime? deletedAt;

  /// Whether the record has been soft-deleted.
  bool get isDeleted => deletedAt != null;

  /// Returns a copy with the given base fields replaced.
  BaseRecord copyWithBase({DateTime? updatedAt, DateTime? deletedAt});

  /// Serialises the subclass specific fields.
  Map<String, Object?> toExtraJson() => const {};

  /// Serialises all fields including the base fields.
  Map<String, Object?> toJson() => {
    'id': id,
    'createdAt': formatTimestamp(createdAt),
    'updatedAt': formatTimestamp(updatedAt),
    'deletedAt': deletedAt == null ? null : formatTimestamp(deletedAt!),
    ...toExtraJson(),
  };

  /// Formats [value] as UTC ISO-8601 with milliseconds, e.g.
  /// `2026-11-16T08:30:00.123Z`.
  static String formatTimestamp(DateTime value) {
    final utc = value.toUtc();
    return DateTime.utc(
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second,
      utc.millisecond,
    ).toIso8601String();
  }

  /// Parses a timestamp written by [formatTimestamp]; result is UTC.
  static DateTime parseTimestamp(Object? value) {
    if (value is! String) {
      throw FormatException('Timestamp must be a string', value);
    }
    return DateTime.parse(value).toUtc();
  }

  /// Parses an optional timestamp; null stays null.
  static DateTime? parseOptionalTimestamp(Object? value) =>
      value == null ? null : parseTimestamp(value);
}
