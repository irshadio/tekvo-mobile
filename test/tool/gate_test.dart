import 'dart:io';

import 'package:test/test.dart';

import '../../tool/gate.dart';
import 'fixture.dart';

void main() {
  late Fixture fixture;

  setUp(() => fixture = Fixture()..workspace());
  tearDown(() => fixture.dispose());

  test('formats hand-written files only, never vendor or generated', () {
    fixture
      ..write('apps/customer/lib/main.dart')
      ..write('apps/customer/lib/x.g.dart')
      ..write('apps/customer/lib/x.freezed.dart')
      ..write('apps/customer/lib/l10n/generated/app_localizations.dart')
      ..write('apps/customer/build/x.dart')
      ..write('apps/customer/test/a_test.dart')
      ..write('packages/core/lib/l10n/generated/core_localizations.dart')
      ..write('packages/core/lib/vendor/v/v.dart')
      ..write('packages/core/lib/readme.md')
      ..write('packages/core/lib/t.dart', '// GENERATED CODE - DO NOT MODIFY')
      ..write('packages/core/test/x.mocks.dart')
      ..write('test/tool/a_test.dart')
      ..write('tool/gate.dart')
      ..write('local_dev/x.dart');

    expect(formattableFiles(fixture.root), <String>[
      'apps/customer/lib/app/app.dart',
      'apps/customer/lib/main.dart',
      'apps/customer/test/a_test.dart',
      'apps/rider/lib/app/app.dart',
      'test/tool/a_test.dart',
      'tool/gate.dart',
    ]);
  });

  test('batches keep every file, in order, within the size', () {
    final files = List.generate(250, (i) => 'f$i.dart');

    final split = batches(files);

    expect(split.map((b) => b.length), <int>[100, 100, 50]);
    expect(split.expand((b) => b), files);
    expect(batches(<String>[]), isEmpty);
  });

  group('gateSteps', () {
    setUp(() {
      fixture
        ..write(
          'packages/core/pubspec.yaml',
          'name: core\ndev_dependencies:\n  build_runner: ^2.0.0\n',
        )
        ..write(
          'apps/customer/pubspec.yaml',
          'name: customer\ndev_dependencies:\n  build_runner: ^2.0.0\n',
        )
        ..write('packages/core/l10n.yaml')
        ..write('apps/rider/l10n.yaml')
        ..write('apps/customer/test/a_test.dart');
      Directory('${fixture.root}/packages/core/test').createSync();
    });

    List<GateStep> steps({bool quiet = false}) => gateSteps(
      fixture.root,
      quiet: quiet,
      formatBatches: <List<String>>[
        <String>['a.dart'],
        <String>['b.dart'],
      ],
    );

    test('keeps the order, with tokens after assets and per-package steps '
        'in workspace order', () {
      expect(steps().map(stepLabel), <String>[
        'assets',
        'tokens',
        'build_runner (packages/core)',
        'build_runner (apps/customer)',
        'format',
        'format',
        'l10n (packages/core)',
        'l10n (apps/rider)',
        'analyze (packages/core)',
        'analyze (apps/customer)',
        'analyze (apps/rider)',
        'analyze',
        'boundaries',
        'loc',
        'structure',
        'branding',
        'layout',
        'duplicates',
        'test (apps/customer)',
        'test',
      ]);
    });

    test('runs per-package steps in the package, the rest at the root', () {
      final all = steps();
      GateStep find(String label) =>
          all.firstWhere((step) => stepLabel(step) == label);

      expect(find('tokens').command, <String>[
        'dart',
        'run',
        'tool/generate_tokens.dart',
        '--check',
      ]);
      expect(find('build_runner (apps/customer)').dir, 'apps/customer');
      expect(find('l10n (apps/rider)').command, <String>[
        'flutter',
        'gen-l10n',
      ]);
      expect(find('analyze').dir, isEmpty);
      expect(find('analyze').command, <String>[
        'dart',
        'analyze',
        '--fatal-infos',
        'tool',
        'test/tool',
      ]);
      expect(find('layout').command, <String>[
        'dart',
        'run',
        'tool/check_layout.dart',
      ]);
      expect(find('duplicates').command, <String>[
        'dart',
        'run',
        'tool/check_duplicates.dart',
      ]);
      expect(find('test').command, <String>['dart', 'test', 'test/tool']);
    });

    test('quiet tests report failures only', () {
      final tests = steps(quiet: true).where((step) => step.name == 'test');

      expect(
        tests.map((step) => step.command.sublist(step.command.length - 2)),
        everyElement(<String>['-r', 'failures-only']),
      );
    });
  });
}
