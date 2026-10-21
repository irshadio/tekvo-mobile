import 'package:core/vendor/remote_client/remote_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  const policy = RetryPolicy(initialDelayMs: 40, maxDelayMs: 200);

  Dio client(HttpClientAdapter adapter, {RetryPolicy retry = policy}) {
    final dio = dioWith(adapter);
    return dio..interceptors.add(RetryInterceptor(dio: dio, policy: retry));
  }

  /// Fails the first request with [first], then answers 200.
  ScriptedAdapter failOnce(Reply first) {
    var calls = 0;
    return ScriptedAdapter((_) => calls++ == 0 ? first : reply(200));
  }

  test('a 503 is retried and then succeeds', () async {
    final adapter = failOnce(reply(503));

    final response = await client(adapter).get<dynamic>('/x');

    expect(response.statusCode, 200);
    expect(adapter.requests, hasLength(2));
  });

  test('equal jitter never retries sooner than half the delay', () async {
    // Probabilistic against full jitter (uniform on [0, delay)): each run
    // lands below half with p = 0.5, so five runs miss it about 1 in 32.
    const jittered = RetryPolicy(initialDelayMs: 100, maxDelayMs: 1000);
    for (var run = 0; run < 5; run++) {
      final watch = Stopwatch()..start();

      await client(failOnce(reply(503)), retry: jittered).get<dynamic>('/x');

      expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(50));
    }
  });

  group('Retry-After', () {
    // Backoff alone would wait at least 1s; a fast retry proves the header won.
    const slow = RetryPolicy(initialDelayMs: 2000, maxDelayMs: 4000);

    Future<int> elapsedMs(ScriptedAdapter adapter) async {
      final watch = Stopwatch()..start();
      await client(adapter, retry: slow).get<dynamic>('/x');
      return watch.elapsedMilliseconds;
    }

    test('delta-seconds is honoured', () async {
      final adapter = failOnce(
        reply(
          503,
          headers: <String, List<String>>{
            'retry-after': <String>['0'],
          },
        ),
      );

      expect(await elapsedMs(adapter), lessThan(900));
      expect(adapter.requests, hasLength(2));
    });

    test('a date in the past means now', () async {
      final adapter = failOnce(
        reply(
          503,
          headers: <String, List<String>>{
            'retry-after': <String>['Wed, 21 Oct 2015 07:28:00 GMT'],
          },
        ),
      );

      expect(await elapsedMs(adapter), lessThan(900));
      expect(adapter.requests, hasLength(2));
    });

    test('longer than maxDelayMs stops retrying', () async {
      final adapter = failOnce(
        reply(
          503,
          headers: <String, List<String>>{
            'retry-after': <String>['3600'],
          },
        ),
      );

      await expectLater(
        client(adapter).get<dynamic>('/x'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.requests, hasLength(1));
    });
  });

  test('no retry starts past the deadline in extra', () async {
    final adapter = failOnce(reply(503));
    final deadline = DateTime.now().millisecondsSinceEpoch + 10;

    await expectLater(
      client(adapter).get<dynamic>(
        '/x',
        options: Options(
          extra: <String, Object?>{kRetryDeadlineExtraKey: deadline},
        ),
      ),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests, hasLength(1));
  });

  test('a transformTimeout follows retryOnTimeout', () async {
    var calls = 0;
    final adapter = _ThrowingAdapter(
      () => calls++ == 0
          ? DioException(
              requestOptions: RequestOptions(path: '/x'),
              type: DioExceptionType.transformTimeout,
            )
          : null,
    );

    final response = await client(adapter).get<dynamic>('/x');

    expect(response.statusCode, 200);
    expect(calls, 2);
  });

  group('HttpDate.tryParse', () {
    test('reads IMF-fixdate as UTC', () {
      expect(
        HttpDate.tryParse('Wed, 21 Oct 2015 07:28:00 GMT'),
        DateTime.utc(2015, 10, 21, 7, 28),
      );
    });

    test('returns null for anything else', () {
      expect(HttpDate.tryParse('tomorrow'), isNull);
      expect(HttpDate.tryParse('Wed, 21 Foo 2015 07:28:00 GMT'), isNull);
    });
  });
}

/// Throws the exception [next] returns, or answers 200 when it returns null.
class _ThrowingAdapter implements HttpClientAdapter {
  _ThrowingAdapter(this.next);

  final DioException? Function() next;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final error = next();
    if (error != null) throw error;
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}
