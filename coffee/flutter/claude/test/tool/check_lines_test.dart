import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_lines_lib.dart';

void main() {
  late Directory root;

  setUp(() => root = Directory.systemTemp.createTempSync('check_lines'));
  tearDown(() => root.deleteSync(recursive: true));

  void write(String rel, int lines, {bool trailingNewline = true}) {
    final file = File('${root.path}/$rel')..createSync(recursive: true);
    final body = List.filled(lines, '// x').join('\n');
    file.writeAsStringSync(trailingNewline ? '$body\n' : body);
  }

  Future<(int, String)> run() async {
    final out = StringBuffer();
    final code = await checkLines(root, out);
    return (code, out.toString());
  }

  test('small files pass with exit 0', () async {
    write('lib/a.dart', 10);
    write('test/a_test.dart', 10);
    final (code, out) = await run();
    expect(code, 0);
    expect(out, isEmpty);
  });

  test('lib file with 301 lines and trailing newline fails', () async {
    write('lib/x.dart', 301);
    final (code, out) = await run();
    expect(code, 1);
    expect(out, contains('lib/x.dart: 301'));
  });

  test('lib file with 301 lines without trailing newline fails', () async {
    write('lib/sub/y.dart', 301, trailingNewline: false);
    final (code, out) = await run();
    expect(code, 1);
    expect(out, contains('lib/sub/y.dart: 301'));
  });

  test('lib file with 300 lines and trailing newline passes', () async {
    write('lib/x.dart', 300);
    final (code, out) = await run();
    expect(code, 0);
    expect(out, isEmpty);
  });

  test(
    'lib file with exactly 300 lines, no trailing newline, passes',
    () async {
      write('lib/x.dart', 300, trailingNewline: false);
      expect((await run()).$1, 0);
    },
  );

  test('test file limit is 500', () async {
    write('test/ok_test.dart', 500, trailingNewline: false);
    expect((await run()).$1, 0);
    write('test/big_test.dart', 501, trailingNewline: false);
    final (code, out) = await run();
    expect(code, 1);
    expect(out, contains('test/big_test.dart: 501'));
  });

  test('exempt generated and l10n files are ignored', () async {
    write('lib/a.g.dart', 1000);
    write('lib/a.freezed.dart', 1000);
    write('lib/l10n/app_localizations.dart', 1000);
    write('lib/l10n/app_localizations_de.dart', 1000);
    final (code, out) = await run();
    expect(code, 0);
    expect(out, isEmpty);
  });
}
