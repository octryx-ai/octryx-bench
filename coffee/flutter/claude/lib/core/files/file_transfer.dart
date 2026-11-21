import 'save_outcome.dart';

/// Moves export text out of the app and import text into it. The platform
/// implementation is picked by a conditional import (browser vs. device).
abstract interface class FileTransfer {
  /// Whether [pickText] opens a file chooser on this platform.
  bool get canPick;

  /// Hands [content] to the user as the file [fileName].
  Future<SaveOutcome> save(String fileName, String content);

  /// Lets the user choose a JSON file and returns its text, or null if the
  /// choice was cancelled.
  Future<String?> pickText();
}
