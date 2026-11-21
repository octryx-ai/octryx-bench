import 'dart:io';

import 'check_lines_lib.dart';

/// CLI entry: `dart run tool/check_lines.dart` checks file-length limits.
Future<void> main() async {
  final code = await checkLines(Directory.current, stdout);
  exit(code);
}
