import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/files/file_transfer_io.dart';
import 'package:kaffee_begleiter/core/files/save_outcome.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const transfer = PlatformFileTransfer();
  String? clipboard;

  setUp(() {
    clipboard = null;
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(PlatformFileTransfer.channel, null);
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test(
    'the export goes to the native share sheet with name and content',
    () async {
      MethodCall? seen;
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(PlatformFileTransfer.channel, (call) async {
            seen = call;
            return true;
          });
      final outcome = await transfer.save(
        'coffee-export-2026-11-16.json',
        '{"a":1}',
      );
      expect(outcome, SaveOutcome.shared);
      expect(seen!.method, 'shareFile');
      expect(seen!.arguments, {
        'fileName': 'coffee-export-2026-11-16.json',
        'content': '{"a":1}',
      });
      expect(clipboard, isNull);
    },
  );

  test('a failing share sheet falls back to the clipboard', () async {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(PlatformFileTransfer.channel, (call) async {
          throw PlatformException(code: 'share_failed');
        });
    final outcome = await transfer.save('x.json', '{"b":2}');
    expect(outcome, SaveOutcome.copied);
    expect(clipboard, '{"b":2}');
  });

  test('without a native handler the text is copied', () async {
    final outcome = await transfer.save('x.json', '{"c":3}');
    expect(outcome, SaveOutcome.copied);
    expect(clipboard, '{"c":3}');
  });
}
