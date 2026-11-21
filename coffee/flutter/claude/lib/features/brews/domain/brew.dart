import '../../../core/data/base_record.dart';
import 'brew_method.dart';
import 'brew_pour.dart';
import 'taste.dart';

const Object _keep = Object();

/// A logged brew (SPEC section 3, "Brew").
class Brew extends BaseRecord {
  /// Creates a brew; [startedAt] must be UTC.
  const Brew({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.method,
    this.machineId,
    required this.grinderId,
    required this.packId,
    required this.grindSetting,
    required this.doseG,
    this.purgeG = 0,
    this.yieldG,
    this.shotTimeS,
    this.waterTempC,
    this.waterProfileId,
    this.taste,
    this.rating,
    this.note = '',
    required this.startedAt,
    this.waterTotalG,
    this.bloomG,
    this.pours = const [],
    this.drawdownS,
  });

  /// Reads a brew written by [toJson].
  factory Brew.fromJson(Map<String, Object?> json) {
    double? d(String k) => (json[k] as num?)?.toDouble();
    int? i(String k) => (json[k] as num?)?.toInt();
    final taste = json['taste'] as String?;
    return Brew(
      id: json['id']! as String,
      createdAt: BaseRecord.parseTimestamp(json['createdAt']),
      updatedAt: BaseRecord.parseTimestamp(json['updatedAt']),
      deletedAt: BaseRecord.parseOptionalTimestamp(json['deletedAt']),
      method: BrewMethod.parse(json['method']! as String),
      machineId: json['machineId'] as String?,
      grinderId: json['grinderId']! as String,
      packId: json['packId']! as String,
      grindSetting: d('grindSetting')!,
      doseG: d('doseG')!,
      purgeG: d('purgeG') ?? 0,
      yieldG: d('yieldG'),
      shotTimeS: i('shotTimeS'),
      waterTempC: d('waterTempC'),
      waterProfileId: json['waterProfileId'] as String?,
      taste: taste == null ? null : Taste.parse(taste),
      rating: i('rating'),
      note: json['note'] as String? ?? '',
      startedAt: BaseRecord.parseTimestamp(json['startedAt']),
      waterTotalG: d('waterTotalG'),
      bloomG: d('bloomG'),
      pours: [
        for (final p in (json['pours'] as List<Object?>? ?? const []))
          BrewPour.fromJson((p! as Map).cast<String, Object?>()),
      ],
      drawdownS: i('drawdownS'),
    );
  }

  /// Brewing method.
  final BrewMethod method;

  /// Machine used (espresso), or null.
  final String? machineId;

  /// Grinder used.
  final String grinderId;

  /// Pack the coffee came from.
  final String packId;

  /// Grinder dial setting.
  final double grindSetting;

  /// Coffee dose in grams.
  final double doseG;

  /// Coffee purged from the grinder before the dose, in grams.
  final double purgeG;

  /// Output weight in grams (espresso), or null.
  final double? yieldG;

  /// Shot time in seconds (espresso), or null.
  final int? shotTimeS;

  /// Water temperature in degrees Celsius, or null.
  final double? waterTempC;

  /// Water profile used, or null.
  final String? waterProfileId;

  /// Taste impression, or null.
  final Taste? taste;

  /// Rating 1 to 5, or null.
  final int? rating;

  /// Free-text note.
  final String note;

  /// Start instant (UTC).
  final DateTime startedAt;

  /// Total water in grams (filter), or null.
  final double? waterTotalG;

  /// Bloom water in grams (filter), or null.
  final double? bloomG;

  /// Pours (filter); empty if none.
  final List<BrewPour> pours;

  /// Drawdown time in seconds (filter), or null.
  final int? drawdownS;

  /// Returns a copy with the given fields replaced. Nullable fields can be
  /// cleared by passing an explicit `null`.
  Brew copyWith({
    BrewMethod? method,
    Object? machineId = _keep,
    String? grinderId,
    String? packId,
    double? grindSetting,
    double? doseG,
    double? purgeG,
    Object? yieldG = _keep,
    Object? shotTimeS = _keep,
    Object? waterTempC = _keep,
    Object? waterProfileId = _keep,
    Object? taste = _keep,
    Object? rating = _keep,
    String? note,
    DateTime? startedAt,
    Object? waterTotalG = _keep,
    Object? bloomG = _keep,
    List<BrewPour>? pours,
    Object? drawdownS = _keep,
  }) => Brew(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    method: method ?? this.method,
    machineId: identical(machineId, _keep)
        ? this.machineId
        : machineId as String?,
    grinderId: grinderId ?? this.grinderId,
    packId: packId ?? this.packId,
    grindSetting: grindSetting ?? this.grindSetting,
    doseG: doseG ?? this.doseG,
    purgeG: purgeG ?? this.purgeG,
    yieldG: identical(yieldG, _keep) ? this.yieldG : yieldG as double?,
    shotTimeS: identical(shotTimeS, _keep) ? this.shotTimeS : shotTimeS as int?,
    waterTempC: identical(waterTempC, _keep)
        ? this.waterTempC
        : waterTempC as double?,
    waterProfileId: identical(waterProfileId, _keep)
        ? this.waterProfileId
        : waterProfileId as String?,
    taste: identical(taste, _keep) ? this.taste : taste as Taste?,
    rating: identical(rating, _keep) ? this.rating : rating as int?,
    note: note ?? this.note,
    startedAt: startedAt ?? this.startedAt,
    waterTotalG: identical(waterTotalG, _keep)
        ? this.waterTotalG
        : waterTotalG as double?,
    bloomG: identical(bloomG, _keep) ? this.bloomG : bloomG as double?,
    pours: pours ?? this.pours,
    drawdownS: identical(drawdownS, _keep) ? this.drawdownS : drawdownS as int?,
  );

  @override
  Brew copyWithBase({DateTime? updatedAt, DateTime? deletedAt}) => Brew(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
    method: method,
    machineId: machineId,
    grinderId: grinderId,
    packId: packId,
    grindSetting: grindSetting,
    doseG: doseG,
    purgeG: purgeG,
    yieldG: yieldG,
    shotTimeS: shotTimeS,
    waterTempC: waterTempC,
    waterProfileId: waterProfileId,
    taste: taste,
    rating: rating,
    note: note,
    startedAt: startedAt,
    waterTotalG: waterTotalG,
    bloomG: bloomG,
    pours: pours,
    drawdownS: drawdownS,
  );

  @override
  Map<String, Object?> toExtraJson() => {
    'method': method.code,
    'machineId': machineId,
    'grinderId': grinderId,
    'packId': packId,
    'grindSetting': grindSetting,
    'doseG': doseG,
    'purgeG': purgeG,
    'yieldG': yieldG,
    'shotTimeS': shotTimeS,
    'waterTempC': waterTempC,
    'waterProfileId': waterProfileId,
    'taste': taste?.code,
    'rating': rating,
    'note': note,
    'startedAt': BaseRecord.formatTimestamp(startedAt),
    'waterTotalG': waterTotalG,
    'bloomG': bloomG,
    'pours': [for (final p in pours) p.toJson()],
    'drawdownS': drawdownS,
  };
}
