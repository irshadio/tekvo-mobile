import 'package:test/test.dart';

import '../../tool/check_duplicates.dart';
import 'fixture.dart';

const _a = 'apps/customer/lib/features/a/presentation/view/widgets';
const _b = 'apps/customer/lib/features/b/presentation/view/widgets';

/// [count] distinct, non-blank statement lines.
String _block(int count, {String prefix = 'x'}) =>
    List.generate(count, (i) => '  final $prefix$i = $i;').join('\n');

String _fn(String body) => 'void f() {\n$body\n}\n';

void main() {
  late Fixture fixture;

  setUp(() => fixture = Fixture()..workspace());
  tearDown(() => fixture.dispose());

  List<String> check({
    Map<String, SharedName> classes = const {},
    Map<String, String> lines = const {},
  }) => checkDuplicates(
    fixture.root,
    classAllow: classes,
    linesAllow: lines,
  );

  group('class', () {
    test('a name in two features fails, a leading underscore ignored', () {
      fixture
        ..write('$_a/one.dart', 'class Card {}')
        ..write('$_b/two.dart', 'class _Card extends X {}')
        ..write('$_a/kind.dart', 'enum Kind { x }')
        ..write('$_b/kind.dart', 'sealed class Kind {}')
        ..write('$_a/m.dart', 'mixin M {}')
        ..write('$_b/m.dart', 'abstract mixin class _M {}');

      final violations = check();

      expect(violations, hasLength(3));
      expect(violations.first, contains('$_a/one.dart'));
      expect(violations.first, contains('$_b/two.dart'));
      expect(
        violations.first,
        contains('class: declared in features {customer/a, customer/b}'),
      );
    });

    test('the same name twice inside one feature passes', () {
      fixture
        ..write('$_a/one.dart', 'class _Card {}')
        ..write('apps/customer/lib/features/a/data/two.dart', 'class Card {}');

      expect(check(), isEmpty);
    });

    test('nested, commented, quoted and generated declarations are '
        'skipped, as are core/ and app/', () {
      fixture
        ..write('$_a/one.dart', 'class Card {}')
        ..write('$_b/nested.dart', 'void f() {\nclass Card {}\n}')
        ..write('$_b/indented.dart', '  class Card {}')
        ..write('$_b/comment.dart', '// class Card {}\n/*\nclass Card {}\n*/')
        ..write('$_b/string.dart', "const s = '''\nclass Card {}\n''';")
        ..write('$_b/x.g.dart', 'class Card {}')
        ..write('$_b/x.freezed.dart', 'class Card {}')
        ..write('packages/core/lib/card.dart', 'class Card {}')
        ..write('apps/customer/lib/app/card.dart', 'class Card {}');

      expect(check(), isEmpty);
    });

    test('an entry naming the exact features suppresses the hit', () {
      fixture
        ..write('$_a/one.dart', 'class _Card {}')
        ..write('$_b/two.dart', 'class _Card {}');

      expect(
        check(
          classes: {
            'Card': (features: {'customer/a', 'customer/b'}, reason: 'r'),
          },
        ),
        isEmpty,
      );
    });

    test('an entry naming other features does not', () {
      fixture
        ..write('$_a/one.dart', 'class _Card {}')
        ..write('$_b/two.dart', 'class _Card {}')
        ..write('apps/customer/lib/features/c/three.dart', 'class _Card {}');

      final violations = check(
        classes: {
          'Card': (features: {'customer/a', 'customer/b'}, reason: 'r'),
        },
      );

      expect(violations, hasLength(1));
      expect(
        violations.single,
        contains(
          'features {customer/a, customer/b, customer/c}, not the listed '
          'features {customer/a, customer/b}',
        ),
      );
    });

    test('an entry naming as many, but different, features does not', () {
      fixture
        ..write('$_a/one.dart', 'class _Card {}')
        ..write('apps/customer/lib/features/c/three.dart', 'class _Card {}');

      final violations = check(
        classes: {
          'Card': (features: {'customer/a', 'customer/b'}, reason: 'r'),
        },
      );

      expect(violations, hasLength(1));
      expect(
        violations.single,
        contains(
          'features {customer/a, customer/c}, not the listed features '
          '{customer/a, customer/b}',
        ),
      );
    });

    test('an entry whose name is no longer shared is stale', () {
      fixture.write('$_a/one.dart', 'class _Card {}');

      final violations = check(
        classes: {
          'Card': (features: {'customer/a', 'customer/b'}, reason: 'r'),
        },
      );

      expect(violations, hasLength(1));
      expect(violations.single, contains('stale allow-list entry'));
    });
  });

  group('lines', () {
    test('$minRun identical lines in two features fail, naming both '
        'spans', () {
      fixture
        ..write('$_a/one.dart', _fn(_block(minRun)))
        ..write('$_b/two.dart', 'int y = 0;\n\n${_fn(_block(minRun))}');

      final violations = check();

      expect(violations, hasLength(1));
      expect(violations.single, contains('$_a/one.dart:1-22'));
      expect(violations.single, contains('$_b/two.dart:3-24'));
      expect(violations.single, contains('lines: 22 identical lines'));
    });

    test('${minRun - 1} identical lines pass', () {
      fixture
        ..write('$_a/one.dart', _block(minRun - 1))
        ..write('$_b/two.dart', _block(minRun - 1));

      expect(check(), isEmpty);
    });

    test('blank lines, comments, indentation and directives are ignored', () {
      final lines = _block(minRun).split('\n');
      final spaced = <String>[
        for (final (i, line) in lines.indexed) ...[
          if (i.isEven) '' else '    // note $i',
          '    ${line.trim()}',
        ],
      ];
      fixture
        ..write('$_a/one.dart', "import 'a.dart';\n${lines.join('\n')}")
        ..write(
          '$_b/two.dart',
          "import 'b.dart';\nexport 'c.dart';\n${spaced.join('\n')}",
        );

      expect(check(), hasLength(1));
    });

    test('the same lines inside one feature, or outside features/, '
        'pass', () {
      fixture
        ..write('$_a/one.dart', _block(minRun))
        ..write('apps/customer/lib/features/a/data/two.dart', _block(minRun))
        ..write('packages/core/lib/three.dart', _block(minRun))
        ..write('$_b/x.g.dart', _block(minRun));

      expect(check(), isEmpty);
    });

    test('an entry suppresses its pair, in either order', () {
      fixture
        ..write('$_a/one.dart', _block(minRun))
        ..write('$_b/two.dart', _block(minRun));

      expect(check(lines: {'$_a/one.dart|$_b/two.dart': 'r'}), isEmpty);
      expect(check(lines: {'$_b/two.dart|$_a/one.dart': 'r'}), isEmpty);
    });

    test('an entry whose files no longer share the lines is stale', () {
      fixture
        ..write('$_a/one.dart', _block(minRun))
        ..write('$_b/two.dart', _block(minRun, prefix: 'y'));

      final violations = check(lines: {'$_a/one.dart|$_b/two.dart': 'r'});

      expect(violations, hasLength(1));
      expect(violations.single, contains('stale allow-list entry'));
    });
  });

  group('between apps', () {
    const rider = 'apps/rider/lib/features/a/presentation/view/widgets';

    test('a feature of the same name in two apps is two features', () {
      fixture
        ..write('$_a/one.dart', 'class Card {}')
        ..write('$rider/one.dart', 'class Card {}');

      expect(
        check().single,
        contains('class: declared in features {customer/a, rider/a}'),
      );
    });

    test("one app's app/, routing/ and main compare with another app's "
        'code, not their own', () {
      fixture
        ..write('apps/customer/lib/app/run_app.dart', 'class Runner {}')
        ..write('apps/customer/lib/main.dart', 'class Runner {}')
        ..write('apps/customer/lib/routing/routes.dart', _block(minRun))
        ..write('$_a/one.dart', _block(minRun))
        ..write('apps/rider/lib/routing/routes.dart', _block(minRun))
        ..write('apps/rider/lib/app/run_app.dart', 'class Runner {}');

      final violations = check();

      expect(violations, hasLength(3));
      expect(
        violations.first,
        contains('class: declared in features {customer, rider}'),
      );
      expect(
        violations.where((v) => v.contains('apps/rider/lib/routing/')),
        hasLength(2),
      );
    });

    test('an entry naming app units suppresses the hit', () {
      fixture
        ..write('apps/customer/lib/app/app_shell.dart', 'class Shell {}')
        ..write('apps/rider/lib/app/app_shell.dart', 'class Shell {}');

      expect(
        check(
          classes: {
            'Shell': (features: {'customer', 'rider'}, reason: 'r'),
          },
        ),
        isEmpty,
      );
    });

    test('packages without lib/app/ are not scanned', () {
      fixture
        ..write('packages/core/lib/features/a/one.dart', 'class Card {}')
        ..write('$_a/one.dart', 'class Card {}');

      expect(check(), isEmpty);
    });
  });
}
