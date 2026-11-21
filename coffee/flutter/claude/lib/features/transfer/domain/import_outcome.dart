import 'data_snapshot.dart';
import 'import_result.dart';

/// The merged data and counters computed by `ImportMerger`.
class ImportOutcome {
  /// Creates an outcome.
  const ImportOutcome(this.snapshot, this.result);

  /// Everything as it should be after the import.
  final DataSnapshot snapshot;

  /// The counters.
  final ImportResult result;
}
