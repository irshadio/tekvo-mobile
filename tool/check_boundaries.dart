import 'dart:io';

import 'src/dart_source.dart';
import 'src/workspace.dart';

export 'src/dart_source.dart' show directiveUris, maskDart;

/// Enforces the import boundaries and banned APIs in every workspace
/// package's lib/.
///
///     dart run tool/check_boundaries.dart
///
/// An import or export (every URI, including conditional ones) is illegal
/// when:
///   1. vendor/ (packages/core/lib/vendor/) reaches outside vendor/ (it is a
///      leaf).
///   2. core imports an app package.
///   3. an app imports another app; a feature imports another feature, or
///      its app's app/.
///   4. within a feature, domain/ imports data/ or presentation/, or data/
///      imports presentation/.
///   5. remote_client (rc.*) or dio is imported outside core, an app's app/
///      and a feature's data/, or re-exported outside vendor/.
///   6. it is relative, outside vendor/ (a `part` must stay in its own
///      directory).
///   7. it pulls in a banned package (go_router, dartz).
///
/// Plus: `$Notifier` only in the two state mixins, no `setState`, no
/// `Future.delayed` inside a ViewModel, and no colour or text-style literals
/// in an app (screens take both from the core theme).
void main() {
  final violations = checkBoundaries(Directory.current.path);
  if (violations.isEmpty) {
    stdout.writeln('OK: no import-boundary violations.');
    return;
  }
  stderr
    ..writeln('Import-boundary violations (${violations.length}):\n')
    ..writeln(violations.join('\n\n'));
  exitCode = 1;
}

const List<String> _transportPrefixes = <String>[
  'package:core/vendor/remote_client/',
  'package:remote_client/',
  'package:dio/',
];
const List<String> _bannedPackages = <String>[
  'package:go_router/',
  'package:dartz/',
];
const String _notifierToken = r'$Notifier';
final RegExp _notifier = RegExp(r'\$Notifier\b');
const Set<String> _notifierFiles = <String>{
  '$coreDir/lib/state/remote_state_mixin.dart',
  '$coreDir/lib/state/mutation_state_mixin.dart',
};

/// A directive at a line start or after `;`, past any annotations. The URI
/// must follow the keyword, so `export: '...'` and `import = '...'` are not
/// directives.
final RegExp _directive = RegExp(
  r'''(?:^|(?<=;))\s*(?:@[\w.]+(?:\((?:[^()]|\([^()]*\))*\))?\s*)*'''
  r'''\b(import|export|part)\s*(?=r?['"])([^;]*);''',
  multiLine: true,
);

/// Returns one message per violation under each workspace package's lib/.
List<String> checkBoundaries(String root) {
  final packages = workspacePackages(root);
  final violations = <String>[];
  for (final package in packages) {
    for (final fromPath in filesUnder(root, '${package.dir}/lib')) {
      if (!_isHandwrittenDart(fromPath)) continue;
      final String source;
      try {
        source = File('$root/$fromPath').readAsStringSync();
      } on FileSystemException {
        violations.add('  $fromPath\n    -> unreadable (not UTF-8)');
        continue;
      }
      final withStrings = maskDart(source);
      final blank = maskDart(source, strings: true);
      final from = _Location(packages, fromPath);
      violations
        ..addAll(_checkDirectives(packages, from, withStrings, blank))
        ..addAll(_checkBannedCode(from, blank));
    }
  }
  return violations;
}

