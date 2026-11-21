import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final forbidden = <String, RegExp>{
    'Color(': RegExp(r'\bColor\('),
    'Colors.': RegExp(r'\bColors\.'),
    'size literal': RegExp(
      r'\b(fontSize|width|height|size|radius|elevation|thickness|blurRadius|'
      r'minWidth|minHeight|maxWidth|maxHeight|horizontal|vertical|top|bottom|'
      r'left|right)\s*:\s*-?[1-9]',
    ),
    'EdgeInsets literal': RegExp(r'EdgeInsets\.\w+\(\s*-?[1-9]'),
    'BorderRadius literal': RegExp(r'BorderRadius\.\w+\(\s*[1-9]'),
    'Size literal': RegExp(r'\bSize(\.\w+)?\(\s*[1-9]'),
    'Offset literal': RegExp(r'\bOffset\(\s*[1-9]'),
  };

  test('lib/ has no colour or size literals outside tokens.dart', () {
    final violations = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !_norm(f).endsWith('core/theme/tokens.dart'))
        .where((f) => !_norm(f).contains('lib/l10n/'));
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        for (final rule in forbidden.entries) {
          if (rule.value.hasMatch(line)) {
            violations.add(
              '${file.path}:${i + 1}: ${rule.key}: ${line.trim()}',
            );
          }
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

String _norm(File f) => f.path.replaceAll('\\', '/');
