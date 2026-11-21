/// Outcome of an import (SPEC section 6).
class ImportResult {
  /// Creates a result.
  const ImportResult({
    this.imported = 0,
    this.unchanged = 0,
    this.skipped = 0,
    this.deletedApplied = 0,
  });

  /// Records inserted or replaced by a newer version.
  final int imported;

  /// Records whose local version was equal or newer.
  final int unchanged;

  /// Records dropped because a referenced record is missing.
  final int skipped;

  /// Existing records soft-deleted because the file's deletion is newer
  /// (not counted in [imported]).
  final int deletedApplied;
}
