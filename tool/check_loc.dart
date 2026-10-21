import 'dart:io';

import 'src/workspace.dart';

/// Fails if any hand-written Dart file in a workspace package's lib/ or
/// test/, or in the root test/, exceeds [maxLines].
///
///     dart run tool/check_loc.dart
///
/// Generated files (by name, or a first line starting `// GENERATED CODE`)
/// and vendored source (packages/core/lib/vendor/) are exempt.
const int maxLines = 500;

void main() {
  final offenders = checkLoc(Directory.current.path);
  if (offenders.isEmpty) {
    stdout.writeln('OK: every file is within $maxLines lines.');
    return;
  }
  stderr
    ..writeln('LOC violations (limit $maxLines), split these:\n')
    ..writeln(offenders.join('\n'));
  exitCode = 1;
}

/// Returns one line per file under `<root>` that exceeds [maxLines].
List<String> checkLoc(String root) {
  final offenders = <String>[];
  final dirs = <String>[
    for (final package in workspacePackages(root)) ...<String>[
      '${package.dir}/lib',
      '${package.dir}/test',
    ],
    'test',
  ];

  for (final dir in dirs) {
    for (final path in filesUnder(root, dir)) {
      if (!path.endsWith('.dart') || _isExempt(path)) continue;
      final List<String> lines;
      try {
        lines = File('$root/$path').readAsLinesSync();
      } on FileSystemException {
        offenders.add('  $path: unreadable (not UTF-8)');
        continue;
      }
      if (lines.isNotEmpty && lines.first.startsWith('// GENERATED CODE')) {
        continue;
      }
      if (lines.length > maxLines) {
        offenders.add('  $path: ${lines.length} lines');
      }
    }
  }
  return offenders..sort();
}

bool _isExempt(String path) =>
    path.startsWith(vendorDir) ||
    isL10nOutput(path) ||
    path.endsWith('.g.dart') ||
    path.endsWith('.gen.dart') ||
    path.endsWith('.freezed.dart') ||
    path.endsWith('.mocks.dart');
