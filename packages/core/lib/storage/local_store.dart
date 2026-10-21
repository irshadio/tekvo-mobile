import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';

part 'local_store.g.dart';

/// Non-sensitive local persistence (caches, offline copies). Never tokens.
///
/// Records are JSON maps; the data layer converts them with DTO
/// `toJson` / `fromJson`.
abstract interface class LocalStore {
  Future<Map<String, Object?>?> read(String storeName, String key);
  Future<List<Map<String, Object?>>> readAll(String storeName);
  Future<void> write(String storeName, String key, Map<String, Object?> value);

  /// Upserts [entries] in one transaction; other keys are kept. Use
  /// [replaceAll] for a snapshot, where removed records must not linger.
  Future<void> writeAll(
    String storeName,
    Map<String, Map<String, Object?>> entries,
  );

  /// Replaces the whole of [storeName] with [entries] in one transaction.
  Future<void> replaceAll(
    String storeName,
    Map<String, Map<String, Object?>> entries,
  );

  Future<void> delete(String storeName, String key);
  Future<void> clear(String storeName);
}

/// sembast-backed [LocalStore]; the [Database] is opened in `core/bootstrap`.
class LocalStoreImpl implements LocalStore {
  LocalStoreImpl(this._db);

  final Database _db;

  StoreRef<String, Map<String, Object?>> _store(String name) =>
      stringMapStoreFactory.store(name);

  @override
  Future<Map<String, Object?>?> read(String storeName, String key) =>
      _store(storeName).record(key).get(_db);

  @override
  Future<List<Map<String, Object?>>> readAll(String storeName) async {
    final records = await _store(storeName).find(_db);
    return records.map((record) => record.value).toList();
  }

  @override
  Future<void> write(
    String storeName,
    String key,
    Map<String, Object?> value,
  ) => _store(storeName).record(key).put(_db, value);

  @override
  Future<void> writeAll(
    String storeName,
    Map<String, Map<String, Object?>> entries,
  ) {
    return _db.transaction((txn) async {
      final store = _store(storeName);
      for (final entry in entries.entries) {
        await store.record(entry.key).put(txn, entry.value);
      }
    });
  }

  @override
  Future<void> replaceAll(
    String storeName,
    Map<String, Map<String, Object?>> entries,
  ) {
    return _db.transaction((txn) async {
      final store = _store(storeName);
      await store.delete(txn);
      for (final entry in entries.entries) {
        await store.record(entry.key).put(txn, entry.value);
      }
    });
  }

  @override
  Future<void> delete(String storeName, String key) =>
      _store(storeName).record(key).delete(_db);

  @override
  Future<void> clear(String storeName) => _store(storeName).delete(_db);
}

/// Bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
LocalStore localStore(Ref ref) => throw UnimplementedError(
  'localStoreProvider must be overridden in ProviderScope (core/bootstrap).',
);
