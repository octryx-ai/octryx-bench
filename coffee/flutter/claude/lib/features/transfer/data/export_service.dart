import '../../../app/app_data.dart';
import '../domain/export_codec.dart';

/// Creates the JSON export of all data (SPEC section 6).
class ExportService {
  /// Creates the service.
  const ExportService();

  /// JSON with every record of [data], soft-deleted ones included, stamped
  /// with [exportedAt] (default: now).
  String exportJson(AppData data, {DateTime? exportedAt}) => ExportCodec.encode(
    data.snapshot(),
    exportedAt ?? data.brewsRepository.now,
  );

  /// File name `coffee-export-YYYY-MM-DD.json` for [today].
  static String fileName(DateTime today) => ExportCodec.fileName(today);
}
