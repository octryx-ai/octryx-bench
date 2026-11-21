import '../../../core/data/base_record.dart';

/// Merge of one record type: [records] is the new full list.
class MergeStep<T extends BaseRecord> {
  /// Creates a step.
  MergeStep(this.records);

  /// Merged records (local ones first, then new ones).
  final List<T> records;

  /// Records inserted or replaced.
  int imported = 0;

  /// Records kept as they were.
  int unchanged = 0;

  /// Records dropped because of a missing reference.
  int skipped = 0;

  /// Existing records deleted by a newer deletion.
  int deletedApplied = 0;

  /// Ids present after the merge.
  Set<String> get ids => {for (final r in records) r.id};

  /// Merges [incoming] into [local] by id; the file's version wins only if
  /// its `updatedAt` is strictly newer. [refsOk] tells if all references of
  /// a record exist; failing records are skipped.
  static MergeStep<T> run<T extends BaseRecord>(
    List<T> local,
    List<T> incoming,
    bool Function(T) refsOk,
  ) {
    final byId = {for (final r in local) r.id: r};
    final step = MergeStep<T>([]);
    for (final r in incoming) {
      final mine = byId[r.id];
      if (mine != null && !r.updatedAt.isAfter(mine.updatedAt)) {
        step.unchanged++;
      } else if (!refsOk(r)) {
        step.skipped++;
      } else if (mine == null) {
        byId[r.id] = r;
        step.imported++;
      } else {
        byId[r.id] = r;
        if (r.isDeleted && !mine.isDeleted) {
          step.deletedApplied++;
        } else {
          step.imported++;
        }
      }
    }
    step.records.addAll(byId.values);
    return step;
  }
}
