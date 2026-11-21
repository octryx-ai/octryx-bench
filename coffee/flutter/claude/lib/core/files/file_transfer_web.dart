import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'file_transfer.dart';
import 'save_outcome.dart';

/// Browser implementation: a Blob download and a hidden file input.
class PlatformFileTransfer implements FileTransfer {
  /// Creates the transfer.
  const PlatformFileTransfer();

  @override
  bool get canPick => true;

  @override
  Future<SaveOutcome> save(String fileName, String content) async {
    final blob = web.Blob(
      [content.toJS].toJS,
      web.BlobPropertyBag(type: 'application/json'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName;
    web.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
    return SaveOutcome.downloaded;
  }

  @override
  Future<String?> pickText() {
    final done = Completer<String?>();
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = '.json,application/json';
    input.addEventListener(
      'change',
      (web.Event _) {
        final file = input.files?.item(0);
        if (file == null) {
          done.complete(null);
          return;
        }
        file.text().toDart.then(
          (text) => done.complete(text.toDart),
          onError: (Object _) => done.complete(null),
        );
      }.toJS,
    );
    input.addEventListener(
      'cancel',
      (web.Event _) {
        if (!done.isCompleted) done.complete(null);
      }.toJS,
    );
    // Browsers without a `cancel` event only give the focus back to the page:
    // if no file arrived shortly after that, treat the dialog as cancelled.
    web.window.addEventListener(
      'focus',
      (web.Event _) {
        Timer(const Duration(seconds: 2), () {
          if (!done.isCompleted && input.files?.length == 0) {
            done.complete(null);
          }
        });
      }.toJS,
    );
    input.click();
    return done.future;
  }
}

/// Device storage in the browser: `localStorage`, so data survives a reload
/// (SPEC decision 2: local storage, offline first).
class PlatformKeyValueStorage {
  /// Creates the storage view.
  const PlatformKeyValueStorage();

  /// Value stored under [key], or null.
  String? read(String key) => web.window.localStorage.getItem(key);

  /// Stores [value] under [key].
  void write(String key, String value) =>
      web.window.localStorage.setItem(key, value);
}
