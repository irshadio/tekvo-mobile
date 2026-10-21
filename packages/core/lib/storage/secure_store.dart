import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_store.g.dart';

/// Sensitive key/value storage. Tokens live here and nowhere else.
abstract interface class SecureStore {
  Future<String?> readAccessToken();
  Future<void> writeAccessToken(String token);
  Future<String?> readRefreshToken();
  Future<void> writeRefreshToken(String token);

  /// Wipes every secure value (logout, 401).
  Future<void> clear();
}

/// `flutter_secure_storage`-backed [SecureStore].
class SecureStoreImpl implements SecureStore {
  SecureStoreImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  @override
  Future<void> clear() => _storage.deleteAll();
}

/// Bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
SecureStore secureStore(Ref ref) => throw UnimplementedError(
  'secureStoreProvider must be overridden in ProviderScope (core/bootstrap).',
);