/// Directives are located in [blank] (so text inside strings never looks
/// like one) and their URIs read from the same span of [withStrings].
List<String> _checkDirectives(
  List<WorkspacePackage> packages,
  _Location from,
  String withStrings,
  String blank,
) {
  final violations = <String>[];
  final fromPath = from.path;

  for (final directive in _directive.allMatches(blank)) {
    final keyword = directive.group(1)!;
    final isExport = keyword == 'export';
    final bodyEnd = directive.end - 1;
    final body = withStrings.substring(
      bodyEnd - directive.group(2)!.length,
      bodyEnd,
    );
    for (final raw in directiveUris(body)) {
      final target = _packageTarget(packages, raw);
      final uri = target == null
          ? raw
          : 'package:${target.package.name}/${target.rest}';
      void report(String reason) =>
          violations.add('  $fromPath\n    imports $uri\n    -> $reason');

      if (keyword == 'part') {
        final partPath = target?.path ?? _resolve(fromPath, uri);
        if (_directory(partPath) != _directory(fromPath)) {
          report('a part must live in the same directory');
        }
        continue;
      }

      if (!uri.startsWith('package:') && !uri.startsWith('dart:')) {
        if (from.zone != _Zone.vendor) {
          report('relative import; use package:${from.package.name}/...');
          continue;
        }
        if (!_resolve(fromPath, uri).startsWith(vendorDir)) {
          report('vendored code may not reach outside lib/vendor/');
        }
        continue;
      }

      if (_bannedPackages.any(uri.startsWith)) {
        report('banned package');
        continue;
      }

      if (_transportPrefixes.any(uri.startsWith)) {
        final reason = _transportViolation(from, isExport: isExport);
        if (reason != null) report(reason);
      }

      if (target == null) continue;
      final reason = _violation(from, _Location(packages, target.path));
      if (reason != null) report(reason);
    }
  }
  return violations;
}

List<String> _checkBannedCode(_Location from, String code) {
  if (from.zone == _Zone.vendor) return <String>[];
  final fromPath = from.path;
  final violations = <String>[];
  void report(String what) => violations.add('  $fromPath\n    -> $what');

  if (_notifier.hasMatch(code) && !_notifierFiles.contains(fromPath)) {
    report('names $_notifierToken; only the two state mixins may');
  }
  if (_setState.hasMatch(code)) {
    report('calls setState; state belongs to a ViewModel');
  }
  if (fromPath.endsWith('_view_model.dart') && _futureDelayed.hasMatch(code)) {
    report(
      'uses Future.delayed in a ViewModel; put stand-ins behind a '
      'repository',
    );
  }
  if (!from.package.isApp) return violations;
  for (final (patterns, what) in _themeRules) {
    final lines = <int>{
      for (final pattern in patterns)
        for (final m in pattern.allMatches(code)) _lineOf(code, m.start),
    }.toList()..sort();
    if (lines.isEmpty) continue;
    violations.add('  $fromPath:${lines.join(',')}\n    -> $what');
  }
  return violations;
}

final RegExp _setState = RegExp(r'\bsetState\b');
final RegExp _futureDelayed = RegExp(
  r'\bFuture\s*(?:<[^;(){}]*>)?\s*\.\s*delayed\b',
);

/// App code reads colours and text styles from the core theme.
final List<(List<RegExp>, String)> _themeRules = <(List<RegExp>, String)>[
  (
    <RegExp>[
      RegExp(r'(?<![\w$])Color\s*\(\s*0[xX]'),
      RegExp(r'(?<![\w$])Color\s*\.\s*from(?:ARGB|RGBO)\s*\('),
      RegExp(r'(?<![\w$])Colors\s*\.\s*(?!transparent\b)\w+'),
    ],
    'hard-codes a colour (Color literal or Colors.*); take colours from '
        'the core theme',
  ),
  (
    <RegExp>[
      RegExp(r'(?<![\w$])TextStyle\s*\('),
      RegExp(r'(?<![\w$])font(?:Size|Weight|Family)\s*:(?!:)'),
    ],
    'hard-codes a text style (TextStyle( or font*:); take text styles from '
        'the core theme',
  ),
];

int _lineOf(String code, int offset) =>
    '\n'.allMatches(code.substring(0, offset)).length + 1;

String _directory(String path) => path.substring(0, path.lastIndexOf('/') + 1);

/// Resolves a relative [uri] against [fromPath] to a root-relative path.
String _resolve(String fromPath, String uri) =>
    Uri.parse('/$fromPath').resolve(uri).path.substring(1);

