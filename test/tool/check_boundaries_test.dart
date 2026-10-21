import 'dart:io';

import 'package:test/test.dart';

import '../../tool/check_boundaries.dart';
import 'fixture.dart';

void main() {
  late Fixture fixture;

  setUp(() => fixture = Fixture()..workspace());
  tearDown(() => fixture.dispose());

  String imports(String uri) => "import '$uri';\n";
  const rc = 'package:core/vendor/remote_client/remote_client.dart';

  test('clean tree passes', () {
    fixture
      ..write(
        'apps/customer/lib/main.dart',
        imports('package:customer/app/app.dart'),
      )
      ..write(
        'apps/customer/lib/app/app.dart',
        imports('package:customer/features/a/a.dart'),
      )
      ..write(
        'packages/core/lib/x.dart',
        imports(rc) + imports('package:dio/dio.dart'),
      )
      ..write('packages/core/lib/vendor/v/v.dart', imports('src/w.dart'))
      ..write(
        'packages/core/lib/vendor/v/src/w.dart',
        imports('../../other/o.dart'),
      )
      ..write(
        'apps/customer/lib/features/a/data/sources/a_remote_data_source.dart',
        imports(rc) +
            imports('package:customer/features/a/domain/entities/a.dart'),
      )
      ..write(
        'apps/customer/lib/features/a/domain/entities/a.dart',
        "part 'a.freezed.dart';\n",
      )
      ..write(
        'packages/core/lib/state/remote_state_mixin.dart',
        r'mixin M on $Notifier<int> {}',
      )
      ..write(
        'packages/core/lib/state/mutation_state_mixin.dart',
        r'mixin N on $Notifier<int> {}',
      )
      ..write(
        'packages/core/lib/y.dart',
        r'/// Never extend $Notifier or setState(.',
      );

    expect(checkBoundaries(fixture.root), isEmpty);
  });

  test('flags every rule', () {
    fixture
      ..write(
        'packages/core/lib/vendor/v/v.dart',
        imports('package:core/x.dart'),
      )
      ..write(
        'packages/core/lib/x.dart',
        imports('package:customer/app/app.dart'),
      )
      ..write(
        'apps/customer/lib/features/a/presentation/view/a_view.dart',
        imports('package:customer/features/b/b.dart') +
            imports('package:customer/app/app.dart') +
            imports(rc),
      )
      ..write(
        'apps/customer/lib/features/a/domain/entities/a.dart',
        imports('package:customer/features/a/data/dtos/a_dto.dart'),
      )
      ..write(
        'apps/customer/lib/features/a/data/dtos/a_dto.dart',
        "export 'package:customer/features/a/presentation/view/a_view.dart';",
      )
      ..write(
        'apps/customer/lib/features/a/a_overrides.dart',
        imports('../../core/x.dart'),
      )
      ..write('packages/core/lib/y.dart', r'class Y extends $Notifier<int> {}')
      ..write(
        'packages/core/lib/state/view_state.dart',
        r'typedef T = $Notifier<int>;',
      );

    final violations = checkBoundaries(fixture.root).join('\n');

    expect(violations, contains('vendored code may not import core'));
    expect(violations, contains('core may not import app'));
    expect(violations, contains('feature "a" may not import feature "b"'));
    expect(violations, contains('features may not import app'));
    expect(violations, contains("a feature's data/ layer"));
    expect(violations, contains('domain may not import data'));
    expect(violations, contains('data may not import presentation'));
    expect(violations, contains('relative import'));
    expect(RegExp(r'names \$Notifier').allMatches(violations), hasLength(2));
  });

  test('generated localizations may use relative imports', () {
    fixture
      ..write(
        'packages/core/lib/l10n/generated/app_localizations.dart',
        imports('app_localizations_en.dart'),
      )
      ..write('packages/core/lib/l10n/x.dart', imports('generated/x.dart'));

    final violations = checkBoundaries(fixture.root);

    expect(violations, hasLength(1));
    expect(violations.single, contains('packages/core/lib/l10n/x.dart'));
  });

  test('vendored code cannot escape through a relative import', () {
    fixture.write(
      'packages/core/lib/vendor/v/v.dart',
      imports('../../core/x.dart'),
    );

    expect(
      checkBoundaries(fixture.root).join(),
      contains('vendored code may not reach outside lib/vendor/'),
    );
  });

  test('conditional and multi-line imports are checked', () {
    fixture
      ..write(
        'packages/core/lib/x.dart',
        "import 'package:core/y.dart'\n"
            "    if (dart.library.io) 'package:customer/app/app.dart';\n",
      )
      ..write(
        'apps/customer/lib/features/a/presentation/view/a_view.dart',
        "import\n    'package:customer/features/b/b.dart';\n",
      );

    final violations = checkBoundaries(fixture.root).join('\n');

    expect(violations, contains('core may not import app'));
    expect(violations, contains('feature "a" may not import feature "b"'));
  });

  test('transport types stay in data/ and are never re-exported', () {
    fixture
      ..write(
        'apps/customer/lib/features/a/presentation/view/a_view.dart',
        imports('package:dio/dio.dart'),
      )
      ..write(
        'apps/customer/lib/features/a/data/sources/x.dart',
        "export '$rc';",
      );

    final violations = checkBoundaries(fixture.root).join('\n');

    expect(violations, contains("a feature's data/ layer"));
    expect(violations, contains('only vendor/ may re-export transport types'));
  });

  test('banned packages and APIs fail', () {
    fixture
      ..write(
        'apps/customer/lib/app/app.dart',
        imports('package:go_router/go_router.dart'),
      )
      ..write('packages/core/lib/e.dart', imports('package:dartz/dartz.dart'))
      ..write(
        'apps/customer/lib/features/a/presentation/view/a_view.dart',
        'void f() { setState(() {}); }',
      )
      ..write(
        'apps/customer/lib/features/a/presentation/view_model/a_view_model.dart',
        'Future<void> f() => Future.delayed(Duration.zero);',
      );

    final violations = checkBoundaries(fixture.root).join('\n');

    expect(
      RegExp('banned package').allMatches(violations),
      hasLength(2),
    );
    expect(violations, contains('calls setState'));
    expect(violations, contains('Future.delayed in a ViewModel'));
  });

  test('banned calls are caught in every spelling', () {
    fixture
      ..write(
        'apps/customer/lib/features/a/presentation/view/a_view.dart',
        'void f() { setState (() {}); }',
      )
      ..write(
        'apps/customer/lib/features/a/presentation/view_model/a_view_model.dart',
        'Future<void> f() => Future<List<int>>.delayed(Duration.zero);',
      );

    final violations = checkBoundaries(fixture.root).join('\n');

    expect(violations, contains('calls setState'));
    expect(violations, contains('Future.delayed in a ViewModel'));
  });

  test('only vendor/ may re-export transport types', () {
    fixture
      ..write('packages/core/lib/net.dart', "export 'package:dio/dio.dart';")
      ..write(
        'packages/core/lib/vendor/v/v.dart',
        "export 'package:dio/dio.dart';",
      );

    final violations = checkBoundaries(fixture.root);

    expect(violations, hasLength(1));
    expect(violations.single, contains('packages/core/lib/net.dart'));
  });

  test('comments and strings never count as code', () {
    fixture.write(
      'packages/core/lib/a.dart',
      "/*\nimport 'package:customer/app/x.dart';\n/* nested */\n*/\n"
          "const s = '''\nexport 'package:customer/features/z/z.dart';\n''';\n"
          r"const t = r'$Notifier setState(';"
          '\nvoid f() {} // setState(() {}) was removed\n',
    );

    expect(checkBoundaries(fixture.root), isEmpty);
  });

  test('dot segments in a package URI cannot hide the target', () {
    fixture.write(
      'apps/customer/lib/features/a/presentation/view/a_view.dart',
      imports('package:customer/features/a/../../app/app.dart') +
          imports('package:customer/features/a/../b/x.dart'),
    );

    final violations = checkBoundaries(fixture.root).join('\n');

    expect(violations, contains('features may not import app'));
    expect(violations, contains('feature "a" may not import feature "b"'));
  });

  test('dot segments and raw strings cannot smuggle in transport types', () {
    fixture
      ..write(
        'apps/customer/lib/features/a/presentation/view/a_view.dart',
        imports('package:core/state/../vendor/remote_client/rc.dart'),
      )
      ..write(
        'apps/customer/lib/features/a/presentation/view/b_view.dart',
        "import r'package:dio/dio.dart';",
      )
      ..write(
        'apps/customer/lib/features/a/presentation/view/c_view.dart',
        "@A(B()) import 'package:dio/dio.dart';",
      );

    final violations = checkBoundaries(fixture.root).join('\n');

    for (final view in <String>['a_view', 'b_view', 'c_view']) {
      expect(violations, contains('$view.dart'));
    }
  });

  test('a comment inside an interpolation masks nothing else', () {
    fixture.write(
      'packages/core/lib/a.dart',
      "final s = '\${a /* ' */}';\nvoid f() { setState(() {}); }\n",
    );

    expect(checkBoundaries(fixture.root).join(), contains('calls setState'));
  });

  test('transport types are confined outside the known zones too', () {
    fixture
      ..write('apps/customer/lib/main.dart', imports('package:dio/dio.dart'))
      ..write(
        'apps/customer/lib/app/app.dart',
        imports('package:dio/dio.dart'),
      );

    final violations = checkBoundaries(fixture.root);

    expect(violations, hasLength(1));
    expect(violations.single, contains('apps/customer/lib/main.dart'));
  });

  test('a brace in a string nested in an interpolation masks nothing else', () {
    fixture.write(
      'packages/core/lib/a.dart',
      "final s = '\${m['{']}';\nvoid f() { setState(() {}); }\n",
    );

    expect(checkBoundaries(fixture.root).join(), contains('calls setState'));
  });

  test(r'$Notifier is a whole word; setState tear-offs count', () {
    fixture
      ..write(
        'packages/core/lib/a.dart',
        r'class A extends $NotifierProviderElement {}',
      )
      ..write('packages/core/lib/b.dart', 'void f(g) => g(setState);');

    final violations = checkBoundaries(fixture.root);

    expect(violations, hasLength(1));
    expect(violations.single, contains('calls setState'));
  });

  test('parts stay in their directory', () {
    fixture
      ..write(
        'packages/core/lib/a.dart',
        "part 'a.g.dart';\npart 'sub/b.dart';",
      )
      ..write('packages/core/lib/c.dart', "part '../app/x.dart';");

    final violations = checkBoundaries(fixture.root).join('\n');

    expect(
      RegExp('a part must live in the same directory').allMatches(violations),
      hasLength(2),
    );
  });

  test('every directive is found, and only directives', () {
    fixture
      ..write(
        'packages/core/lib/a.dart',
        "import 'dart:io'; import 'package:customer/app/app.dart';\n"
            "@Deprecated('x') import 'package:customer/features/z/z.dart';\n",
      )
      ..write(
        'apps/customer/lib/features/a/presentation/view/a_view.dart',
        "void f() => g(\n  export: 'package:dio/dio.dart',\n);\n"
            "var import = 'package:dio/dio.dart';\n",
      )
      ..write(
        'apps/customer/lib/features/a/presentation/view/b_view.dart',
        "import 'package:di' 'o/dio.dart';",
      );

    final violations = checkBoundaries(fixture.root).join('\n');

    expect(RegExp('core may not import').allMatches(violations), hasLength(2));
    expect(violations, isNot(contains('a_view.dart')));
    expect(violations, contains('b_view.dart\n    imports package:dio/'));
  });

  group('directiveUris', () {
    test('joins adjacent pieces and keeps conditional URIs', () {
      expect(
        directiveUris(
          " 'package:a/' 'b.dart'\n    if (dart.library.io) 'package:c/d.dart'"
          ' as x show y',
        ),
        <String>['package:a/b.dart', 'package:c/d.dart'],
      );
    });
  });

  group('maskDart', () {
    test('keeps length and line breaks', () {
      const source = "a /* b\nc */ 'd' // e\nf";

      expect(maskDart(source).length, source.length);
      expect(maskDart(source, strings: true).split('\n'), hasLength(3));
    });

    test('keeps URIs unless strings are masked', () {
      const source = "import 'package:x/y.dart'; // z";

      expect(maskDart(source), "import 'package:x/y.dart';     ");
      expect(maskDart(source, strings: true), startsWith("import '      "));
    });

    test('handles escapes and interpolation', () {
      const source = r"final s = 'it\'s ${m['k']}'; setState(";

      expect(maskDart(source, strings: true), endsWith("'; setState("));
      expect(maskDart(source, strings: true), isNot(contains('k')));
    });
  });

  test('generated files are skipped', () {
    fixture.write(
      'packages/core/lib/x.g.dart',
      r'class X extends $Notifier<int> {}',
    );

    expect(checkBoundaries(fixture.root), isEmpty);
  });

  test('a file that is not UTF-8 is reported, not a crash', () {
    File('${fixture.root}/packages/core/lib/bad.dart')
      ..createSync(recursive: true)
      ..writeAsBytesSync(<int>[0xff, 0xfe, 0x00]);

    expect(checkBoundaries(fixture.root).join(), contains('not UTF-8'));
  });
}
