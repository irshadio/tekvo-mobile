import 'package:test/test.dart';

import '../../tool/check_layout.dart';
import 'fixture.dart';

const _feature = 'apps/customer/lib/features/a/presentation/view/widgets';

/// Every rule's pattern once, for files that must be skipped.
const _everyPattern = '''
void f() {
  Image.network(url);
  MediaQuery.of(context);
  showModalBottomSheet(context: context, builder: b);
  Semantics(button: true, child: GestureDetector(onTap: t));
  Text('', textAlign: TextAlign.left);
  Positioned(left: 4, child: c);
  EdgeInsets.only(right: 2);
  EdgeInsets.fromLTRB(1, 0, 2, 0);
  DateFormat('d', 'en');
}
''';

void main() {
  late Fixture fixture;

  setUp(() => fixture = Fixture()..workspace());
  tearDown(() => fixture.dispose());

  List<String> check([Map<String, Map<String, String>> allow = const {}]) =>
      checkLayout(fixture.root, allowList: allow);

  test('clean tree passes', () {
    fixture
      ..write(
        'packages/core/lib/presentation/widgets/app_network_image.dart',
        'Widget f() => Image.network(url, cacheWidth: 1);',
      )
      ..write(
        'packages/core/lib/presentation/widgets/app_sheet.dart',
        'void f() => showModalBottomSheet<T>(context: c, builder: b);',
      )
      ..write(
        'packages/core/lib/presentation/widgets/tap.dart',
        'Widget f() => Semantics(button: true, child: GestureDetector());',
      )
      ..write('packages/core/lib/utils/format_cache.dart', '''
final d = DateFormat(p, l);
final n = NumberFormat.decimalPattern(l);
''')
      ..write(
        'packages/core/lib/insets.dart',
        'const p = EdgeInsets.fromLTRB(1, 0, 2, 0);',
      )
      ..write('$_feature/ok.dart', '''
Widget f() => Column(children: [
  Semantics(button: true, child: InkWell(onTap: t)),
  Semantics(label: 'x', child: GestureDetector(onTap: t)),
  Semantics(toggled: on, child: AppQuietTap(onTap: t, child: c)),
  Positioned.fill(child: c),
  PositionedDirectional(start: 4, child: c),
  Padding(padding: EdgeInsetsDirectional.only(start: 4)),
  Padding(padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 1)),
  Positioned(left: 0, right: 0, bottom: 0, child: c),
  Positioned(top: 3, child: c),
  Text('', textAlign: TextAlign.start),
  MediaQuery.sizeOf(context),
  Padding(padding: EdgeInsets.fromLTRB(16.w, 9.h, 16.w, 0)),
  Padding(padding: EdgeInsetsDirectional.fromSTEB(1, 0, 2, 0)),
  Text(FormatCache.date('d MMM', locale).format(day)),
  Text(FormatCache.decimal(locale).format(1)),
  if (DateFormat.localeExists(locale)) Text(''),
  Text(NumberFormat.numberOfIntegerDigits(4).toString()),
]);
''')
      ..write(
        '$_feature/hidden.dart',
        '''
// Image.network( MediaQuery.of( showModalBottomSheet( TextAlign.left
/* Positioned(left: 4) EdgeInsets.only(right: 2) DateFormat('d') */
// EdgeInsets.fromLTRB(1, 0, 2, 0) NumberFormat('0')
const s = 'Semantics(button: true, child: GestureDetector())';
const t = "TextAlign.right Positioned(right: 1) EdgeInsets.only(left: 1)";
''',
      )
      ..write('packages/core/lib/vendor/v/v.dart', _everyPattern)
      ..write('$_feature/x.g.dart', _everyPattern)
      ..write('$_feature/x.freezed.dart', _everyPattern)
      ..write('packages/core/lib/assets/assets.gen.dart', _everyPattern)
      ..write(
        'packages/core/lib/l10n/generated/app_localizations.dart',
        _everyPattern,
      )
      ..write(
        'apps/rider/lib/l10n/generated/app_localizations.dart',
        _everyPattern,
      );

    expect(check(), isEmpty);
  });

  test('flags every rule once per file, naming path and rule', () {
    fixture
      ..write('$_feature/image.dart', 'Widget f() => Image.network(u);')
      ..write('$_feature/query.dart', 'void f() => MediaQuery.of(c).size;')
      ..write(
        'packages/core/lib/query.dart',
        'void f() => MediaQuery.of(c).size;',
      )
      ..write(
        '$_feature/sheet.dart',
        'void f() => showModalBottomSheet<void>(context: c, builder: b);',
      )
      ..write(
        'packages/core/lib/sheet.dart',
        'void f() => showModalBottomSheet(context: c, builder: b);',
      )
      ..write(
        '$_feature/tap.dart',
        'Widget f() => Semantics(button: true, child: GestureDetector());',
      )
      ..write(
        '$_feature/align.dart',
        "Widget f() => Text('', textAlign: TextAlign.right);",
      )
      ..write(
        '$_feature/positioned.dart',
        'Widget f() => Positioned(left: 4, top: 0, child: c);',
      )
      ..write(
        '$_feature/insets.dart',
        'const p = EdgeInsets.only(left: 14, right: 12);',
      )
      ..write(
        '$_feature/ltrb.dart',
        'const p = EdgeInsets.fromLTRB(14, 0, 12, 0);',
      )
      ..write('$_feature/format.dart', "final f = DateFormat('d', l);")
      ..write(
        'packages/core/lib/format.dart',
        "final f = NumberFormat('0', l);",
      );

    final violations = check();

    expect(violations, hasLength(12));
    for (final (path, rule) in <(String, String)>[
      ('$_feature/image.dart:1', 'image-network'),
      ('$_feature/query.dart:1', 'media-query-of'),
      ('packages/core/lib/query.dart:1', 'media-query-of'),
      ('$_feature/sheet.dart:1', 'modal-sheet'),
      ('packages/core/lib/sheet.dart:1', 'modal-sheet'),
      ('$_feature/tap.dart:1', 'semantics-gesture'),
      ('$_feature/align.dart:1', 'rtl-text-align'),
      ('$_feature/positioned.dart:1', 'rtl-positioned'),
      ('$_feature/insets.dart:1', 'rtl-edge-insets'),
      ('$_feature/ltrb.dart:1', 'rtl-edge-insets-ltrb'),
      ('$_feature/format.dart:1', 'format-cache'),
      ('packages/core/lib/format.dart:1', 'format-cache'),
    ]) {
      expect(
        violations.where((v) => v.contains('$path\n') && v.contains(rule)),
        hasLength(1),
        reason: '$path $rule',
      );
    }
  });

  test('app/ is held to the feature rules; core/ is not', () {
    const tap =
        'Widget f() => Semantics(button: true, child: GestureDetector());';
    fixture
      ..write('apps/customer/lib/app/tap.dart', tap)
      ..write('packages/core/lib/presentation/widgets/tap.dart', tap)
      ..write(
        'packages/core/lib/align.dart',
        "Widget f() => Text('', textAlign: TextAlign.left);",
      );

    final violations = check();

    expect(violations, hasLength(1));
    expect(violations.single, contains('apps/customer/lib/app/tap.dart'));
  });

  test('lists every line of a file in one message', () {
    fixture.write(
      '$_feature/align.dart',
      '''
Widget f() => Column(children: [
  Text('', textAlign: TextAlign.left),
  Text('', textAlign: TextAlign.right),
]);
''',
    );

    const message =
        '  $_feature/align.dart:2,3\n'
        '    -> rtl-text-align: use TextAlign.start / end so Arabic mirrors';
    expect(check(), <String>[message]);
  });

  test('an allow-listed path passes', () {
    fixture.write(
      '$_feature/align.dart',
      "Widget f() => Text('', textAlign: TextAlign.right);",
    );

    expect(
      check(<String, Map<String, String>>{
        'rtl-text-align': <String, String>{'$_feature/align.dart': 'reason'},
      }),
      isEmpty,
    );
  });

  test('an entry for a rule the file no longer breaks is stale', () {
    fixture.write(
      '$_feature/align.dart',
      "Widget f() => Text('', textAlign: TextAlign.start);",
    );

    final violations = check(<String, Map<String, String>>{
      'rtl-text-align': <String, String>{'$_feature/align.dart': 'reason'},
      'rtl-positioned': <String, String>{'$_feature/gone.dart': 'reason'},
    });

    expect(violations, hasLength(2));
    expect(violations, everyElement(contains('stale allow-list entry')));
  });

  test('a toggle or check over a bare GestureDetector is flagged', () {
    fixture
      ..write(
        '$_feature/toggle.dart',
        'Widget f() => Semantics(toggled: on, child: GestureDetector());',
      )
      ..write(
        '$_feature/check.dart',
        'Widget f() => Semantics(checked: on, child: GestureDetector());',
      );

    final violations = check();

    expect(violations, hasLength(2));
    expect(violations, everyElement(contains('semantics-gesture')));
  });

  test('reads calls that span lines and nest', () {
    fixture
      ..write('$_feature/tap.dart', '''
Widget f() {
  return Semantics(
    label: label(a, b),
    button: true,
    onTap: () => go(c, d),
    child: GestureDetector(
      onTap: t,
      child: Row(children: [Text('a, b')]),
    ),
  );
}
''')
      ..write('$_feature/nested.dart', '''
Widget f() => Semantics(
  button: true,
  child: Padding(
    padding: EdgeInsets.all(1),
    child: GestureDetector(onTap: t),
  ),
);
''')
      ..write('$_feature/insets.dart', '''
final p = EdgeInsets.only(
  left: max(a, b),
  right: max(a, b),
);
final q = EdgeInsets.only(
  top: f(g(1, 2)),
  left: 3,
);
''');

    final violations = check();

    expect(violations, hasLength(2));
    expect(violations, contains(contains('$_feature/tap.dart:2\n')));
    expect(violations, contains(contains('$_feature/insets.dart:5\n')));
  });

  test('flags every format constructor, not the static helpers', () {
    fixture.write('$_feature/formats.dart', '''
final a = DateFormat.yMMMd(l);
final b = NumberFormat.decimalPattern(l);
final c = NumberFormat.currency(locale: l, symbol: '');
final d = new DateFormat('d');
final e = intl.NumberFormat('0', l);
final f = DateFormat
    .E(l);
final ok = DateFormat.localeExists(l);
final ok2 = MyDateFormat('d');
''');

    const message =
        '  $_feature/formats.dart:1,2,3,4,5,6\n'
        '    -> format-cache: use FormatCache (shared formats, built once '
        'per pattern and locale)';
    expect(check(), <String>[message]);
  });

  test('fromLTRB passes when left and right read the same', () {
    fixture.write('$_feature/ltrb.dart', '''
final p = EdgeInsets.fromLTRB(
  AppSpacing.lg.w,
  f(1, 2),
  AppSpacing.lg.w,
  0,
);
final q = EdgeInsets.fromLTRB(
  max(a, b),
  0,
  max(a,  c),
  0,
);
''');

    final violations = check();

    expect(violations, hasLength(1));
    expect(violations.single, contains('$_feature/ltrb.dart:7\n'));
    expect(violations.single, contains('rtl-edge-insets-ltrb'));
  });

  test("every app's features/ and app/ are scoped; core and main are not", () {
    const align = "Widget f() => Text('', textAlign: TextAlign.left);";
    fixture
      ..write('apps/rider/lib/features/a/presentation/view/a_view.dart', align)
      ..write('apps/rider/lib/app/app.dart', align)
      ..write('apps/rider/lib/main.dart', align)
      ..write('packages/core/lib/features/a.dart', align);

    final violations = check();

    expect(violations, hasLength(2));
    expect(violations, everyElement(contains('apps/rider/lib/')));
  });
}
