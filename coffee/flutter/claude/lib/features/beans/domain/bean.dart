import '../../../core/data/base_record.dart';
import 'bean_kind.dart';
import 'roast_level.dart';

/// A coffee bean offering by a roaster (SPEC section 3).
class Bean extends BaseRecord {
  /// Creates a bean.
  const Bean({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.name,
    required this.roaster,
    required this.roastLevel,
    required this.kind,
    this.minStockG,
    this.leadTimeDays = 3,
  });

  /// Reads a bean written by [toJson].
  factory Bean.fromJson(Map<String, Object?> json) => Bean(
    id: json['id']! as String,
    createdAt: BaseRecord.parseTimestamp(json['createdAt']),
    updatedAt: BaseRecord.parseTimestamp(json['updatedAt']),
    deletedAt: BaseRecord.parseOptionalTimestamp(json['deletedAt']),
    name: json['name']! as String,
    roaster: json['roaster']! as String,
    roastLevel: RoastLevel.parse(json['roastLevel']! as String),
    kind: BeanKind.parse(json['kind']! as String),
    minStockG: (json['minStockG'] as num?)?.toDouble(),
    leadTimeDays: (json['leadTimeDays'] as num?)?.toInt() ?? 3,
  );

  /// Display name.
  final String name;

  /// Roaster name.
  final String roaster;

  /// Roast level.
  final RoastLevel roastLevel;

  /// Intended use.
  final BeanKind kind;

  /// Minimum stock in grams before reordering, or null.
  final double? minStockG;

  /// Days a reorder takes to arrive.
  final int leadTimeDays;

  /// Returns a copy with the given fields replaced; set [clearMinStock] to
  /// remove the minimum stock.
  Bean copyWith({
    String? name,
    String? roaster,
    RoastLevel? roastLevel,
    BeanKind? kind,
    double? minStockG,
    bool clearMinStock = false,
    int? leadTimeDays,
  }) => Bean(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    name: name ?? this.name,
    roaster: roaster ?? this.roaster,
    roastLevel: roastLevel ?? this.roastLevel,
    kind: kind ?? this.kind,
    minStockG: clearMinStock ? null : minStockG ?? this.minStockG,
    leadTimeDays: leadTimeDays ?? this.leadTimeDays,
  );

  @override
  Bean copyWithBase({DateTime? updatedAt, DateTime? deletedAt}) => Bean(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
    name: name,
    roaster: roaster,
    roastLevel: roastLevel,
    kind: kind,
    minStockG: minStockG,
    leadTimeDays: leadTimeDays,
  );

  @override
  Map<String, Object?> toExtraJson() => {
    'name': name,
    'roaster': roaster,
    'roastLevel': roastLevel.code,
    'kind': kind.code,
    'minStockG': minStockG,
    'leadTimeDays': leadTimeDays,
  };
}
