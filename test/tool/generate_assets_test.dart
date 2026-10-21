import 'dart:io';

import 'package:test/test.dart';

import '../../tool/generate_assets.dart';
import 'fixture.dart';

void main() {
  late Fixture fixture;

  setUp(() => fixture = Fixture()..workspace());
  tearDown(() => fixture.dispose());

  const core = 'packages/core';

  void pubspec(List<String> assets) => fixture.write(
    '$core/pubspec.yaml',
    [
      'name: core',
      'flutter:',
      '  uses-material-design: true',
      '  assets:',
      for (final asset in assets) '    - $asset',
      '  fonts:',
      '    - family: Inter',
    ].join('\n'),
  );

  List<String> problemsOf(void Function() generate) {
    try {
      generate();
    } on AssetsException catch (error) {
      return error.problems;
    }
    return const <String>[];
  }

  group('constantName', () {
    test('joins the folder and file name in camelCase', () {
      expect(constantName('assets/icons/arrow_left.svg'), 'iconsArrowLeft');
      expect(
        constantName('assets/images/svgs/account_menu/log-out.svg'),
        'accountMenuLogOut',
      );
      expect(constantName('assets/fonts/inter/OFL.txt'), 'interOfl');
      expect(
        constantName('assets/images/onboarding_1.png'),
        'imagesOnboarding1',
      );
    });
  });

  test('generates sorted constants for declared files', () {
    pubspec(['assets/images/', 'assets/icons/back.svg']);
    fixture
      ..write('$core/assets/images/logo.png')
      ..write('$core/assets/images/banner.png')
      ..write('$core/assets/icons/back.svg');

    final result = generateAssets(fixture.root);

    expect(result.count, 3);
    expect(
      result.source,
      contains(
        '  static const String iconsBack = '
        "'packages/core/assets/icons/back.svg';\n"
        '  static const String imagesBanner = '
        "'packages/core/assets/images/banner.png';\n"
        '  static const String imagesLogo = '
        "'packages/core/assets/images/logo.png';\n",
      ),
    );
  });

  test('skips fonts, hidden files and resolution variants', () {
    pubspec(['assets/images/']);
    fixture
      ..write('$core/assets/images/logo.png')
      ..write('$core/assets/images/2.0x/logo.png')
      ..write('$core/assets/images/3.0x/logo.png')
      ..write('$core/assets/images/.DS_Store')
      ..write('$core/assets/fonts/Inter.ttf');

    final result = generateAssets(fixture.root);

    expect(result.count, 1);
    expect(result.source, isNot(contains('2.0x')));
    expect(result.source, isNot(contains('DS_Store')));
  });

  test('breaks long lines the way dart format does', () {
    pubspec(['assets/images/very_long_folder_name/']);
    const longPath =
        'assets/images/very_long_folder_name/an_illustration_with_a_long_name.png';
    fixture.write('$core/$longPath');

    final lines = generateAssets(fixture.root).source.split('\n');

    final declaration = lines.indexOf(
      '  static const String veryLongFolderNameAnIllustrationWithALongName =',
    );
    expect(declaration, isNot(-1));
    expect(lines[declaration + 1], "      '$core/$longPath';");
  });

  test('fails on a file the pubspec does not bundle', () {
    pubspec(['assets/images/']);
    fixture
      ..write('$core/assets/images/logo.png')
      ..write('$core/assets/images/nested/deep.png');

    expect(
      problemsOf(() => generateAssets(fixture.root)).single,
      contains(
        '$core/assets/images/nested/deep.png: not declared in '
        '$core/pubspec.yaml',
      ),
    );
  });

  test('fails on two files with the same name', () {
    pubspec(['assets/images/']);
    fixture
      ..write('$core/assets/images/logo.png')
      ..write('$core/assets/images/logo.svg');

    expect(
      problemsOf(() => generateAssets(fixture.root)).single,
      contains('"imagesLogo" is also the name of'),
    );
  });

  test('fails on a name that is not a valid identifier', () {
    pubspec(['assets/', 'assets/9/']);
    fixture
      ..write('$core/assets/new.png')
      ..write('$core/assets/9/1.png');

    final problems = problemsOf(() => generateAssets(fixture.root));

    expect(problems, hasLength(2));
    expect(problems, everyElement(contains('is not a valid constant name')));
  });

  test('keeps a valid name for a file at the top of assets/', () {
    pubspec(['assets/']);
    fixture.write('$core/assets/logo.png');

    expect(
      generateAssets(fixture.root).source,
      contains("static const String logo = 'packages/core/assets/logo.png';"),
    );
  });

  test('fails on a variant without its base file', () {
    pubspec(['assets/images/']);
    fixture.write('$core/assets/images/2.0x/logo.png');

    expect(
      problemsOf(() => generateAssets(fixture.root)).single,
      contains('resolution variant without $core/assets/images/logo.png'),
    );
  });

  test('indexes flags by file name instead of one constant each', () {
    pubspec(['assets/flags/', 'assets/icons/']);
    fixture
      ..write('$core/assets/flags/ae.svg')
      ..write('$core/assets/flags/do.svg')
      ..write('$core/assets/icons/back.svg');

    final result = generateAssets(fixture.root);

    expect(result.count, 3);
    expect(result.source, isNot(contains('flagsAe')));
    expect(
      result.source,
      contains(
        '  /// `packages/core/assets/flags/` by file name.\n'
        '  static const Map<String, String> flags = <String, String>{\n'
        "    'ae': 'packages/core/assets/flags/ae.svg',\n"
        "    'do': 'packages/core/assets/flags/do.svg',\n"
        '  };\n',
      ),
    );
  });

  test('indexed files must still be declared', () {
    pubspec(['assets/icons/']);
    fixture
      ..write('$core/assets/icons/back.svg')
      ..write('$core/assets/flags/ae.svg');

    expect(
      problemsOf(() => generateAssets(fixture.root)).single,
      contains('$core/assets/flags/ae.svg: not declared'),
    );
  });

  test('fails on two indexed files with the same name', () {
    pubspec(['assets/flags/']);
    fixture
      ..write('$core/assets/flags/ae.png')
      ..write('$core/assets/flags/ae.svg');

    expect(
      problemsOf(() => generateAssets(fixture.root)).single,
      contains('"ae" is also the name of $core/assets/flags/ae.png'),
    );
  });

  test('fails when an index map clashes with a constant', () {
    pubspec(['assets/', 'assets/flags/']);
    fixture
      ..write('$core/assets/flags.png')
      ..write('$core/assets/flags/ae.svg');

    expect(
      problemsOf(() => generateAssets(fixture.root)).single,
      contains('"flags" is also the name of $core/assets/flags.png'),
    );
  });

  group('declaredAssets', () {
    Set<String> parse(String pubspec) {
      fixture.write('$core/pubspec.yaml', pubspec);
      return declaredAssets(File('${fixture.root}/$core/pubspec.yaml'));
    }

    test('reads quoted, commented and path entries', () {
      expect(
        parse('''
name: app
flutter:
  uses-material-design: true
# a column-0 comment
  assets:
    - assets/a/ # inline comment
    - 'assets/b/'
    - "assets/c.png"
    - path: assets/d/
      flavors:
        - dev
  fonts:
    - family: Inter
'''),
        <String>{'assets/a/', 'assets/b/', 'assets/c.png', 'assets/d/'},
      );
    });

    test('reads other indents, same-indent lists and inline lists', () {
      expect(
        parse('flutter:\n    assets:\n    - assets/a/\n    - assets/b/\n'),
        <String>{'assets/a/', 'assets/b/'},
      );
      expect(
        parse("flutter:\n  assets: [assets/a/, 'assets/b.png']\n"),
        <String>{'assets/a/', 'assets/b.png'},
      );
    });

    test('reads CRLF files and ignores assets outside flutter:', () {
      expect(
        parse('assets:\r\n  - nope/\r\nflutter:\r\n  assets:\r\n    - a/\r\n'),
        <String>{'a/'},
      );
    });
  });

  test('skips hidden folders', () {
    pubspec(['assets/images/']);
    fixture
      ..write('$core/assets/images/logo.png')
      ..write('$core/assets/.cache/tmp.png');

    expect(generateAssets(fixture.root).count, 1);
  });

  test('writes an empty class when there are no assets', () {
    pubspec(<String>[]);

    expect(
      generateAssets(fixture.root).source,
      endsWith('abstract final class Assets {}\n'),
    );
  });

  group('check', () {
    setUp(() {
      pubspec(['assets/images/']);
      fixture.write('$core/assets/images/logo.png');
    });

    test('passes when the file is current and used', () {
      final source = generateAssets(fixture.root).source;
      fixture
        ..write(outputPath, source)
        ..write('apps/customer/lib/a.dart', 'final logo = Assets.imagesLogo;');

      expect(checkAssets(fixture.root, source), isEmpty);
    });

    test('fails when the file is missing or stale', () {
      final source = generateAssets(fixture.root).source;

      expect(checkAssets(fixture.root, source).single, contains('out of date'));

      fixture.write(outputPath, '// old');
      expect(checkAssets(fixture.root, source).single, contains('out of date'));
    });

    test('accepts CRLF line endings', () {
      final source = generateAssets(fixture.root).source;
      fixture.write(outputPath, source.replaceAll('\n', '\r\n'));

      expect(checkAssets(fixture.root, source), isEmpty);
    });

    test('ignores asset paths in comments', () {
      final source = generateAssets(fixture.root).source;
      fixture
        ..write(outputPath, source)
        ..write('apps/customer/lib/a.dart', "// was 'assets/images/logo.png'");

      expect(checkAssets(fixture.root, source), isEmpty);
    });

    test('fails on a raw asset path in any package lib/', () {
      final source = generateAssets(fixture.root).source;
      fixture
        ..write(outputPath, source)
        ..write('apps/customer/lib/a.dart', "final a = 'assets/images/a.png';")
        ..write(
          'packages/core/lib/b.dart',
          "final b = 'packages/core/assets/images/b.png';",
        )
        ..write('apps/rider/test/c_test.dart', "final c = 'assets/c.png';")
        ..write('packages/core/lib/vendor/v.dart', "final x = 'assets/x.png';")
        ..write(
          'apps/rider/lib/l10n/generated/l.dart',
          "final x = 'assets/x.png';",
        );

      expect(checkAssets(fixture.root, source), <String>[
        '  apps/customer/lib/a.dart:1: use an Assets constant, not a path',
        '  packages/core/lib/b.dart:1: use an Assets constant, not a path',
      ]);
    });
  });

  test('the committed file matches this workspace', () {
    final root = Directory.current.path;

    expect(
      checkAssets(root, generateAssets(root).source),
      isEmpty,
    );
  });
}
