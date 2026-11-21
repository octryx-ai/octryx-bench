import '../../../core/data/base_record.dart';

/// An espresso machine with its brewing defaults (SPEC R1).
class Machine extends BaseRecord {
  /// Creates a machine.
  const Machine({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.name,
    required this.brewTempC,
    required this.preinfusionS,
    required this.pressureProfile,
    this.defaultWaterProfileId,
  });

  /// Reads a machine written by [toJson].
  factory Machine.fromJson(Map<String, Object?> json) => Machine(
    id: json['id']! as String,
    createdAt: BaseRecord.parseTimestamp(json['createdAt']),
    updatedAt: BaseRecord.parseTimestamp(json['updatedAt']),
    deletedAt: BaseRecord.parseOptionalTimestamp(json['deletedAt']),
    name: json['name']! as String,
    brewTempC: (json['brewTempC']! as num).toDouble(),
    preinfusionS: (json['preinfusionS']! as num).toDouble(),
    pressureProfile: json['pressureProfile']! as String,
    defaultWaterProfileId: json['defaultWaterProfileId'] as String?,
  );

  /// Display name.
  final String name;

  /// Brew temperature in degrees Celsius.
  final double brewTempC;

  /// Pre-infusion time in seconds.
  final double preinfusionS;

  /// Free-text pressure profile.
  final String pressureProfile;

  /// Id of the default water profile, if any.
  final String? defaultWaterProfileId;

  /// Returns a copy with the given fields replaced; set
  /// [clearDefaultWaterProfile] to remove the default water profile.
  Machine copyWith({
    String? name,
    double? brewTempC,
    double? preinfusionS,
    String? pressureProfile,
    String? defaultWaterProfileId,
    bool clearDefaultWaterProfile = false,
  }) => Machine(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    name: name ?? this.name,
    brewTempC: brewTempC ?? this.brewTempC,
    preinfusionS: preinfusionS ?? this.preinfusionS,
    pressureProfile: pressureProfile ?? this.pressureProfile,
    defaultWaterProfileId: clearDefaultWaterProfile
        ? null
        : defaultWaterProfileId ?? this.defaultWaterProfileId,
  );

  @override
  Machine copyWithBase({DateTime? updatedAt, DateTime? deletedAt}) => Machine(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
    name: name,
    brewTempC: brewTempC,
    preinfusionS: preinfusionS,
    pressureProfile: pressureProfile,
    defaultWaterProfileId: defaultWaterProfileId,
  );

  @override
  Map<String, Object?> toExtraJson() => {
    'name': name,
    'brewTempC': brewTempC,
    'preinfusionS': preinfusionS,
    'pressureProfile': pressureProfile,
    'defaultWaterProfileId': defaultWaterProfileId,
  };
}
