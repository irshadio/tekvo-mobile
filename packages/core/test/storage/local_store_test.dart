import 'package:core/storage/local_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late LocalStore store;

  setUp(() async {
    store = LocalStoreImpl(
      await newDatabaseFactoryMemory().openDatabase('test.db'),
    );
  });

  test('write, read, delete', () async {
    await store.write('s', 'a', <String, Object?>{'v': 1});

    expect(await store.read('s', 'a'), <String, Object?>{'v': 1});

    await store.delete('s', 'a');
    expect(await store.read('s', 'a'), isNull);
  });

  test('writeAll upserts and keeps other keys', () async {
    await store.write('s', 'old', <String, Object?>{'v': 0});

    await store.writeAll('s', <String, Map<String, Object?>>{
      'a': <String, Object?>{'v': 1},
    });

    expect(await store.readAll('s'), hasLength(2));
  });

  test('replaceAll drops records missing from the new snapshot', () async {
    await store.write('s', 'old', <String, Object?>{'v': 0});

    await store.replaceAll('s', <String, Map<String, Object?>>{
      'a': <String, Object?>{'v': 1},
    });

    expect(await store.readAll('s'), <Map<String, Object?>>[
      <String, Object?>{'v': 1},
    ]);
  });

  test('clear empties one store only', () async {
    await store.write('s', 'a', <String, Object?>{'v': 1});
    await store.write('t', 'a', <String, Object?>{'v': 1});

    await store.clear('s');

    expect(await store.readAll('s'), isEmpty);
    expect(await store.readAll('t'), hasLength(1));
  });
}
