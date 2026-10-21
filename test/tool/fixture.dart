import 'dart:io';

/// A throwaway workspace root for exercising the tool/ checkers.
class Fixture {
  Fixture() : root = Directory.systemTemp.createTempSync('gate_fixture_').path;

  final String root;

  void write(String path, [String content = '']) {
    File('$root/$path')
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  /// A workspace listing packages/core and `apps/<name>` for each of [apps];
  /// each app gets `lib/app/app.dart`, which marks it as an app.
  void workspace({List<String> apps = const <String>['customer', 'rider']}) {
    write(
      'pubspec.yaml',
      <String>[
        'name: workspace',
        'workspace:',
        '  - packages/core',
        for (final app in apps) '  - apps/$app',
        'dev_dependencies:',
        '  test: any',
      ].join('\n'),
    );
    write('packages/core/pubspec.yaml', 'name: core\n');
    for (final app in apps) {
      write('apps/$app/pubspec.yaml', 'name: $app\n');
      write('apps/$app/lib/app/app.dart');
    }
  }

  void dispose() => Directory(root).deleteSync(recursive: true);
}
