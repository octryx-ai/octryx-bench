import '../../../core/data/base_record.dart';
import 'care_kind.dart';

/// A recorded care action (SPEC section 3, "CareEvent").
class CareEvent extends BaseRecord {
  /// Creates an event; [doneAt] must be UTC.
  const CareEvent({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    this.machineId,
    this.grinderId,
    required this.kind,
    required this.doneAt,
  });

  /// Reads an event written by [toJson].
  factory CareEvent.fromJson(Map<String, Object?> json) => CareEvent(
    id: json['id']! as String,
    createdAt: BaseRecord.parseTimestamp(json['createdAt']),
    updatedAt: BaseRecord.parseTimestamp(json['updatedAt']),
    deletedAt: BaseRecord.parseOptionalTimestamp(json['deletedAt']),
    machineId: json['machineId'] as String?,
    grinderId: json['grinderId'] as String?,
    kind: CareKind.parse(json['kind']! as String),
    doneAt: BaseRecord.parseTimestamp(json['doneAt']),
  );

  /// Machine the care was done on, or null.
  final String? machineId;

  /// Grinder the care was done on, or null.
  final String? grinderId;

  /// What was done.
  final CareKind kind;

  /// When it was done (UTC).
  final DateTime doneAt;

  /// Returns a copy with the given fields replaced.
  CareEvent copyWith({CareKind? kind, DateTime? doneAt}) => CareEvent(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    machineId: machineId,
    grinderId: grinderId,
    kind: kind ?? this.kind,
    doneAt: doneAt ?? this.doneAt,
  );

  @override
  CareEvent copyWithBase({DateTime? updatedAt, DateTime? deletedAt}) =>
      CareEvent(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        machineId: machineId,
        grinderId: grinderId,
        kind: kind,
        doneAt: doneAt,
      );

  @override
  Map<String, Object?> toExtraJson() => {
    'machineId': machineId,
    'grinderId': grinderId,
    'kind': kind.code,
    'doneAt': BaseRecord.formatTimestamp(doneAt),
  };
}
