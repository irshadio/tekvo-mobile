import 'dart:io';

import 'src/workspace.dart';

/// Generates [outputPath]: one `Assets` constant per bundled file in
/// packages/core/[assetsDir], so code never spells an asset path. The core
/// package bundles the files, so each constant holds the key an app loads
/// (`packages/core/assets/...`).
///
///     dart run tool/generate_assets.dart           # write the file
///     dart run tool/generate_assets.dart --check   # gate: fail if stale
///
/// A constant is named after the file's folder and name in camelCase
/// (`assets/icons/arrow_left.svg` -> `iconsArrowLeft`). Fonts, hidden files
/// and `2.0x` / `3.0x` variants get no constant. Files in an [indexedDirs]
/// folder, looked up by name at runtime, form one map named after the folder
/// instead (`assets/flags/ae.svg` -> `flags['ae']`). Every other file must be
/// declared under `flutter: assets:` in packages/core/pubspec.yaml.
const String assetsDir = 'assets';
const String outputPath = '$coreDir/lib/assets/assets.gen.dart';

/// The pubspec that declares the assets, and the key prefix apps load them
/// with.
const String pubspecPath = '$coreDir/pubspec.yaml';
const String assetKeyPrefix = 'packages/core/';

const Set<String> indexedDirs = <String>{'$assetsDir/flags'};

const Set<String> _ignoredExtensions = <String>{'.ttf', '.otf'};
const int _lineLimit = 80;

final RegExp _variantDir = RegExp(r'^\d+(\.\d+)?x$');
final RegExp _identifier = RegExp(r'^[a-z][a-zA-Z0-9]*$');
final RegExp _rawAssetPath = RegExp(
  '''['"](?:$assetKeyPrefix)?$assetsDir/''',
);

const Set<String> _reserved = <String>{
  'assert',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'default',
  'do',
  'else',
  'enum',
  'extends',
  'false',
  'final',
  'finally',
  'for',
  'if',
  'in',
  'is',
  'new',
  'null',
  'rethrow',
  'return',
  'super',
  'switch',
  'this',
  'throw',
  'true',
  'try',
  'var',
  'void',
  'while',
  'with',
};

void main(List<String> args) {
  final root = Directory.current.path;
  final check = args.contains('--check');
  final GeneratedAssets result;
  try {
    result = generateAssets(root);
  } on AssetsException catch (error) {
    stderr.writeln(error);
    exitCode = 1;
    return;
  }

  if (!check) {
    File('$root/$outputPath')
      ..createSync(recursive: true)
      ..writeAsStringSync(result.source);
    stdout.writeln('Wrote $outputPath (${result.count} assets).');
    return;
  }

  final problems = checkAssets(root, result.source);
  if (problems.isEmpty) {
    stdout.writeln('OK: $outputPath is current and used.');
    return;
  }
  stderr
    ..writeln('Asset problems (${problems.length}):\n')
    ..writeln(problems.join('\n'));
  exitCode = 1;
}

class GeneratedAssets {
  const GeneratedAssets(this.source, this.count);

  final String source;
  final int count;
}

class AssetsException implements Exception {
  const AssetsException(this.problems);

  final List<String> problems;

  @override
  String toString() =>
      'Cannot generate $outputPath:\n\n${problems.join('\n')}\n\n'
      'Declare each file under `flutter: assets:` in $pubspecPath and give '
      'every file a unique, valid name.';
}

