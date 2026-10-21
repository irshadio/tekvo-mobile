import 'package:core/network/token_provider.dart';
import 'package:core/storage/secure_store.dart';
import 'package:flutter_test/flutter_test.dart';

class _SecureStore implements SecureStore {
  _SecureStore(this.token);

  final String? token;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> writeAccessToken(String token) async {}

  @override
  Future<void> writeRefreshToken(String token) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  test('reads the access token from the secure store', () async {
    final provider = SecureTokenProvider(_SecureStore('abc'));

    expect(await provider.getAccessToken(), 'abc');
    expect(await provider.hasValidToken(), isTrue);
  });

  test('a missing or empty token is not valid', () async {
    expect(
      await SecureTokenProvider(_SecureStore(null)).hasValidToken(),
      false,
    );
    expect(await SecureTokenProvider(_SecureStore('')).hasValidToken(), false);
  });

  test('refresh is unsupported, so a 401 ends the session', () async {
    expect(await SecureTokenProvider(_SecureStore('abc')).refreshToken(), null);
  });
}
