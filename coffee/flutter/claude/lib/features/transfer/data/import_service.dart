import '../../../app/app_data.dart';
import '../domain/import_merger.dart';
import '../domain/import_result.dart';

/// Imports an export file into [AppData] (SPEC section 6).
class ImportService {
  /// Creates the service.
  const ImportService();

  /// Merges [json] into [data] by record id.
  ///
  /// Throws `ImportException` and changes nothing if the file is unusable.
  /// The merge is computed on copies and committed in one transaction;
  /// listeners are notified once. Nothing is ever hard-deleted.
  Future<ImportResult> importJson(AppData data, String json) async {
    final outcome = const ImportMerger().merge(data.snapshot(), json);
    final r = outcome.result;
    if (r.imported + r.deletedApplied > 0 ||
        outcome.snapshot.settings.hardnessUnit != data.hardnessUnit) {
      await data.restore(outcome.snapshot);
    }
    return r;
  }
}
