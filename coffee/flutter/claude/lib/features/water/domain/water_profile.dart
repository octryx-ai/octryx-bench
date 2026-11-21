import '../../../core/data/base_record.dart';

const Object _keep = Object();

/// A water analysis; hardness is stored in ppm CaCO3 (SPEC R2).
class WaterProfile extends BaseRecord {
  /// Creates a water profile.
  const WaterProfile({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.name,
    required this.hardnessPpm,
    this.alkalinityPpm,
    this.tdsPpm,
    this.ph,
    this.sodiumMgL,
    this.chlorineMgL,
  });

  /// Reads a profile written by [toJson].
  factory WaterProfile.fromJson(Map<String, Object?> json) {
    double? opt(String k) => (json[k] as num?)?.toDouble();
    return WaterProfile(
      id: json['id']! as String,
      createdAt: BaseRecord.parseTimestamp(json['createdAt']),
      updatedAt: BaseRecord.parseTimestamp(json['updatedAt']),
      deletedAt: BaseRecord.parseOptionalTimestamp(json['deletedAt']),
      name: json['name']! as String,
      hardnessPpm: (json['hardnessPpm']! as num).toDouble(),
      alkalinityPpm: opt('alkalinityPpm'),
      tdsPpm: opt('tdsPpm'),
      ph: opt('ph'),
      sodiumMgL: opt('sodiumMgL'),
      chlorineMgL: opt('chlorineMgL'),
    );
  }

  /// Display name.
  final String name;

  /// Total hardness in ppm CaCO3.
  final double hardnessPpm;

  /// Alkalinity in ppm CaCO3, if measured.
  final double? alkalinityPpm;

  /// Total dissolved solids in ppm, if measured.
  final double? tdsPpm;

  /// pH value, if measured.
  final double? ph;

  /// Sodium in mg/L, if measured.
  final double? sodiumMgL;

  /// Chlorine in mg/L, if measured.
  final double? chlorineMgL;

  /// Returns a copy with the given fields replaced. The optional measurements
  /// accept an explicit `null` to clear them; omitting keeps the old value.
  WaterProfile copyWith({
    String? name,
    double? hardnessPpm,
    Object? alkalinityPpm = _keep,
    Object? tdsPpm = _keep,
    Object? ph = _keep,
    Object? sodiumMgL = _keep,
    Object? chlorineMgL = _keep,
  }) => WaterProfile(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    name: name ?? this.name,
    hardnessPpm: hardnessPpm ?? this.hardnessPpm,
    alkalinityPpm: identical(alkalinityPpm, _keep)
        ? this.alkalinityPpm
        : alkalinityPpm as double?,
    tdsPpm: identical(tdsPpm, _keep) ? this.tdsPpm : tdsPpm as double?,
    ph: identical(ph, _keep) ? this.ph : ph as double?,
    sodiumMgL: identical(sodiumMgL, _keep)
        ? this.sodiumMgL
        : sodiumMgL as double?,
    chlorineMgL: identical(chlorineMgL, _keep)
        ? this.chlorineMgL
        : chlorineMgL as double?,
  );

  @override
  WaterProfile copyWithBase({DateTime? updatedAt, DateTime? deletedAt}) =>
      WaterProfile(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        name: name,
        hardnessPpm: hardnessPpm,
        alkalinityPpm: alkalinityPpm,
        tdsPpm: tdsPpm,
        ph: ph,
        sodiumMgL: sodiumMgL,
        chlorineMgL: chlorineMgL,
      );

  @override
  Map<String, Object?> toExtraJson() => {
    'name': name,
    'hardnessPpm': hardnessPpm,
    'alkalinityPpm': alkalinityPpm,
    'tdsPpm': tdsPpm,
    'ph': ph,
    'sodiumMgL': sodiumMgL,
    'chlorineMgL': chlorineMgL,
  };
}
