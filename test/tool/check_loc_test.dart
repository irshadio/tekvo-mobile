import 'dart:io';

import 'package:test/test.dart';

import '../../tool/check_loc.dart';
import 'fixture.dart';

void main() {
  late Fixture fixture;

  setUp(() => fixture = Fixture()..workspace());
  tearDown(() => fixture.dispose());

  String lines(int count) => List.filled(count, '//').join('\n');

  test('files at the limit pass', () {
    fixture
      ..write('packages/core/lib/a.dart', lines(maxLines))
      ..write('apps/customer/test/a_test.dart', lines(maxLines))
      ..write('test/tool/a_test.dart', lines(maxLines));

    expect(checkLoc(fixture.root), isEmpty);
  });

  test("files over the limit in a package's lib/ and test/, or the root "
      'test/, fail', () {
    fixture
      ..write('packages/core/lib/a.dart', lines(maxLines + 1))
      ..write('packages/core/test/a_test.dart', lines(maxLines + 1))
      ..write('apps/rider/lib/a.dart', lines(maxLines + 1))
      ..write('apps/rider/test/a_test.dart', lines(maxLines + 1))
      ..write('test/tool/a_test.dart', lines(maxLines + 1));

    expect(checkLoc(fixture.root), hasLength(5));
  });

  test('files outside lib/ and test/ are not checked', () {
    fixture
      ..write('apps/rider/integration/a.dart', lines(maxLines + 1))
      ..write('tool/a.dart', lines(maxLines + 1))
      ..write('local_dev/a.dart', lines(maxLines + 1));

    expect(checkLoc(fixture.root), isEmpty);
  });

  test('generated and vendored files are exempt', () {
    const lib = 'apps/customer/lib';
    fixture
      ..write('$lib/a.g.dart', lines(maxLines + 1))
      ..write('$lib/a.gen.dart', lines(maxLines + 1))
      ..write('$lib/l10n/generated/l.dart', lines(maxLines + 1))
      ..write('packages/core/lib/l10n/generated/l.dart', lines(maxLines + 1))
      ..write('$lib/a.freezed.dart', lines(maxLines + 1))
      ..write('$lib/a.mocks.dart', lines(maxLines + 1))
      ..write(
        '$lib/tokens.dart',
        '// GENERATED CODE - DO NOT MODIFY BY HAND.\n${lines(maxLines)}',
      )
      ..write('packages/core/lib/vendor/v/big.dart', lines(maxLines + 1));

    expect(checkLoc(fixture.root), isEmpty);
  });

  test('a file that is not UTF-8 is reported, not a crash', () {
    File('${fixture.root}/packages/core/lib/bad.dart')
      ..createSync(recursive: true)
      ..writeAsBytesSync(<int>[0xff, 0xfe, 0x00]);

    expect(checkLoc(fixture.root).join(), contains('not UTF-8'));
  });

  test('vendor exemption applies only to packages/core/lib/vendor/', () {
    fixture
      ..write('apps/customer/lib/vendor/big.dart', lines(maxLines + 1))
      ..write('packages/core/lib/state/vendor/big.dart', lines(maxLines + 1));

    expect(checkLoc(fixture.root), hasLength(2));
  });
}
