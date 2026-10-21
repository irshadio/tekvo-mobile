import 'package:test/test.dart';

import '../../tool/check_structure.dart';
import 'fixture.dart';

void main() {
  late Fixture fixture;

  setUp(() => fixture = Fixture()..workspace());
  tearDown(() => fixture.dispose());

  const fetchingViewModel =
      'class AViewModel extends _\$AViewModel\n'
      '    with RemoteStateMixin<int> {}';

  void writeFullFeature() {
    const f = 'apps/customer/lib/features/a';
    fixture
      ..write('$f/a_overrides.dart')
      ..write('$f/domain/entities/a.dart')
      ..write('$f/domain/entities/a.freezed.dart')
      ..write('$f/domain/repositories/a_repository.dart')
      ..write('$f/data/dtos/a_dto.dart')
      ..write('$f/data/sources/a_remote_data_source.dart')
      ..write('$f/data/sources/a_local_data_source.dart')
      ..write('$f/data/repositories/a_repository_impl.dart')
      ..write('$f/presentation/view/a_view.dart')
      ..write('$f/presentation/view/widgets/a_tile.dart')
      ..write('$f/presentation/view_model/a_view_model.dart', fetchingViewModel)
      ..write('$f/presentation/view_model/a_view_model.g.dart')
      ..write('$f/.DS_Store');
  }

  test('no features directory passes', () {
    expect(checkStructure(fixture.root), isEmpty);
  });

  test('full layout passes', () {
    writeFullFeature();

    expect(checkStructure(fixture.root), isEmpty);
  });

  test('presentation-only feature passes', () {
    fixture.write(
      'apps/customer/lib/features/splash/presentation/view/splash_view.dart',
    );

    expect(checkStructure(fixture.root), isEmpty);
  });

  test('flags stray files, directories and suffixes', () {
    writeFullFeature();
    const f = 'apps/customer/lib/features/a';
    fixture
      ..write('apps/customer/lib/features/stray.dart')
      ..write('$f/helpers.dart')
      ..write('$f/usecase/x.dart')
      ..write('$f/domain/x.dart')
      ..write('$f/domain/models/x.dart')
      ..write('$f/domain/entities/nested/x.dart')
      ..write('$f/data/dtos/a_model.dart')
      ..write('$f/data/sources/a_api.dart')
      ..write('$f/data/repositories/a_repository.dart')
      ..write('$f/presentation/view/a_tile.dart')
      ..write('$f/presentation/view/extra/x.dart');

    final flagged = checkStructure(
      fixture.root,
    ).map((v) => v.trim().split('\n').first).toList();

    expect(
      flagged,
      unorderedEquals(<String>[
        'apps/customer/lib/features/a/helpers.dart',
        'apps/customer/lib/features/a/usecase/',
        'apps/customer/lib/features/a/data/dtos/a_model.dart',
        'apps/customer/lib/features/a/data/repositories/a_repository.dart',
        'apps/customer/lib/features/a/data/sources/a_api.dart',
        'apps/customer/lib/features/a/domain/x.dart',
        'apps/customer/lib/features/a/domain/entities/nested/',
        'apps/customer/lib/features/a/domain/models/',
        'apps/customer/lib/features/a/presentation/view/a_tile.dart',
        'apps/customer/lib/features/a/presentation/view/extra/',
        'apps/customer/lib/features/stray.dart',
      ]),
    );
  });

  test('hidden directories are flagged, hidden files are not', () {
    writeFullFeature();
    fixture
      ..write('apps/customer/lib/features/.cache/x.dart')
      ..write('apps/customer/lib/features/a/.impl/x.dart')
      ..write('apps/customer/lib/features/a/domain/entities/.x/y.dart');

    final flagged = checkStructure(
      fixture.root,
    ).map((v) => v.trim().split('\n').first).toList();

    expect(flagged, <String>[
      'apps/customer/lib/features/.cache/',
      'apps/customer/lib/features/a/.impl/',
      'apps/customer/lib/features/a/domain/entities/.x/',
    ]);
  });

  test('feature without presentation/view fails', () {
    fixture.write('apps/customer/lib/features/a/domain/entities/a.dart');

    expect(
      checkStructure(fixture.root).join(),
      contains('every feature needs presentation/view/'),
    );
  });

  test('repository contract without overrides fails', () {
    fixture
      ..write(
        'apps/customer/lib/features/a/domain/repositories/a_repository.dart',
      )
      ..write('apps/customer/lib/features/a/presentation/view/a_view.dart');

    expect(checkStructure(fixture.root).join(), contains('a_overrides.dart'));
  });

  test('view model that runs requests needs a repository', () {
    fixture
      ..write('apps/customer/lib/features/a/presentation/view/a_view.dart')
      ..write(
        'apps/customer/lib/features/a/presentation/view_model/a_view_model.dart',
        r'class A extends _$A with MutationStateMixin<void> {}',
      );

    expect(checkStructure(fixture.root).join(), contains('a_view_model.dart'));
  });

  group('usesStateMixin', () {
    test('matches multi-line class headers', () {
      expect(usesStateMixin(fetchingViewModel), isTrue);
    });

    test('ignores comments', () {
      expect(usesStateMixin('// with RemoteStateMixin<int>'), isFalse);
    });
  });

  group('optsOut', () {
    test('needs a reason', () {
      expect(optsOut('// $optOutMarker'), isFalse);
      expect(optsOut('// $optOutMarker — reads SecureStore'), isTrue);
    });
  });

  test('every app is checked; a package without lib/app/ is not', () {
    fixture
      ..write('apps/rider/lib/features/stray.dart')
      ..write('packages/core/lib/features/stray.dart');

    final flagged = checkStructure(
      fixture.root,
    ).map((v) => v.trim().split('\n').first).toList();

    expect(flagged, <String>['apps/rider/lib/features/stray.dart']);
  });
}
