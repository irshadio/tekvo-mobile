/// Fails the gate when this repository names another client's project.
///
/// Forbidden words are stored as FNV-1a/64 hashes so this file never spells
/// them out. The hash only keeps the plaintext out of the tree; it is not a
/// security measure.
///
///     dart run tool/check_branding.dart                    # working tree
///     dart run tool/check_branding.dart --history <range>  # commits + messages
///     dart run tool/check_branding.dart --hash <word>      # add a word
///
/// The working-tree scan covers every file git would track (tracked plus
/// untracked, minus ignored), their file names, and the staged copy of any
/// file whose index content differs from the working tree.
library;

import 'dart:convert';
import 'dart:io';

/// A forbidden word: what it IS (never what it says) and its length.
///
/// With a length, the word is found anywhere in a line once separators are
/// removed (`myWordTheme`, `word-x`). Without one, only whole words and
/// adjacent word pairs are compared.
typedef Forbidden = ({String what, int? length});

const Map<int, Forbidden> forbiddenHashes = <int, Forbidden>{
  0x5eadf819487cd062: (what: 'another project (short name)', length: null),
  0xe6c31baf3a22899c: (what: 'another project (name)', length: 6),
  0x539a4aca86840e85: (what: 'another project (name)', length: null),
  0xdf1561aecab2a067: (what: 'another project (name)', length: 8),
};

Future<void> main(List<String> args) async {
  if (args.length == 2 && args.first == '--hash') {
    final word = _squash(args[1]);
    stdout.writeln(
      "  ${hex(fnv1a(word))}: (what: '<what it is>', length: ${word.length}),",
    );
    return;
  }

  final root = Directory.current.path;
  final List<String> violations;
  if (args.length == 2 && args.first == '--history') {
    violations = checkHistory(root, args[1]);
  } else if (args.isEmpty) {
    violations = checkBranding(root);
  } else {
    stderr.writeln(
      'Usage: check_branding.dart [--history <range> | --hash <word>]',
    );
    exit(64);
  }

  if (violations.isEmpty) {
    stdout.writeln('OK: no other project is named.');
    return;
  }
  stderr
    ..writeln(
      "This repository must not name another client's project. Refer to it\n"
      'by role ("the reference project") instead:\n',
    )
    ..writeln(violations.map((v) => '  $v').join('\n'));
  exit(1);
}

/// Scans the files git would track under [root].
List<String> checkBranding(
  String root, {
  Map<int, Forbidden> forbidden = forbiddenHashes,
}) {
  // Unmerged paths have no single staged copy; their working copy is scanned.
  final unmerged = _split(
    _git(root, <String>['ls-files', '-u', '-z']),
  ).map((entry) => entry.split('\t').last).toSet();
  final unstaged = _split(
    _git(root, <String>['diff', '--name-only', '-z']),
  ).difference(unmerged);
  final violations = <String>[];

  void scan(String label, List<int> bytes) {
    final text = _decode(bytes);
    if (text == null) return;
    for (final hit in scanText(text, forbidden)) {
      violations.add('$label:${hit.line}: names ${hit.what}');
    }
  }

  for (final path in _gitFiles(root)) {
    if (path.startsWith('local_dev/')) continue;

    final nameHit = _firstHit(path, forbidden);
    if (nameHit != null) violations.add('$path: the file name names $nameHit');

    final file = File('$root/$path');
    if (file.existsSync()) scan(path, file.readAsBytesSync());
    if (unstaged.contains(path)) {
      scan('$path (staged)', _gitBytes(root, <String>['show', ':$path']));
    }
  }
  return violations..sort();
}

/// Scans every commit in [range]: message, diff and file names.
List<String> checkHistory(
  String root,
  String range, {
  Map<int, Forbidden> forbidden = forbiddenHashes,
}) {
  final shas = _git(root, <String>[
    'rev-list',
    range,
  ]).split('\n').where((s) => s.isNotEmpty);
  final violations = <String>[];
  for (final sha in shas) {
    final text = _git(root, <String>['show', '--format=%B', sha]);
    for (final hit in scanText(text, forbidden)) {
      violations.add(
        'commit ${sha.substring(0, 8)} (line ${hit.line}): names ${hit.what}',
      );
    }
  }
  return violations;
}

