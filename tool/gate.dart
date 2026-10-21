import 'dart:io';

import 'src/workspace.dart';

/// The quality gate. Exits 1 on the first failing step.
///
///     dart run tool/gate.dart [--quiet]
///
/// `--quiet` prints one line per passing step and the full output only for
/// the step that fails; tests report failures only.
///
/// Per-package steps run with the package directory as the working
/// directory. Formatting is checked, never applied, and only on hand-written
/// files: never run `dart format` over packages/core/lib/vendor/ (that is an
/// unrecorded vendor edit).
Future<void> main(List<String> args) async {
  final quiet = args.contains('--quiet');
  final root = Directory.current.path;
  final formatBatches = batches(formattableFiles(root));
  final steps = gateSteps(root, quiet: quiet, formatBatches: formatBatches);

  for (final step in steps) {
    final label = stepLabel(step);
    if (!quiet) stdout.writeln('== $label ==');
    // runInShell resolves the flutter/dart launchers on every OS.
    final result = await Process.run(
      step.command.first,
      step.command.sublist(1),
      workingDirectory: step.dir.isEmpty ? root : '$root/${step.dir}',
      runInShell: true,
    );
    final failed = result.exitCode != 0;
    if (!quiet || failed) {
      if (quiet) stdout.writeln('== $label ==');
      stdout.write((result.stdout as String?) ?? '');
      stderr.write((result.stderr as String?) ?? '');
    } else {
      stdout.writeln('ok: $label');
    }
    if (failed) {
      stdout.writeln('FAILED: $label (exit ${result.exitCode})');
      exit(1);
    }
  }
  stdout.writeln('GATE PASSED');
}

/// One gate step: a name, the root-relative directory it runs in (empty for
/// the root) and its command line.
typedef GateStep = ({String name, String dir, List<String> command});

String stepLabel(GateStep step) =>
    step.dir.isEmpty ? step.name : '${step.name} (${step.dir})';

/// The gate's steps in order for the workspace at [root].
List<GateStep> gateSteps(
  String root, {
  required bool quiet,
  required List<List<String>> formatBatches,
}) {
  final packages = workspacePackages(root);
  GateStep atRoot(String name, List<String> command) =>
      (name: name, dir: '', command: command);
  GateStep tool(String name, String file, [List<String> args = const []]) =>
      atRoot(name, <String>['dart', 'run', 'tool/$file', ...args]);
  final failuresOnly = <String>[
    if (quiet) ...<String>['-r', 'failures-only'],
  ];

  return <GateStep>[
    tool('assets', 'generate_assets.dart', <String>['--check']),
    tool('tokens', 'generate_tokens.dart', <String>['--check']),
    for (final package in packages)
      if (_usesBuildRunner(root, package))
        (
          name: 'build_runner',
          dir: package.dir,
          command: <String>['dart', 'run', 'build_runner', 'build'],
        ),
    for (final batch in formatBatches)
      atRoot('format', <String>[
        'dart',
        'format',
        '--output=none',
        '--set-exit-if-changed',
        ...batch,
      ]),
    for (final package in packages)
      if (File('$root/${package.dir}/l10n.yaml').existsSync())
        (
          name: 'l10n',
          dir: package.dir,
          command: <String>['flutter', 'gen-l10n'],
        ),
    for (final package in packages)
      (
        name: 'analyze',
        dir: package.dir,
        command: <String>['flutter', 'analyze'],
      ),
    atRoot('analyze', <String>[
      'dart',
      'analyze',
      '--fatal-infos',
      'tool',
      'test/tool',
    ]),
    tool('boundaries', 'check_boundaries.dart'),
    tool('loc', 'check_loc.dart'),
    tool('structure', 'check_structure.dart'),
    tool('branding', 'check_branding.dart'),
    tool('layout', 'check_layout.dart'),
    tool('duplicates', 'check_duplicates.dart'),
    for (final package in packages)
      if (_hasTests(root, package))
        (
          name: 'test',
          dir: package.dir,
          command: <String>['flutter', 'test', ...failuresOnly],
        ),
    atRoot('test', <String>['dart', 'test', 'test/tool', ...failuresOnly]),
  ];
}

bool _usesBuildRunner(String root, WorkspacePackage package) {
  final pubspec = File('$root/${package.dir}/pubspec.yaml');
  return pubspec.existsSync() &&
      RegExp(
        r'^\s+build_runner\s*:',
        multiLine: true,
      ).hasMatch(pubspec.readAsStringSync());
}

/// A test/ directory with at least one test; `flutter test` fails on an
/// empty one.
bool _hasTests(String root, WorkspacePackage package) => filesUnder(
  root,
  '${package.dir}/test',
).any((path) => path.endsWith('_test.dart'));

/// Hand-written Dart files in each package's lib/ and test/ (minus
/// packages/core/lib/vendor/), and in the root tool/ and test/.
List<String> formattableFiles(String root) {
  final dirs = <String>[
    for (final package in workspacePackages(root)) ...<String>[
      '${package.dir}/lib',
      '${package.dir}/test',
    ],
    'tool',
    'test',
  ];
  final files = <String>[];
  for (final dir in dirs) {
    for (final path in filesUnder(root, dir)) {
      if (!path.endsWith('.dart') ||
          path.startsWith(vendorDir) ||
          isL10nOutput(path) ||
          path.endsWith('.g.dart') ||
          path.endsWith('.freezed.dart') ||
          path.endsWith('.mocks.dart') ||
          _hasGeneratedHeader('$root/$path')) {
        continue;
      }
      files.add(path);
    }
  }
  return files..sort();
}

bool _hasGeneratedHeader(String path) {
  try {
    final lines = File(path).readAsLinesSync();
    return lines.isNotEmpty && lines.first.startsWith('// GENERATED CODE');
  } on FileSystemException {
    return false;
  }
}

/// Splits [files] so no command line outgrows the Windows shell limit.
List<List<String>> batches(List<String> files, {int size = 100}) =>
    <List<String>>[
      for (var i = 0; i < files.length; i += size)
        files.sublist(i, i + size > files.length ? files.length : i + size),
    ];
