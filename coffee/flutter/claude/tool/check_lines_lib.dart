import 'dart:convert';
import 'dart:io';

/// Maximum number of lines allowed in a file below `lib/`.
const int maxLibLines = 300;

/// Maximum number of lines allowed in a file below `test/`.
const int maxTestLines = 500;

/// Returns true if [relPath] (forward slashes) is exempt from the check.
bool isExempt(String relPath) {
  final name = relPath.split('/').last;
  if (name.endsWith('.g.dart') || name.endsWith('.freezed.dart')) {
    return true;
  }
  return relPath.startsWith('lib/l10n/') &&
      name.startsWith('app_localizations') &&
      name.endsWith('.dart');
}

/// Counts the lines of [file]; a final newline does not start a new line.
int countLines(File file) =>
    const LineSplitter().convert(file.readAsStringSync()).length;

/// Checks `lib/` (max 300 lines) and `test/` (max 500 lines) below [root].
///
/// Writes `<relative path>: <lines>` for each violating file to [out] and
/// returns the process exit code: 1 if any file violates, otherwise 0.
Future<int> checkLines(Directory root, StringSink out) async {
  final limits = {'lib': maxLibLines, 'test': maxTestLines};
  final violations = <String>[];
  final rootPath = root.absolute.path.replaceAll('\\', '/');
  for (final entry in limits.entries) {
    final dir = Directory('$rootPath/${entry.key}');
    if (!dir.existsSync()) continue;
    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final full = file.absolute.path.replaceAll('\\', '/');
      final rel = full.substring(rootPath.length + 1);
      if (isExempt(rel)) continue;
      final lines = countLines(file);
      if (lines > entry.value) violations.add('$rel: $lines');
    }
  }
  violations.sort();
  violations.forEach(out.writeln);
  return violations.isEmpty ? 0 : 1;
}
