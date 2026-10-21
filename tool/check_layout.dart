import 'dart:io';

import 'src/dart_source.dart';
import 'src/workspace.dart';

/// Flags patterns that cost work on every build or frame, break
/// accessibility, or do not mirror in Arabic, in every workspace package's
/// hand-written lib/ code (comments and strings ignored). No rule checks text scale; that is left
/// to the layout tests:
///
///     dart run tool/check_layout.dart
///
///   image-network      `Image.network(` outside the core network image.
///   media-query-of     `MediaQuery.of(`: read one aspect (`sizeOf`, ...).
///   modal-sheet        `showModalBottomSheet(` outside the core sheet helper.
///   semantics-gesture  `Semantics(button: true, child: GestureDetector(`,
///                      or with `toggled:` / `checked:`, in an app's
///                      features/ or app/: no focus, no keyboard activation.
///   rtl-text-align     `TextAlign.left` / `.right` in features/ or app/.
///   rtl-positioned     `Positioned(` with `left:` or `right:` in features/
///                      or app/, unless both sides are the same expression.
///   rtl-edge-insets    `EdgeInsets.only(` with `left:` or `right:`, under
///                      the same scope and exemption.
///   rtl-edge-insets-ltrb
///                      `EdgeInsets.fromLTRB(` in features/ or app/ whose
///                      left and right are written differently.
///   format-cache       `DateFormat(` / `NumberFormat(` (any constructor)
///                      outside the core format cache.
///
/// An existing site is listed in [layoutAllowList] with the reason it stays.
/// An entry whose file no longer breaks its rule is reported as stale, so
/// the fix deletes its own entry.
void main() {
  final violations = checkLayout(Directory.current.path);
  if (violations.isEmpty) {
    stdout.writeln('OK: no layout-rule violations.');
    return;
  }
  stderr
    ..writeln('Layout-rule violations (${violations.length}):\n')
    ..writeln(violations.join('\n\n'));
  exitCode = 1;
}

const String _networkImageFile =
    '$coreDir/lib/presentation/widgets/app_network_image.dart';
const String _sheetHelperFile =
    '$coreDir/lib/presentation/widgets/app_sheet.dart';
const String _formatCacheFile = '$coreDir/lib/utils/format_cache.dart';

/// Rule -> root-relative path -> why the site stays for now.
const Map<String, Map<String, String>> layoutAllowList =
    <String, Map<String, String>>{
      'media-query-of': <String, String>{
        '$coreDir/lib/presentation/widgets/offline_banner.dart':
            'scales the bottom inset of the whole MediaQuery while the strip '
            'animates; no single-aspect copy exists',
      },
    };

/// Returns one message per file and rule broken under each workspace
/// package's lib/, plus one per stale entry in [allowList].
List<String> checkLayout(
  String root, {
  Map<String, Map<String, String>> allowList = layoutAllowList,
}) {
  final hits = <String, Map<String, List<int>>>{};
  for (final package in workspacePackages(root)) {
    final lib = '${package.dir}/lib/';
    for (final path in filesUnder(root, lib).where(_isScanned)) {
      final String source;
      try {
        source = File('$root/$path').readAsStringSync();
      } on FileSystemException {
        continue;
      }
      final site = (
        path: path,
        inLib: path.substring(lib.length),
        isApp: package.isApp,
      );
      final code = maskDart(source, strings: true);
      for (final rule in _rules) {
        if (!rule.appliesTo(site)) continue;
        final offsets = rule.find(code);
        if (offsets.isEmpty) continue;
        (hits[rule.id] ??= <String, List<int>>{})[path] = <int>[
          for (final offset in offsets) _lineOf(code, offset),
        ];
      }
    }
  }

  final violations = <String>[];
  for (final rule in _rules) {
    final allowed = allowList[rule.id] ?? const <String, String>{};
    final found = hits[rule.id] ?? const <String, List<int>>{};
    for (final MapEntry(key: path, value: lines) in found.entries) {
      if (allowed.containsKey(path)) continue;
      violations.add(
        '  $path:${lines.join(',')}\n    -> ${rule.id}: ${rule.message}',
      );
    }
    for (final path in allowed.keys) {
      if (found.containsKey(path)) continue;
      violations.add(
        '  $path\n    -> ${rule.id}: stale allow-list entry; the file no '
        'longer breaks the rule, delete the entry',
      );
    }
  }
  return violations;
}

bool _isScanned(String path) =>
    path.endsWith('.dart') &&
    !path.startsWith(vendorDir) &&
    !isL10nOutput(path) &&
    !path.endsWith('.g.dart') &&
    !path.endsWith('.freezed.dart') &&
    !path.endsWith('.gen.dart');

/// A scanned file: its root-relative path, its path inside its package's
/// lib/, and whether that package is an app.
typedef _Site = ({String path, String inLib, bool isApp});

bool _inFeaturesOrApp(_Site site) =>
    site.isApp &&
    (site.inLib.startsWith('features/') || site.inLib.startsWith('app/'));

class _Rule {
  const _Rule(this.id, this.message, this.appliesTo, this.find);

  final String id;
  final String message;
  final bool Function(_Site site) appliesTo;
  final List<int> Function(String code) find;
}

