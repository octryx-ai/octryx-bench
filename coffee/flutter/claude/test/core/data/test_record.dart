import 'package:kaffee_begleiter/core/data/base_record.dart';

/// Minimal record used by the data layer tests.
class TestRecord extends BaseRecord {
  const TestRecord({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    this.name = '',
  });

  factory TestRecord.fromJson(Map<String, Object?> json) => TestRecord(
    id: json['id']! as String,
    createdAt: BaseRecord.parseTimestamp(json['createdAt']),
    updatedAt: BaseRecord.parseTimestamp(json['updatedAt']),
    deletedAt: BaseRecord.parseOptionalTimestamp(json['deletedAt']),
    name: json['name']! as String,
  );

  final String name;

  @override
  TestRecord copyWithBase({DateTime? updatedAt, DateTime? deletedAt}) =>
      TestRecord(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        name: name,
      );

  TestRecord rename(String value) => TestRecord(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    name: value,
  );

  @override
  Map<String, Object?> toExtraJson() => {'name': name};
}
