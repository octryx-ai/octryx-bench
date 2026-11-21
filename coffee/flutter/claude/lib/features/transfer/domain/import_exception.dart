import 'import_error.dart';

/// Thrown when an import file is rejected; nothing was changed.
class ImportException implements Exception {
  /// Creates the exception for [error].
  const ImportException(this.error);

  /// The reason.
  final ImportError error;

  @override
  String toString() => 'ImportException(${error.name})';
}