/// 1-based line numbers of [text] that carry a forbidden word.
List<({int line, String what})> scanText(
  String text,
  Map<int, Forbidden> forbidden,
) {
  final hits = <({int line, String what})>[];
  final lines = text.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final what = _firstHit(lines[i], forbidden);
    if (what != null) hits.add((line: i + 1, what: what));
  }
  return hits;
}

String? _firstHit(String text, Map<int, Forbidden> forbidden) {
  final squashed = _squash(text);
  final lengths = forbidden.values.map((f) => f.length).nonNulls.toSet();
  for (final length in lengths) {
    for (var start = 0; start + length <= squashed.length; start++) {
      final entry = forbidden[fnv1a(squashed.substring(start, start + length))];
      if (entry != null && entry.length == length) return entry.what;
    }
  }
  for (final token in tokens(text)) {
    final entry = forbidden[fnv1a(token)];
    if (entry != null && entry.length == null) return entry.what;
  }
  return null;
}

/// Lowercase with everything but letters and digits removed.
String _squash(String text) =>
    text.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

/// Lowercased words, split at separators and camelCase humps, plus each
/// adjacent pair joined and each unsplit alphanumeric run.
Iterable<String> tokens(String text) sync* {
  final runs = RegExp('[A-Za-z0-9]+').allMatches(text).map((m) => m.group(0)!);
  final words = <String>[];
  for (final run in runs) {
    yield run.toLowerCase();
    words.addAll(
      RegExp(
        '[A-Z]+(?![a-z])|[A-Z]?[a-z]+|[0-9]+',
      ).allMatches(run).map((m) => m.group(0)!.toLowerCase()),
    );
  }
  for (var i = 0; i < words.length; i++) {
    yield words[i];
    if (i + 1 < words.length) yield words[i] + words[i + 1];
  }
}

/// 64-bit FNV-1a. Dart ints wrap at 64 bits, so no masking is needed.
int fnv1a(String s) {
  var hash = 0xcbf29ce484222325;
  for (final unit in s.codeUnits) {
    hash ^= unit;
    hash *= 0x100000001b3;
  }
  return hash;
}

/// Unsigned 64-bit hex, as the constants are written.
String hex(int h) {
  final high = (h >> 32) & 0xFFFFFFFF;
  final low = h & 0xFFFFFFFF;
  return '0x${high.toRadixString(16).padLeft(8, '0')}'
      '${low.toRadixString(16).padLeft(8, '0')}';
}

List<String> _gitFiles(String root) => _split(
  _git(root, <String>[
    'ls-files',
    '--cached',
    '--others',
    '--exclude-standard',
    '-z',
  ]),
).toList();

Set<String> _split(String nulSeparated) =>
    nulSeparated.split('\x00').where((p) => p.isNotEmpty).toSet();

String _git(String root, List<String> args) =>
    _decode(_gitBytes(root, args), binaryAsNull: false)!;

List<int> _gitBytes(String root, List<String> args) {
  final result = Process.runSync(
    'git',
    args,
    workingDirectory: root,
    stdoutEncoding: null,
  );
  if (result.exitCode != 0) {
    throw ProcessException('git', args, '${result.stderr}', result.exitCode);
  }
  return result.stdout as List<int>;
}

/// Text of [bytes] (UTF-16 with a byte-order mark, else UTF-8 with malformed
/// sequences replaced), or null for binary content.
String? _decode(List<int> bytes, {bool binaryAsNull = true}) {
  if (bytes.length >= 2) {
    final littleEndian = bytes[0] == 0xff && bytes[1] == 0xfe;
    final bigEndian = bytes[0] == 0xfe && bytes[1] == 0xff;
    if (littleEndian || bigEndian) {
      final (low, high) = littleEndian ? (0, 1) : (1, 0);
      return String.fromCharCodes(<int>[
        for (var i = 2; i + 1 < bytes.length; i += 2)
          bytes[i + low] | (bytes[i + high] << 8),
      ]);
    }
  }
  if (binaryAsNull && bytes.contains(0)) return null;
  return const Utf8Decoder(allowMalformed: true).convert(bytes);
}
