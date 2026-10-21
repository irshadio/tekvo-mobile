import 'dart:io';

import 'package:test/test.dart';

import '../../tool/check_boundaries.dart';
import 'fixture.dart';

/// Rules that exist because the code is split into workspace packages.
void main() {
  late Fixture fixture;

  setUp(() => fixture = Fixture()..workspace());
  tearDown(() => fixture.dispose());

  String imports(String uri) => "import '$uri';\n";
  const view = 'apps/customer/lib/features/a/presentation/view';

  test('core never imports an app package', () {
    fixture
      ..write('packages/core/lib/a.dart', imports('package:customer/main.dart'))
      ..write(
        'packages/core/lib/b.dart',
        imports('package:rider/features/a/a.dart'),
      );

    final violations = checkBoundaries(fixture.root).join('\n');

    expect(violations, contains('core may not import app package "customer"'));
    expect(violations, contains('core may not import app package "rider"'));
  });

  test('an app never imports another app', () {
    fixture
      ..write(
        'apps/customer/lib/main.dart',
        imports('package:customer/app/app.dart') +
            imports('package:rider/app/app.dart'),
      )
      ..write('$view/a_view.dart', imports('package:rider/features/a/a.dart'));

    final violations = checkBoundaries(fixture.root).join('\n');

    expect(
      RegExp('app "customer" may not import app "rider"').allMatches(
        violations,
      ),
      hasLength(2),
    );
  });

  test('a relative import names its own package', () {
    fixture.write('apps/rider/lib/main.dart', imports('app/app.dart'));

    expect(
      checkBoundaries(fixture.root).join(),
      contains('relative import; use package:rider/...'),
    );
  });

  test('the hosted remote_client is a transport type too', () {
    fixture
      ..write(
        'packages/core/lib/n.dart',
        imports('package:remote_client/remote_client.dart'),
      )
      ..write(
        '$view/a_view.dart',
        imports('package:remote_client/remote_client.dart'),
      );

    final violations = checkBoundaries(fixture.root);

    expect(violations, hasLength(1));
    expect(violations.single, contains("a feature's data/ layer"));
  });

  test('app code takes colours and text styles from the core theme', () {
    fixture
      ..write('$view/a_view.dart', '''
final a = Color(0xFF000000);
final b = const Color.fromARGB(255, 0, 0, 0);
final c = Color.fromRGBO(0, 0, 0, 1);
final d = Colors.red;
final e = Colors.transparent;
final f = TextStyle(height: 1);
final g = style.copyWith(fontSize: 12, fontWeight: w, fontFamily: 'x');
''')
      ..write('apps/rider/lib/main.dart', 'final c = Colors.white;');

    final violations = checkBoundaries(fixture.root);

    expect(violations, hasLength(3));
    expect(
      violations,
      contains(
        '  $view/a_view.dart:1,2,3,4\n'
        '    -> hard-codes a colour (Color literal or Colors.*); take '
        'colours from the core theme',
      ),
    );
    expect(
      violations,
      contains(
        '  $view/a_view.dart:6,7\n'
        '    -> hard-codes a text style (TextStyle( or font*:); take text '
        'styles from the core theme',
      ),
    );
    expect(violations.join(), contains('apps/rider/lib/main.dart:1'));
  });

  test('the theme rules skip comments, strings, look-alikes and core', () {
    fixture
      ..write('$view/a_view.dart', '''
// Color(0xFF000000) Colors.red TextStyle(
/// Use context.colors, never Colors.red or fontSize: 12.
final a = 'Colors.red TextStyle( fontSize: 1';
final b = AppColors.red;
final c = context.colors.primary;
final d = MyTextStyle(x);
final e = Colors.transparent;
''')
      ..write(
        'packages/core/lib/theme/app_theme.dart',
        'final c = Color(0xFF000000);\nfinal s = TextStyle(fontSize: 1);\n',
      );

    expect(checkBoundaries(fixture.root), isEmpty);
  });

  test('workspace members missing on disk are skipped', () {
    fixture
      ..workspace(apps: <String>['customer', 'gone'])
      ..write('apps/customer/lib/main.dart', imports('package:dio/dio.dart'));
    Directory('${fixture.root}/apps/gone').deleteSync(recursive: true);

    expect(checkBoundaries(fixture.root), hasLength(1));
  });
}
