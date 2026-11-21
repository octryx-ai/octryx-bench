import 'package:flutter/services.dart';

import 'file_transfer.dart';
import 'save_outcome.dart';

/// Device implementation. The export goes through the system share sheet
/// (native `shareFile` handler of the Android and iOS runners); if that is
/// unavailable or fails, the text is copied to the clipboard instead.
/// Importing happens by pasting.
class PlatformFileTransfer implements FileTransfer {
  /// Creates the transfer.
  const PlatformFileTransfer();

  /// Method channel of the native share sheet.
  static const MethodChannel channel = MethodChannel(
    'ch.octryx.kaffee_begleiter/share',
  );

  @override
  bool get canPick => false;

  @override
  Future<SaveOutcome> save(String fileName, String content) async {
    try {
      final shared = await channel.invokeMethod<bool>('shareFile', {
        'fileName': fileName,
        'content': content,
      });
      if (shared ?? false) return SaveOutcome.shared;
    } on PlatformException {
      // Fall through to the clipboard.
    } on MissingPluginException {
      // No native share sheet on this platform (e.g. desktop, tests).
    }
    await Clipboard.setData(ClipboardData(text: content));
    return SaveOutcome.copied;
  }

  @override
  Future<String?> pickText() async => null;
}

/// Device storage without a browser: a process-wide map, so a new app state
/// in the same process sees what an earlier one stored. Persisting native
/// data across an app restart (drift/SQLite) is the follow-up story
/// "native persistence with drift".
class PlatformKeyValueStorage {
  /// Creates the storage view.
  const PlatformKeyValueStorage();

  static final Map<String, String> _values = {};

  /// Value stored under [key], or null.
  String? read(String key) => _values[key];

  /// Stores [value] under [key].
  void write(String key, String value) => _values[key] = value;

  /// Removes every value (an empty device).
  static void clear() => _values.clear();
}
