import 'dart:async';

import 'package:core/logging/app_logger.dart';
import 'package:core/network/unauthorized_handler.dart';
import 'package:core/storage/local_store.dart';
import 'package:core/storage/secure_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

class _SecureStore implements SecureStore {
  int clears = 0;
  Completer<void>? gate;
  bool fails = false;

  @override
  Future<void> clear() async {
    clears++;
    await gate?.future;
    if (fails) throw StateError('keychain');
  }

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> writeAccessToken(String token) async {}

  @override
  Future<void> writeRefreshToken(String token) async {}
}

class _Logger implements AppLogger {
  final List<String> errors = <String>[];

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      errors.add(message);

  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {}
}

class _FailingStore extends LocalStoreImpl {
  _FailingStore(super._db);

  @override
  Future<void> clear(String storeName) async {
    if (storeName == 'broken') throw StateError('disk');
    return super.clear(storeName);
  }
}

void main() {
  late _SecureStore secureStore;
  late _Logger logger;
  late LocalStoreImpl localStore;

  setUp(() async {
    secureStore = _SecureStore();
    logger = _Logger();
    final db = await newDatabaseFactoryMemory().openDatabase('test.db');
    localStore = _FailingStore(db);
    await localStore.write('profile', 'me', <String, Object?>{'name': 'A'});
    await localStore.write('cache', 'x', <String, Object?>{'v': 1});
  });

  AppUnauthorizedHandler handler(List<String> stores) => AppUnauthorizedHandler(
    secureStore: secureStore,
    localStore: localStore,
    userDataStores: stores,
    logger: logger,
  );

  test('clears tokens and only the listed user-data stores', () async {
    await handler(<String>['profile']).handleUnauthorized();

    expect(secureStore.clears, 1);
    expect(await localStore.readAll('profile'), isEmpty);
    expect(await localStore.readAll('cache'), isNotEmpty);
  });

  test('concurrent calls share one wipe', () async {
    secureStore.gate = Completer<void>();
    final subject = handler(<String>['profile']);

    final calls = <Future<void>>[
      for (var i = 0; i < 4; i++) subject.handleUnauthorized(),
    ];
    secureStore.gate!.complete();
    await Future.wait(calls);

    expect(secureStore.clears, 1);
  });

  test('user data is still cleared when the keychain fails', () async {
    secureStore.fails = true;

    await handler(<String>['profile']).handleUnauthorized();

    expect(logger.errors.single, contains('credentials'));
    expect(await localStore.readAll('profile'), isEmpty);
  });

  test('a later call wipes again', () async {
    final subject = handler(<String>['profile']);

    await subject.handleUnauthorized();
    await subject.handleUnauthorized();

    expect(secureStore.clears, 2);
  });

  test(
    'a store that fails to clear is logged and the rest still clear',
    () async {
      await handler(<String>['broken', 'profile']).handleUnauthorized();

      expect(logger.errors.single, contains('broken'));
      expect(await localStore.readAll('profile'), isEmpty);
    },
  );
}