/// Builds the source of [outputPath] from the files under
/// `<root>/packages/core/assets`. Paths are read relative to the core
/// package, as its pubspec declares them.
GeneratedAssets generateAssets(String root) {
  final declared = declaredAssets(File('$root/$pubspecPath'));
  final dir = Directory('$root/$coreDir/$assetsDir');
  final problems = <String>[];
  final byName = <String, String>{};
  final indexes = <String, Map<String, String>>{};

  final files = dir.existsSync()
      ? dir.listSync(recursive: true).whereType<File>()
      : const <File>[];
  final prefix = '${root.replaceAll(r'\', '/')}/$coreDir/';
  final paths =
      files
          .map((f) => f.path.replaceAll(r'\', '/').replaceFirst(prefix, ''))
          .where(_isCandidate)
          .toList()
        ..sort();

  for (final path in paths) {
    final segments = path.split('/');
    final folder = segments.length > 2 ? segments[segments.length - 2] : '';
    if (_variantDir.hasMatch(folder)) {
      final base = [
        ...segments.sublist(0, segments.length - 2),
        segments.last,
      ].join('/');
      if (!paths.contains(base)) {
        problems.add(
          '  $coreDir/$path: resolution variant without $coreDir/$base',
        );
      }
      continue;
    }
    if (!_isDeclared(path, declared)) {
      problems.add('  $coreDir/$path: not declared in $pubspecPath');
      continue;
    }
    if (path.contains("'") || path.contains(r'$') || path.contains(r'\')) {
      problems.add('  $coreDir/$path: quote, dollar or backslash in the path');
      continue;
    }
    final dir = path.substring(0, path.lastIndexOf('/'));
    if (indexedDirs.contains(dir)) {
      final index = indexes[dir] ??= <String, String>{};
      final key = _stem(segments.last);
      if (index[key] case final clash?) {
        problems.add(
          '  $coreDir/$path: "$key" is also the name of $coreDir/$clash',
        );
      } else {
        index[key] = path;
      }
      continue;
    }
    final name = constantName(path);
    if (!_identifier.hasMatch(name) || _reserved.contains(name)) {
      problems.add('  $coreDir/$path: "$name" is not a valid constant name');
      continue;
    }
    final clash = byName[name];
    if (clash != null) {
      problems.add(
        '  $coreDir/$path: "$name" is also the name of $coreDir/$clash',
      );
      continue;
    }
    byName[name] = path;
  }
  for (final dir in indexes.keys) {
    final name = dir.split('/').last;
    if (!_identifier.hasMatch(name) || _reserved.contains(name)) {
      problems.add('  $coreDir/$dir/: "$name" is not a valid map name');
    } else if (byName[name] case final clash?) {
      problems.add(
        '  $coreDir/$dir/: "$name" is also the name of $coreDir/$clash',
      );
    }
  }
  if (problems.isNotEmpty) throw AssetsException(problems);

  final names = byName.keys.toList()..sort();
  final count =
      names.length + indexes.values.fold<int>(0, (n, m) => n + m.length);
  final buffer = StringBuffer()
    ..writeln('// Generated by tool/generate_assets.dart. Do not edit: run')
    ..writeln('// `dart run tool/generate_assets.dart` after changing')
    ..writeln('// $coreDir/$assetsDir/.')
    ..writeln()
    ..writeln('/// Paths of the bundled assets.')
    ..write('abstract final class Assets {');
  if (count == 0) {
    buffer.writeln('}');
    return GeneratedAssets(buffer.toString(), 0);
  }
  buffer.writeln();
  for (final name in names) {
    final value = '$assetKeyPrefix${byName[name]}';
    final line = "  static const String $name = '$value';";
    if (line.length <= _lineLimit) {
      buffer.writeln(line);
    } else {
      buffer
        ..writeln('  static const String $name =')
        ..writeln("      '$value';");
    }
  }
  for (final dir in indexes.keys.toList()..sort()) {
    final entries = indexes[dir]!;
    buffer
      ..writeln()
      ..writeln('  /// `$assetKeyPrefix$dir/` by file name.')
      ..writeln(
        '  static const Map<String, String> ${dir.split('/').last} = '
        '<String, String>{',
      );
    for (final key in entries.keys.toList()..sort()) {
      buffer.writeln("    '$key': '$assetKeyPrefix${entries[key]}',");
    }
    buffer.writeln('  };');
  }
  buffer.writeln('}');
  return GeneratedAssets(buffer.toString(), count);
}

String _stem(String file) {
  final dot = file.lastIndexOf('.');
  return dot > 0 ? file.substring(0, dot) : file;
}

/// Folder and file name, without the extension, in camelCase.
String constantName(String path) {
  final segments = path.split('/');
  final stem = _stem(segments.last);
  final folder = segments.length > 2 ? segments[segments.length - 2] : '';
  final words = '${folder}_$stem'
      .replaceAll(RegExp(r'[-\s]+'), '_')
      .replaceAll(RegExp('[^a-zA-Z0-9_]'), '')
      .split('_')
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return '';
  return words.first.toLowerCase() +
      words
          .skip(1)
          .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
          .join();
}

/// The `flutter: assets:` entries of [pubspec]: block or inline lists of
/// paths, or `- path:` entries.
Set<String> declaredAssets(File pubspec) {
  if (!pubspec.existsSync()) return <String>{};
  final declared = <String>{};
  int? childIndent;
  int? assetsIndent;
  int? itemIndent;
  var inFlutter = false;
  for (final raw in pubspec.readAsLinesSync()) {
    final line = raw.replaceFirst(RegExp(r'(^|\s)#.*$'), '').trimRight();
    if (line.trim().isEmpty) continue;
    final indent = line.length - line.trimLeft().length;
    final text = line.trim();
    if (indent == 0) {
      inFlutter = text == 'flutter:';
      childIndent = null;
      assetsIndent = null;
      itemIndent = null;
      continue;
    }
    if (!inFlutter) continue;
    childIndent ??= indent;
    if (assetsIndent != null &&
        (indent > assetsIndent ||
            (indent == assetsIndent && text.startsWith('-')))) {
      if (text.startsWith('-')) itemIndent ??= indent;
      // Deeper lines belong to an item, e.g. its `flavors:`.
      if (indent != itemIndent) continue;
      final item = RegExp(r'^-\s*(?:path:\s*)?(.+)$').firstMatch(text);
      if (item != null) declared.add(_unquote(item.group(1)!));
      continue;
    }
    assetsIndent = null;
    if (indent != childIndent) continue;
    final inline = RegExp(r'^assets:\s*\[(.*)\]$').firstMatch(text);
    if (inline != null) {
      declared.addAll(
        inline.group(1)!.split(',').map(_unquote).where((e) => e.isNotEmpty),
      );
    } else if (text == 'assets:') {
      assetsIndent = indent;
      itemIndent = null;
    }
  }
  return declared;
}

String _unquote(String value) {
  final trimmed = value.trim();
  final quoted = RegExp(r"""^(['"])(.*)\1$""").firstMatch(trimmed);
  return quoted == null ? trimmed : quoted.group(2)!;
}

/// Problems with [expected] as the current output: a stale file, or a raw
/// asset path in a package's lib/ instead of an `Assets` constant.
List<String> checkAssets(String root, String expected) {
  final problems = <String>[];
  final output = File('$root/$outputPath');
  if (!output.existsSync() ||
      output.readAsStringSync().replaceAll('\r\n', '\n') != expected) {
    problems.add(
      '  $outputPath: out of date; run `dart run tool/generate_assets.dart`',
    );
  }

  final paths = <String>[
    for (final package in workspacePackages(root))
      ...filesUnder(root, '${package.dir}/lib'),
  ];
  for (final path in paths) {
    if (!path.endsWith('.dart') ||
        path == outputPath ||
        path.startsWith(vendorDir) ||
        isL10nOutput(path) ||
        path.endsWith('.g.dart') ||
        path.endsWith('.freezed.dart')) {
      continue;
    }
    final lines = File('$root/$path').readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final code = lines[i].trimLeft();
      if (!code.startsWith('//') && _rawAssetPath.hasMatch(code)) {
        problems.add('  $path:${i + 1}: use an Assets constant, not a path');
      }
    }
  }
  return problems..sort();
}

bool _isCandidate(String path) {
  if (path.split('/').any((segment) => segment.startsWith('.'))) return false;
  final name = path.split('/').last;
  final dot = name.lastIndexOf('.');
  final extension = dot < 0 ? '' : name.substring(dot).toLowerCase();
  return !_ignoredExtensions.contains(extension);
}

bool _isDeclared(String path, Set<String> declared) {
  if (declared.contains(path)) return true;
  final slash = path.lastIndexOf('/');
  return declared.contains(path.substring(0, slash + 1));
}
