import '../../../core/data/base_record.dart';

/// A purchased pack of one bean (SPEC section 3).
class Pack extends BaseRecord {
  /// Creates a pack; [roastDate] is a date-only UTC value.
  const Pack({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.beanId,
    required this.roastDate,
    required this.sizeG,
    required this.remainingG,
    this.openedAt,
  });

  /// Reads a pack written by [toJson].
  factory Pack.fromJson(Map<String, Object?> json) => Pack(
    id: json['id']! as String,
    createdAt: BaseRecord.parseTimestamp(json['createdAt']),
    updatedAt: BaseRecord.parseTimestamp(json['updatedAt']),
    deletedAt: BaseRecord.parseOptionalTimestamp(json['deletedAt']),
    beanId: json['beanId']! as String,
    roastDate: parseDate(json['roastDate']! as String),
    sizeG: (json['sizeG']! as num).toDouble(),
    remainingG: (json['remainingG']! as num).toDouble(),
    openedAt: BaseRecord.parseOptionalTimestamp(json['openedAt']),
  );

  /// Id of the [Bean] this pack belongs to.
  final String beanId;

  /// Roast date (date-only, UTC midnight).
  final DateTime roastDate;

  /// Pack size in grams.
  final double sizeG;

  /// Remaining coffee in grams.
  final double remainingG;

  /// Instant the pack was opened (UTC), or null if sealed.
  final DateTime? openedAt;

  /// Formats [date] as `YYYY-MM-DD`.
  static String formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Parses `YYYY-MM-DD` into a UTC date-only value.
  static DateTime parseDate(String text) {
    final p = DateTime.parse(text);
    return DateTime.utc(p.year, p.month, p.day);
  }

  /// Returns a copy with the given fields replaced; set [clearOpenedAt] to
  /// mark the pack as sealed again.
  Pack copyWith({
    String? beanId,
    DateTime? roastDate,
    double? sizeG,
    double? remainingG,
    DateTime? openedAt,
    bool clearOpenedAt = false,
  }) => Pack(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    beanId: beanId ?? this.beanId,
    roastDate: roastDate ?? this.roastDate,
    sizeG: sizeG ?? this.sizeG,
    remainingG: remainingG ?? this.remainingG,
    openedAt: clearOpenedAt ? null : openedAt ?? this.openedAt,
  );

  @override
  Pack copyWithBase({DateTime? updatedAt, DateTime? deletedAt}) => Pack(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
    beanId: beanId,
    roastDate: roastDate,
    sizeG: sizeG,
    remainingG: remainingG,
    openedAt: openedAt,
  );

  @override
  Map<String, Object?> toExtraJson() => {
    'beanId': beanId,
    'roastDate': formatDate(roastDate),
    'sizeG': sizeG,
    'remainingG': remainingG,
    'openedAt': openedAt == null ? null : BaseRecord.formatTimestamp(openedAt!),
  };
}
