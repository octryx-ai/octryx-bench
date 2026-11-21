import '../../../core/data/base_record.dart';
import 'finer_direction.dart';

/// A coffee grinder with its dial scale (SPEC R1).
class Grinder extends BaseRecord {
  /// Creates a grinder.
  const Grinder({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.name,
    required this.scaleMin,
    required this.scaleMax,
    required this.scaleStep,
    required this.finerDirection,
    required this.deadSpaceG,
  });

  /// Reads a grinder written by [toJson].
  factory Grinder.fromJson(Map<String, Object?> json) => Grinder(
    id: json['id']! as String,
    createdAt: BaseRecord.parseTimestamp(json['createdAt']),
    updatedAt: BaseRecord.parseTimestamp(json['updatedAt']),
    deletedAt: BaseRecord.parseOptionalTimestamp(json['deletedAt']),
    name: json['name']! as String,
    scaleMin: (json['scaleMin']! as num).toDouble(),
    scaleMax: (json['scaleMax']! as num).toDouble(),
    scaleStep: (json['scaleStep']! as num).toDouble(),
    finerDirection: FinerDirection.values.byName(
      json['finerDirection']! as String,
    ),
    deadSpaceG: (json['deadSpaceG']! as num).toDouble(),
  );

  /// Display name.
  final String name;

  /// Lowest dial setting.
  final double scaleMin;

  /// Highest dial setting.
  final double scaleMax;

  /// Distance between two valid dial settings.
  final double scaleStep;

  /// Which turning direction grinds finer.
  final FinerDirection finerDirection;

  /// Coffee retained in the grinder, in grams.
  final double deadSpaceG;

  /// Returns a copy with the given fields replaced.
  Grinder copyWith({
    String? name,
    double? scaleMin,
    double? scaleMax,
    double? scaleStep,
    FinerDirection? finerDirection,
    double? deadSpaceG,
  }) => Grinder(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    name: name ?? this.name,
    scaleMin: scaleMin ?? this.scaleMin,
    scaleMax: scaleMax ?? this.scaleMax,
    scaleStep: scaleStep ?? this.scaleStep,
    finerDirection: finerDirection ?? this.finerDirection,
    deadSpaceG: deadSpaceG ?? this.deadSpaceG,
  );

  @override
  Grinder copyWithBase({DateTime? updatedAt, DateTime? deletedAt}) => Grinder(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
    name: name,
    scaleMin: scaleMin,
    scaleMax: scaleMax,
    scaleStep: scaleStep,
    finerDirection: finerDirection,
    deadSpaceG: deadSpaceG,
  );

  @override
  Map<String, Object?> toExtraJson() => {
    'name': name,
    'scaleMin': scaleMin,
    'scaleMax': scaleMax,
    'scaleStep': scaleStep,
    'finerDirection': finerDirection.name,
    'deadSpaceG': deadSpaceG,
  };
}
