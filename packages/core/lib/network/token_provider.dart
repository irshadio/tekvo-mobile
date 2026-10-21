import 'package:core/storage/secure_store.dart';
import 'package:core/vendor/remote_client/remote_client.dart' as rc;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_provider.g.dart';

/// Supplies the access token to the client's `AuthInterceptor` from
/// [SecureStore].
///
/// Token refresh is not supported until the refresh endpoint is confirmed:
/// [refreshToken] returns null, so a 401 ends the session through the
/// `UnauthorizedHandler`. A refresh implementation must be single-flight and
/// must not call through the intercepted client (see the vendored
/// `VENDOR.md`, "Known limits").
class SecureTokenProvider implements rc.TokenProvider {
  SecureTokenProvider(this._secureStore);

  final SecureStore _secureStore;

  @override
  Future<String?> getAccessToken() => _secureStore.readAccessToken();

  @override
  Future<bool> hasValidToken() async {
    final token = await _secureStore.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> refreshToken() async => null;
}

/// Bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
rc.TokenProvider tokenProvider(Ref ref) => throw UnimplementedError(
  'tokenProviderProvider must be overridden in ProviderScope (core/bootstrap).',
);
