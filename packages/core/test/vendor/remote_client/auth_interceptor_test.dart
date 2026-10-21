import 'package:core/vendor/remote_client/remote_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

class _Tokens implements TokenProvider {
  _Tokens({required this.refreshed});

  final String? refreshed;
  String current = 'old';
  int refreshes = 0;

  @override
  Future<String?> getAccessToken() async => current;

  @override
  Future<bool> hasValidToken() async => true;

  @override
  Future<String?> refreshToken() async {
    refreshes++;
    final next = refreshed;
    if (next != null) current = next;
    return next;
  }
}

class _Unauthorized implements UnauthorizedHandler {
  int calls = 0;

  @override
  Future<void> handleUnauthorized() async => calls++;
}

void main() {
  late _Unauthorized unauthorized;

  setUp(() => unauthorized = _Unauthorized());

  Dio client(ScriptedAdapter adapter, _Tokens tokens) {
    final dio = dioWith(adapter);
    return dio
      ..interceptors.add(
        AuthInterceptor(
          dio: dio,
          tokenProvider: tokens,
          unauthorizedHandler: unauthorized,
        ),
      );
  }

  String? bearer(RequestOptions options) =>
      options.headers['Authorization'] as String?;

  test('a 401 is replayed once with the refreshed token', () async {
    final tokens = _Tokens(refreshed: 'new');
    final adapter = ScriptedAdapter(
      (o) => bearer(o) == 'Bearer new' ? reply(200) : reply(401),
    );

    final response = await client(adapter, tokens).get<dynamic>('/me');

    expect(response.statusCode, 200);
    expect(
      adapter.sentHeaders.map((h) => h['Authorization']),
      <String>['Bearer old', 'Bearer new'],
    );
    expect(unauthorized.calls, 0);
  });

  test('a rejected replay fails, ends the session, and wedges nothing', () {
    // The replay used to re-enter the queued interceptor and never complete.
    final tokens = _Tokens(refreshed: 'new');
    final adapter = ScriptedAdapter((_) => reply(401));
    final dio = client(adapter, tokens);

    return Future<void>(() async {
      await expectLater(
        dio.get<dynamic>('/me'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(unauthorized.calls, 1);

      await expectLater(dio.get<dynamic>('/other'), throwsA(isA<Exception>()));
    }).timeout(const Duration(seconds: 5));
  });

  test('a failed refresh ends the session without a replay', () async {
    final tokens = _Tokens(refreshed: null);
    final adapter = ScriptedAdapter((_) => reply(401));

    await expectLater(
      client(adapter, tokens).get<dynamic>('/me'),
      throwsA(isA<DioException>()),
    );

    expect(adapter.requests, hasLength(1));
    expect(unauthorized.calls, 1);
  });
}
