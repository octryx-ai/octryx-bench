/// Why an import was rejected.
enum ImportError {
  /// The file's `schemaVersion` is not supported.
  unsupportedVersion,

  /// The file is not valid JSON or lacks the expected structure.
  invalidFile,
}
