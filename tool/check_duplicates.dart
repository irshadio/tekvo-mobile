import 'dart:io';

import 'src/dart_source.dart';
import 'src/workspace.dart';

/// Flags code copied between features or between apps, in hand-written
/// app lib/ code:
///
///     dart run tool/check_duplicates.dart
///
///   class  The same top-level class, mixin, enum or extension type name
///          (a leading underscore ignored) declared in two features.
///   lines  Two files in different features sharing [minRun] or more
///          identical consecutive lines (blank lines, comments, indentation
///          and import / export / part directives ignored).
///
/// A feature is named `<app>/<feature>`; the rest of an app's lib/ (app/,
/// routing/, main*.dart, ...) is one unit named `<app>`. Units of one app
/// compare only feature to feature; units of two apps always compare.
///
/// Shared code belongs in core/. An intentional case is listed in
/// [classAllowList] or [linesAllowList] with the reason it stays; an entry
/// that no longer matches is reported as stale.
void main() {
  final violations = checkDuplicates(Directory.current.path);
  if (violations.isEmpty) {
    stdout.writeln('OK: no code duplicated across features.');
    return;
  }
  stderr
    ..writeln('Duplicated across features (${violations.length}):\n')
    ..writeln(violations.join('\n\n'));
  exitCode = 1;
}

/// Identical consecutive lines that count as a copy.
const int minRun = 20;

/// A class name shared on purpose: the exact units declaring it, and why
/// each keeps its own.
typedef SharedName = ({Set<String> features, String reason});

/// Class name (no leading underscore) -> where it is shared, and why.
const Map<String, SharedName> classAllowList = <String, SharedName>{};

/// `<path>|<path>` -> why the two files keep the shared lines.
const Map<String, String> linesAllowList = <String, String>{};

/// Returns one message per duplicate under each app's lib/, plus one per
/// stale allow-list entry.
List<String> checkDuplicates(
  String root, {
  Map<String, SharedName> classAllow = classAllowList,
  Map<String, String> linesAllow = linesAllowList,
}) {
  final files = _scan(root);
  return <String>[
    ..._classes(files, classAllow),
    ..._lines(files, linesAllow),
  ];
}

class _Source {
  _Source(this.path, this.app, this.feature, this.code);

  final String path;
  final String app;

  /// `<app>/<feature>`, or `<app>` outside lib/features/.
  final String feature;

  bool get inFeature => feature != app;

  /// Comments masked, strings kept.
  final String code;
}

/// Whether [a] and [b] are compared: different units, and either different
/// apps or two features.
bool _compared(_Source a, _Source b) =>
    a.feature != b.feature && (a.app != b.app || (a.inFeature && b.inFeature));

List<_Source> _scan(String root) {
  final sources = <_Source>[];
  for (final app in workspacePackages(root).where((p) => p.isApp)) {
    final lib = '${app.dir}/lib/';
    for (final path in filesUnder(root, lib).where(_isScanned)) {
      final segments = path.substring(lib.length).split('/');
      final String unit;
      if (segments.first == 'features') {
        if (segments.length < 3) continue;
        unit = '${app.name}/${segments[1]}';
      } else {
        unit = app.name;
      }
      try {
        final source = File('$root/$path').readAsStringSync();
        sources.add(_Source(path, app.name, unit, maskDart(source)));
      } on FileSystemException {
        continue;
      }
    }
  }
  return sources;
}

bool _isScanned(String path) =>
    path.endsWith('.dart') &&
    !isL10nOutput(path) &&
    !path.endsWith('.g.dart') &&
    !path.endsWith('.freezed.dart') &&
    !path.endsWith('.gen.dart');

final RegExp _declaration = RegExp(
  r'^(?:(?:abstract|base|final|interface|sealed|mixin)\s+)*'
  r'(?:class|mixin|enum|extension\s+type)\s+_?([A-Za-z]\w*)',
  multiLine: true,
);

