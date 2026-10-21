import 'dart:io';

import 'package:test/test.dart';

import '../../tool/check_branding.dart';
import 'fixture.dart';

void main() {
  // Harmless stand-ins: one matched anywhere (length known), one matched as a
  // whole word only (length unknown, as for words inherited as bare hashes).
  final forbidden = <int, Forbidden>{
    fnv1a('zebracorn'): (what: 'the test word', length: 9),
    fnv1a('quokkafish'): (what: 'the whole word', length: null),
  };

  group('scanText', () {
    test('finds a known-length word inside any identifier', () {
      const text =
          'ok\nZebraCorn\nzebra-corn\nzebra_corn\nzebra corn\n'
          'myZebracornTheme\nzebracornApp\nzebra\n';

      final lines = scanText(text, forbidden).map((h) => h.line);

      expect(lines, <int>[2, 3, 4, 5, 6, 7]);
    });

    test('finds a whole-word entry split by case or separators', () {
      const text = 'QuokkaFish\nquokka_fish\nQuokkaFishTheme\nquokka\n';

      final lines = scanText(text, forbidden).map((h) => h.line);

      expect(lines, <int>[1, 2, 3]);
    });
  });

  test('hex renders the unsigned 64-bit value', () {
    expect(hex(fnv1a('')), '0xcbf29ce484222325');
  });

  test('forbids exactly the four project names', () {
    expect(forbiddenHashes.keys.map(hex), <String>{
      '0x5eadf819487cd062',
      '0xe6c31baf3a22899c',
      '0x539a4aca86840e85',
      '0xdf1561aecab2a067',
    });
  });

  group('git scans', () {
    late Fixture fixture;

    void git(List<String> args) {
      final result = Process.runSync('git', <String>[
        ..._isolated,
        ...args,
      ], workingDirectory: fixture.root);
      expect(result.exitCode, 0, reason: '${result.stderr}');
    }

    setUp(() {
      fixture = Fixture();
      git(<String>['init', '-q']);
      git(<String>['config', 'user.email', 'test@example.invalid']);
      git(<String>['config', 'user.name', 'test']);
    });
    tearDown(() => fixture.dispose());

    test('clean tree passes', () {
      fixture.write('README.md', 'clean');

      expect(checkBranding(fixture.root, forbidden: forbidden), isEmpty);
    });

    test('flags content and file names in untracked files', () {
      fixture
        ..write('docs/notes.md', 'line one\nfrom zebracorn\n')
        ..write('lib/zebra_corn.dart');

      final violations = checkBranding(fixture.root, forbidden: forbidden);

      expect(violations, <String>[
        'docs/notes.md:2: names the test word',
        'lib/zebra_corn.dart: the file name names the test word',
      ]);
    });

    test('flags a staged copy that differs from the working tree', () {
      fixture.write('a.md', 'zebracorn');
      git(<String>['add', 'a.md']);
      fixture.write('a.md', 'clean');

      final violations = checkBranding(fixture.root, forbidden: forbidden);

      expect(violations, <String>['a.md (staged):1: names the test word']);
    });

    test('does not crash during a merge conflict', () {
      fixture.write('a.md', 'base');
      git(<String>['add', '.']);
      git(<String>['commit', '-q', '-m', 'base']);
      git(<String>['checkout', '-q', '-b', 'other']);
      fixture.write('a.md', 'theirs');
      git(<String>['commit', '-q', '-am', 'theirs']);
      git(<String>['checkout', '-q', '-']);
      fixture.write('a.md', 'ours zebracorn');
      git(<String>['commit', '-q', '-am', 'ours']);
      Process.runSync('git', <String>[
        ..._isolated,
        'merge',
        'other',
      ], workingDirectory: fixture.root);

      final violations = checkBranding(fixture.root, forbidden: forbidden);

      expect(violations.join(), contains('a.md:'));
    });

    test('skips ignored files, local_dev/ and binary content', () {
      fixture
        ..write('.gitignore', 'build/\n')
        ..write('build/out.txt', 'zebracorn')
        ..write('local_dev/x.md', 'zebracorn');
      File('${fixture.root}/logo.png')
        ..createSync()
        ..writeAsBytesSync(<int>[0, ...'zebracorn'.codeUnits]);

      expect(checkBranding(fixture.root, forbidden: forbidden), isEmpty);
    });

    test('reads text that is not valid UTF-8', () {
      File('${fixture.root}/latin.txt')
        ..createSync()
        ..writeAsBytesSync(<int>[0xe9, 0x20, ...'zebracorn'.codeUnits]);

      expect(checkBranding(fixture.root, forbidden: forbidden), hasLength(1));
    });

    test('reads UTF-16 text with a byte-order mark', () {
      File('${fixture.root}/u16.txt')
        ..createSync()
        ..writeAsBytesSync(<int>[
          0xff,
          0xfe,
          for (final unit in 'x zebracorn'.codeUnits) ...<int>[unit, 0],
        ]);

      expect(checkBranding(fixture.root, forbidden: forbidden), hasLength(1));
    });

    test('history scan flags commit messages and diffs', () {
      fixture.write('a.md', 'clean');
      git(<String>['add', '.']);
      git(<String>['commit', '-q', '-m', 'first']);
      fixture.write('b.md', 'clean');
      git(<String>['add', '.']);
      git(<String>['commit', '-q', '-m', 'port from zebracorn']);

      final violations = checkHistory(
        fixture.root,
        'HEAD~1..HEAD',
        forbidden: forbidden,
      );

      expect(violations, hasLength(1));
      expect(
        checkHistory(fixture.root, 'HEAD~1', forbidden: forbidden),
        isEmpty,
      );
    });
  });
}

/// Keeps a developer's global signing or hooks out of the fixture repos.
const List<String> _isolated = <String>[
  '-c',
  'commit.gpgsign=false',
  '-c',
  'core.hooksPath=/dev/null',
];