final List<_Rule> _rules = <_Rule>[
  _Rule(
    'image-network',
    'use AppNetworkImage (decodes at display size)',
    (site) => site.path != _networkImageFile,
    _matches(RegExp(r'\bImage\s*\.\s*network\s*\(')),
  ),
  _Rule(
    'media-query-of',
    'read one aspect (MediaQuery.sizeOf, paddingOf, ...) so unrelated '
        'changes do not rebuild',
    (_) => true,
    _matches(RegExp(r'\bMediaQuery\s*\.\s*of\s*\(')),
  ),
  _Rule(
    'modal-sheet',
    'use showAppSheet (safe area, height cap, keyboard inset)',
    (site) => site.path != _sheetHelperFile,
    _matches(RegExp(r'\bshowModalBottomSheet\s*(?:<[^()]*>)?\s*\(')),
  ),
  const _Rule(
    'semantics-gesture',
    'a control needs InkWell, AppQuietTap or a button widget, not '
        'GestureDetector',
    _inFeaturesOrApp,
    _semanticsGestures,
  ),
  _Rule(
    'rtl-text-align',
    'use TextAlign.start / end so Arabic mirrors',
    _inFeaturesOrApp,
    _matches(RegExp(r'\bTextAlign\s*\.\s*(?:left|right)\b')),
  ),
  _Rule(
    'rtl-positioned',
    'use PositionedDirectional (start / end) so Arabic mirrors',
    _inFeaturesOrApp,
    _oneSided(RegExp(r'(?<![\w.$])Positioned\s*\(')),
  ),
  _Rule(
    'rtl-edge-insets',
    'use EdgeInsetsDirectional.only (start / end) so Arabic mirrors',
    _inFeaturesOrApp,
    _oneSided(RegExp(r'\bEdgeInsets\s*\.\s*only\s*\(')),
  ),
  const _Rule(
    'rtl-edge-insets-ltrb',
    'use EdgeInsetsDirectional.fromSTEB so Arabic mirrors',
    _inFeaturesOrApp,
    _asymmetricLtrb,
  ),
  _Rule(
    'format-cache',
    'use FormatCache (shared formats, built once per pattern and locale)',
    (site) => site.path != _formatCacheFile,
    _matches(
      RegExp(
        r'(?<![\w$])(?:DateFormat|NumberFormat)\s*'
        r'(?:\.\s*(?!(?:localeExists|allLocalesWithSymbols|'
        r'numberOfIntegerDigits)\b)\w+\s*)?(?:<[^()]*>)?\s*\(',
      ),
    ),
  ),
];

List<int> Function(String) _matches(RegExp pattern) =>
    (code) => <int>[for (final m in pattern.allMatches(code)) m.start];

/// Calls matched by [call] that set `left:` or `right:` differently.
List<int> Function(String) _oneSided(RegExp call) =>
    (code) => <int>[
      for (final m in call.allMatches(code))
        if (_namedArgs(code, m.end - 1) case final args
            when (args.containsKey('left') || args.containsKey('right')) &&
                args['left'] != args['right'])
          m.start,
    ];

final RegExp _fromLtrb = RegExp(r'\bEdgeInsets\s*\.\s*fromLTRB\s*\(');

/// `EdgeInsets.fromLTRB(` whose left and right are written differently.
List<int> _asymmetricLtrb(String code) => <int>[
  for (final m in _fromLtrb.allMatches(code))
    if (_args(code, m.end - 1) case final args
        when args.length == 4 && args[0] != args[2])
      m.start,
];

final RegExp _semantics = RegExp(r'\bSemantics\s*\(');
final RegExp _gestureDetector = RegExp(r'^(?:const\s+)?GestureDetector\s*\(');

List<int> _semanticsGestures(String code) => <int>[
  for (final m in _semantics.allMatches(code))
    if (_namedArgs(code, m.end - 1) case final args
        when (args['button'] == 'true' ||
                args.containsKey('toggled') ||
                args.containsKey('checked')) &&
            _gestureDetector.hasMatch(args['child'] ?? ''))
      m.start,
];

/// The top-level arguments of the call whose `(` is at [open], in order,
/// with whitespace collapsed.
List<String> _args(String code, int open) {
  final args = <String>[];
  var depth = 0;
  var start = open + 1;
  void take(int end) {
    final arg = code.substring(start, end).trim();
    if (arg.isNotEmpty) args.add(arg.replaceAll(RegExp(r'\s+'), ' '));
  }

  for (var i = open; i < code.length; i++) {
    final char = code[i];
    if (char == '(' || char == '[' || char == '{') {
      depth++;
    } else if (char == ')' || char == ']' || char == '}') {
      depth--;
      if (depth == 0) {
        take(i);
        break;
      }
    } else if (char == ',' && depth == 1) {
      take(i);
      start = i + 1;
    }
  }
  return args;
}

/// The top-level named arguments of the call whose `(` is at [open], name
/// to expression text.
Map<String, String> _namedArgs(String code, int open) => <String, String>{
  for (final arg in _args(code, open))
    if (RegExp(r'^(\w+)\s*:(?!:)').firstMatch(arg) case final colon?)
      colon.group(1)!: arg.substring(colon.end).trim(),
};

int _lineOf(String code, int offset) =>
    '\n'.allMatches(code.substring(0, offset)).length + 1;
