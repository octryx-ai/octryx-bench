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
