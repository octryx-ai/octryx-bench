import 'dart:convert';

import '../../../core/data/base_record.dart';
import 'data_snapshot.dart';

/// Writes a [DataSnapshot] as the JSON export file (SPEC section 6).
class ExportCodec {
  const ExportCodec._();

  /// Current value of `schemaVersion`.
  static const int schemaVersion = 1;

  /// File name `coffee-export-YYYY-MM-DD.json` for [today].
  static String fileName(DateTime today) =>
      'coffee-export-'
      '${today.year.toString().padLeft(4, '0')}-'
      '${today.month.toString().padLeft(2, '0')}-'
      '${today.day.toString().padLeft(2, '0')}.json';

  /// Compact JSON of [data] stamped with [exportedAt]; soft-deleted records
  /// are included with all their fields.
  static String encode(DataSnapshot data, DateTime exportedAt) {
    List<Map<String, Object?>> list(Iterable<BaseRecord> rs) => [
      for (final r in rs) r.toJson(),
    ];
    return jsonEncode({
      'schemaVersion': schemaVersion,
      'exportedAt': BaseRecord.formatTimestamp(exportedAt),
      'grinders': list(data.grinders),
      'machines': list(data.machines),
      'waterProfiles': list(data.waterProfiles),
      'beans': list(data.beans),
      'packs': list(data.packs),
      'brews': list(data.brews),
      'careEvents': list(data.careEvents),
      'settings': {'hardnessUnit': data.settings.hardnessUnit.code},
    });
  }
}
