import 'dart:io';

import 'src/workspace.dart';

/// Enforces the mandatory feature layout in every app package.
///
///     dart run tool/check_structure.dart
///
/// Checks the shape of `<app>/lib/features/<name>/`, not the contents of the
/// files.
void main() {
  final violations = checkStructure(Directory.current.path);
  if (violations.isEmpty) {
    stdout.writeln('OK: every feature matches the mandatory layout.');
    return;
  }
  stderr
    ..writeln('Feature structure violations (${violations.length}):\n')
    ..writeln(violations.join('\n\n'));
  exitCode = 1;
}

/// Marker that exempts one ViewModel from the repository requirement. It
/// must be followed by a reason.
const String optOutMarker = 'check_structure: no-repository';

const Map<String, Set<String>> _allowedSub = <String, Set<String>>{
  'domain': <String>{'entities', 'repositories'},
  'data': <String>{'dtos', 'sources', 'repositories'},
  'presentation': <String>{'view', 'view_model'},
};

/// Required file-name suffixes per sub-layer.
const Map<String, List<String>> _suffixes = <String, List<String>>{
  'domain/repositories': <String>['_repository.dart'],
  'data/dtos': <String>['_dto.dart'],
  'data/sources': <String>[
    '_remote_data_source.dart',
    '_local_data_source.dart',
  ],
  'data/repositories': <String>['_repository_impl.dart'],
  'presentation/view': <String>['_view.dart'],
  'presentation/view_model': <String>['_view_model.dart'],
};

/// Returns one message per violation under each app's `lib/features`.
List<String> checkStructure(String root) {
  final violations = <String>[];
  for (final app in workspacePackages(root).where((p) => p.isApp)) {
    final features = '${app.dir}/lib/features';
    final featuresDir = Directory('$root/$features');
    if (!featuresDir.existsSync()) continue;

    for (final entity in _children(featuresDir)) {
      final name = _base(entity);
      if (entity is File) {
        violations.add(
          '  $features/$name\n'
          '    -> only feature directories belong in lib/features/',
        );
      } else if (name.startsWith('.')) {
        violations.add('  $features/$name/\n    -> hidden directory');
      } else if (entity is Directory) {
        violations.addAll(_checkFeature(entity, '$features/$name', name));
      }
    }
  }
  return violations;
}

List<String> _checkFeature(Directory feature, String path, String name) {
  final problems = <String>[];

  for (final entity in _children(feature)) {
    final base = _base(entity);
    if (entity is File) {
      if (base != '${name}_overrides.dart') {
        problems.add(
          '  $path/$base\n'
          '    -> the only file allowed at a feature root is '
          '${name}_overrides.dart',
        );
      }
      continue;
    }
    if (entity is! Directory) continue;
    final allowed = _allowedSub[base];
    if (allowed == null) {
      problems.add(
        '  $path/$base/\n'
        '    -> unexpected directory; a feature has only '
        '${_allowedSub.keys.join(", ")}',
      );
      continue;
    }
    for (final sub in _children(entity)) {
      final subBase = _base(sub);
      if (sub is File) {
        problems.add(
          '  $path/$base/$subBase\n'
          '    -> files belong in a sub-layer, not directly under $base/',
        );
      } else if (!allowed.contains(subBase)) {
        problems.add(
          '  $path/$base/$subBase/\n'
          '    -> $base/ may only contain ${allowed.join(", ")}',
        );
      } else {
        problems.addAll(_checkSubLayer(sub as Directory, '$path/$base'));
      }
    }
  }

  if (!Directory('${feature.path}/presentation/view').existsSync()) {
    problems.add('  $path/\n    -> every feature needs presentation/view/');
  }

  return problems
    ..addAll(_checkOverrides(feature, path, name))
    ..addAll(_checkViewModelsHaveRepository(feature, path));
}

/// Leaf sub-layers hold files only; view/ may add a widgets/ directory.
List<String> _checkSubLayer(Directory dir, String parentPath) {
  final problems = <String>[];
  final layer = '${parentPath.split('/').last}/${_base(dir)}';
  final suffixes = _suffixes[layer];

  for (final entity in _children(dir)) {
    final base = _base(entity);
    if (entity is Directory) {
      if (layer == 'presentation/view' && base == 'widgets') continue;
      problems.add(
        '  $parentPath/${_base(dir)}/$base/\n'
        '    -> $layer/ may not contain sub-directories',
      );
      continue;
    }
    if (suffixes == null || _isGenerated(base)) continue;
    if (!suffixes.any(base.endsWith)) {
      final hint = layer == 'presentation/view'
          ? '; put other widgets in view/widgets/'
          : '';
      problems.add(
        '  $parentPath/${_base(dir)}/$base\n'
        '    -> files here must end in ${suffixes.join(" or ")}$hint',
      );
    }
  }
  return problems;
}

/// A feature with a repository contract must bind it.
List<String> _checkOverrides(Directory feature, String path, String name) {
  if (!_hasRepositoryContract(feature)) return <String>[];
  if (File('${feature.path}/${name}_overrides.dart').existsSync()) {
    return <String>[];
  }
  final message =
      '  $path/\n    -> declares a repository contract but has no '
      '${name}_overrides.dart to bind it';
  return <String>[message];
}

/// A ViewModel that fetches or submits must ask a repository, unless it opts
/// out with [optOutMarker] and a reason.
List<String> _checkViewModelsHaveRepository(Directory feature, String path) {
  final dir = Directory('${feature.path}/presentation/view_model');
  if (!dir.existsSync()) return <String>[];

  final offenders =
      _children(dir)
          .whereType<File>()
          .where((f) => f.path.endsWith('_view_model.dart'))
          .where((f) {
            final source = f.readAsStringSync();
            return usesStateMixin(source) && !optsOut(source);
          })
          .map(_base)
          .toList()
        ..sort();
  if (offenders.isEmpty || _hasRepositoryContract(feature)) {
    return <String>[];
  }
  final message =
      '  $path/\n'
      '    -> ${offenders.join(", ")} run requests but the feature declares\n'
      '       no domain/repositories/<x>_repository.dart';
  return <String>[message];
}

final RegExp _mixinPattern = RegExp(
  r'\bwith\s[^{;]*\b(?:RemoteStateMixin|MutationStateMixin)\b',
);

/// True when [source] mixes in a state mixin outside comments.
bool usesStateMixin(String source) {
  final code = source
      .split('\n')
      .where((line) => !line.trimLeft().startsWith('//'))
      .join(' ');
  return _mixinPattern.hasMatch(code);
}

/// True when [source] carries [optOutMarker] followed by a reason.
bool optsOut(String source) =>
    source.split('\n').where((line) => line.contains(optOutMarker)).any((line) {
      final reason = line.split(optOutMarker).last;
      return reason.replaceAll(RegExp(r'^[\s—–:-]+'), '').trim().length >= 10;
    });

bool _hasRepositoryContract(Directory feature) {
  final dir = Directory('${feature.path}/domain/repositories');
  return dir.existsSync() &&
      _children(
        dir,
      ).whereType<File>().any((f) => f.path.endsWith('_repository.dart'));
}

/// Directory entries, skipping hidden files such as `.DS_Store`. Hidden
/// directories are kept so they fail the layout rules.
List<FileSystemEntity> _children(Directory dir) =>
    dir
        .listSync()
        .where((e) => e is! File || !_base(e).startsWith('.'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

String _base(FileSystemEntity entity) =>
    entity.path.replaceAll(r'\', '/').split('/').last;

bool _isGenerated(String base) =>
    base.endsWith('.g.dart') || base.endsWith('.freezed.dart');
