import 'dart:io';

/// The shared core package, relative to the workspace root.
const String coreDir = 'packages/core';

/// Vendored third-party source inside [coreDir].
const String vendorDir = '$coreDir/lib/vendor/';

/// A member of the root pubspec's `workspace:` list that exists on disk.
class WorkspacePackage {
  const WorkspacePackage({
    required this.name,
    required this.dir,
    required this.isApp,
  });

  /// The `name:` from its pubspec.yaml.
  final String name;

  /// Relative to the workspace root, e.g. `apps/customer`.
  final String dir;

  /// An app has `lib/app/`; every other package is a library like core.
  final bool isApp;

  bool get isCore => !isApp;

  @override
  String toString() => '$name ($dir)';
}

/// The workspace members listed in `<root>/pubspec.yaml`, in listed order,
/// skipping entries whose directory does not exist.
List<WorkspacePackage> workspacePackages(String root) {
  final pubspec = File('$root/pubspec.yaml');
  if (!pubspec.existsSync()) return const <WorkspacePackage>[];
  return <WorkspacePackage>[
    for (final dir in workspaceMembers(pubspec.readAsStringSync()))
      if (Directory('$root/$dir').existsSync())
        WorkspacePackage(
          name: _packageName(root, dir),
          dir: dir,
          isApp: Directory('$root/$dir/lib/app').existsSync(),
        ),
  ];
}

/// The entries of the top-level `workspace:` list in [pubspec].
List<String> workspaceMembers(String pubspec) {
  final members = <String>[];
  var inWorkspace = false;
  for (final raw in pubspec.split('\n')) {
    final line = raw.replaceFirst(RegExp(r'(^|\s)#.*$'), '').trimRight();
    if (line.trim().isEmpty) continue;
    if (!line.startsWith(' ') && !line.startsWith('-')) {
      inWorkspace = line == 'workspace:';
      continue;
    }
    if (!inWorkspace) continue;
    final item = RegExp(r'^\s*-\s*(.+)$').firstMatch(line);
    if (item == null) continue;
    final value = item.group(1)!.trim();
    final quoted = RegExp(r"""^(['"])(.*)\1$""").firstMatch(value);
    final dir = (quoted == null ? value : quoted.group(2)!).replaceAll(
      RegExp(r'/+$'),
      '',
    );
    if (dir.isNotEmpty) members.add(dir);
  }
  return members;
}

String _packageName(String root, String dir) {
  final pubspec = File('$root/$dir/pubspec.yaml');
  if (pubspec.existsSync()) {
    final name = RegExp(
      r'^name:\s*([\w]+)',
      multiLine: true,
    ).firstMatch(pubspec.readAsStringSync());
    if (name != null) return name.group(1)!;
  }
  return dir.split('/').last;
}

/// The package whose directory holds the root-relative [path], if any.
WorkspacePackage? packageOf(List<WorkspacePackage> packages, String path) {
  WorkspacePackage? best;
  for (final package in packages) {
    if (!path.startsWith('${package.dir}/')) continue;
    if (best == null || package.dir.length > best.dir.length) best = package;
  }
  return best;
}

/// [path] relative to [root], with forward slashes.
String relativePath(String root, String path) {
  final normalized = path.replaceAll(r'\', '/');
  final prefix = '${root.replaceAll(r'\', '/')}/';
  return normalized.startsWith(prefix)
      ? normalized.substring(prefix.length)
      : normalized;
}

/// Root-relative paths of the files under `<root>/<dir>`, sorted. Empty when
/// the directory does not exist.
List<String> filesUnder(String root, String dir) {
  final directory = Directory('$root/$dir');
  if (!directory.existsSync()) return const <String>[];
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .map((file) => relativePath(root, file.path))
      .toList()
    ..sort();
}

/// flutter gen-l10n output, in any package.
bool isL10nOutput(String path) =>
    RegExp('(^|/)lib/l10n/generated/').hasMatch(path);