/// A `package:` URI into a workspace package, with dot segments removed.
({WorkspacePackage package, String rest, String path})? _packageTarget(
  List<WorkspacePackage> packages,
  String uri,
) {
  final match = RegExp(r'^package:(\w+)/(.*)$').firstMatch(uri);
  if (match == null) return null;
  for (final package in packages) {
    if (package.name != match.group(1)) continue;
    final rest = Uri.parse('/${match.group(2)}').normalizePath().path;
    return (
      package: package,
      rest: rest.substring(1),
      path: '${package.dir}/lib$rest',
    );
  }
  return null;
}

bool _isHandwrittenDart(String path) =>
    path.endsWith('.dart') &&
    !path.endsWith('.g.dart') &&
    !path.endsWith('.freezed.dart') &&
    !isL10nOutput(path);

String? _transportViolation(_Location from, {required bool isExport}) {
  if (from.zone == _Zone.vendor) return null;
  if (isExport) return 'only vendor/ may re-export transport types';
  if (from.zone == _Zone.core || from.zone == _Zone.app) return null;
  if (from.zone == _Zone.feature && from.layer == _Layer.data) return null;
  return 'remote_client (rc.*) and dio may appear only in core, app/ or '
      "a feature's data/ layer";
}

String? _violation(_Location from, _Location to) {
  if (from.zone == _Zone.vendor && to.zone != _Zone.vendor) {
    return 'vendored code may not import ${to.zone.name} (it is a leaf)';
  }
  if (from.package.isCore && to.package.isApp) {
    return 'core may not import app package "${to.package.name}"';
  }
  if (from.package.isApp &&
      to.package.isApp &&
      from.package.dir != to.package.dir) {
    return 'app "${from.package.name}" may not import app '
        '"${to.package.name}"';
  }
  if (from.zone == _Zone.feature && to.zone == _Zone.app) {
    return 'features may not import app';
  }
  if (from.zone == _Zone.feature && to.zone == _Zone.feature) {
    if (from.feature != to.feature) {
      return 'feature "${from.feature}" may not import feature '
          '"${to.feature}"';
    }
    if (from.layer == _Layer.domain && to.layer != _Layer.domain) {
      return 'domain may not import ${to.layer.name}';
    }
    if (from.layer == _Layer.data && to.layer == _Layer.presentation) {
      return 'data may not import presentation';
    }
  }
  return null;
}

enum _Zone { core, app, feature, vendor, other }

enum _Layer { domain, data, presentation, other }

/// Where a root-relative path sits: its package, zone, feature and layer.
class _Location {
  factory _Location(List<WorkspacePackage> packages, String path) {
    final package =
        packageOf(packages, path) ??
        const WorkspacePackage(name: '', dir: '', isApp: false);
    final inLib = path.startsWith('${package.dir}/lib/')
        ? path.substring(package.dir.length + 5).split('/')
        : const <String>[];
    final zone = switch (inLib) {
      _ when path.startsWith(vendorDir) => _Zone.vendor,
      _ when !package.isApp => _Zone.core,
      ['app', _, ...] => _Zone.app,
      ['features', _, ...] => _Zone.feature,
      _ => _Zone.other,
    };
    final feature = zone == _Zone.feature ? inLib[1] : '';
    final layer = zone == _Zone.feature && inLib.length > 2
        ? switch (inLib[2]) {
            'domain' => _Layer.domain,
            'data' => _Layer.data,
            'presentation' => _Layer.presentation,
            _ => _Layer.other,
          }
        : _Layer.other;
    return _Location._(path, package, zone, feature, layer);
  }

  const _Location._(
    this.path,
    this.package,
    this.zone,
    this.feature,
    this.layer,
  );

  final String path;
  final WorkspacePackage package;
  final _Zone zone;

  /// The directory directly under `lib/features/`.
  final String feature;

  /// The layer directly under `lib/features/<name>/`.
  final _Layer layer;
}