List<String> _classes(List<_Source> files, Map<String, SharedName> allow) {
  final where = <String, Map<String, List<String>>>{};
  final declaring = <String, Map<String, _Source>>{};
  for (final file in files) {
    final blank = maskDart(file.code, strings: true);
    for (final m in _declaration.allMatches(blank)) {
      if (_depth(blank, m.start) != 0) continue;
      final name = m.group(1)!;
      ((where[name] ??= <String, List<String>>{})[file.feature] ??= <String>[])
          .add(file.path);
      (declaring[name] ??= <String, _Source>{})[file.feature] ??= file;
    }
  }

  final violations = <String>[];
  final names = where.keys.toList()..sort();
  final shared = <String>{};
  for (final name in names) {
    final features = where[name]!;
    final units = declaring[name]!.values.toList();
    final isShared = <bool>[
      for (var x = 0; x < units.length; x++)
        for (var y = x + 1; y < units.length; y++)
          _compared(units[x], units[y]),
    ].any((compared) => compared);
    if (!isShared) continue;
    shared.add(name);
    final allowed = allow[name]?.features;
    if (allowed != null &&
        allowed.length == features.length &&
        allowed.containsAll(features.keys)) {
      continue;
    }
    final paths = features.values.expand((p) => p).toList()..sort();
    violations.add(
      '  $name\n${paths.map((p) => '    $p').join('\n')}\n'
      '    -> class: declared in ${_names(features.keys)}'
      '${allowed == null ? '' : ', not the listed ${_names(allowed)}'}; '
      'share one from core/ or rename',
    );
  }
  for (final name in allow.keys) {
    if (shared.contains(name)) continue;
    violations.add(
      '  $name\n    -> class: stale allow-list entry; no longer declared in '
      'two features, delete the entry',
    );
  }
  return violations;
}

String _names(Iterable<String> features) =>
    'features {${(features.toList()..sort()).join(', ')}}';

/// Brace depth at [offset] in [code] (strings and comments blanked).
int _depth(String code, int offset) {
  var depth = 0;
  for (var i = 0; i < offset; i++) {
    final char = code.codeUnitAt(i);
    if (char == 0x7b) depth++;
    if (char == 0x7d) depth--;
  }
  return depth;
}

final RegExp _directive = RegExp(r'^(?:import|export|part)\b');

class _Line {
  const _Line(this.text, this.number);

  final String text;
  final int number;
}

List<_Line> _lineList(String code) {
  final lines = <_Line>[];
  final raw = code.split('\n');
  for (var i = 0; i < raw.length; i++) {
    final text = raw[i].trim();
    if (text.isEmpty || _directive.hasMatch(text)) continue;
    lines.add(_Line(text, i + 1));
  }
  return lines;
}

List<String> _lines(List<_Source> files, Map<String, String> allow) {
  final lines = <List<_Line>>[for (final file in files) _lineList(file.code)];
  final windows = <String, List<(int, int)>>{};
  for (var f = 0; f < files.length; f++) {
    final list = lines[f];
    for (var i = 0; i + minRun <= list.length; i++) {
      final key = list.sublist(i, i + minRun).map((l) => l.text).join('\n');
      (windows[key] ??= <(int, int)>[]).add((f, i));
    }
  }

  // File pair -> starts of shared windows, as (index in a, index in b).
  final pairs = <(int, int), Set<(int, int)>>{};
  for (final hits in windows.values) {
    for (var x = 0; x < hits.length; x++) {
      for (var y = x + 1; y < hits.length; y++) {
        final (fa, ia) = hits[x];
        final (fb, ib) = hits[y];
        if (!_compared(files[fa], files[fb])) continue;
        final (a, b, i, j) = fa < fb ? (fa, fb, ia, ib) : (fb, fa, ib, ia);
        (pairs[(a, b)] ??= <(int, int)>{}).add((i, j));
      }
    }
  }

  final allowed = <String>{for (final key in allow.keys) _pairKey(key)};
  final violations = <String>[];
  final found = <String>{};
  final keys = pairs.keys.toList()
    ..sort((p, q) => p.$1 != q.$1 ? p.$1 - q.$1 : p.$2 - q.$2);
  for (final pair in keys) {
    final (a, b) = pair;
    final key = _pairKey('${files[a].path}|${files[b].path}');
    found.add(key);
    if (allowed.contains(key)) continue;
    final starts = pairs[pair]!;
    var best = (0, 0, 0);
    for (final (i, j) in starts) {
      if (starts.contains((i - 1, j - 1))) continue;
      var extra = 0;
      while (starts.contains((i + extra + 1, j + extra + 1))) {
        extra++;
      }
      if (minRun + extra > best.$3) best = (i, j, minRun + extra);
    }
    final (i, j, length) = best;
    String span(int f, int start) =>
        '${files[f].path}:${lines[f][start].number}-'
        '${lines[f][start + length - 1].number}';
    violations.add(
      '  ${span(a, i)}\n  ${span(b, j)}\n'
      '    -> lines: $length identical lines across features; share them '
      'from core/',
    );
  }
  for (final key in allow.keys) {
    if (found.contains(_pairKey(key))) continue;
    violations.add(
      '  ${key.replaceAll('|', '\n  ')}\n    -> lines: stale allow-list '
      'entry; the files no longer share $minRun lines, delete the entry',
    );
  }
  return violations;
}

/// [key]'s two paths in sorted order.
String _pairKey(String key) => (key.split('|')..sort()).join('|');
