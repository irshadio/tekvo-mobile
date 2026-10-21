import 'dart:io';

import 'gate.dart';

/// Formats every hand-written Dart file: the same set the gate checks, so
/// packages/core/lib/vendor/ and generated files are never touched.
///
///     dart run tool/format.dart
///
/// `dart format` has no exclude option; never run it on `packages` or `.`.
Future<void> main() async {
  for (final batch in batches(formattableFiles(Directory.current.path))) {
    final result = await Process.run(
      'dart',
      <String>['format', ...batch],
      runInShell: true,
    );
    stdout.write((result.stdout as String?) ?? '');
    stderr.write((result.stderr as String?) ?? '');
    if (result.exitCode != 0) exit(result.exitCode);
  }
}
