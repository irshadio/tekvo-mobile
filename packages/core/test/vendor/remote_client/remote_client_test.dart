import 'dart:async';

import 'package:core/vendor/remote_client/remote_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  test('the barrel exposes the types added downstream', () {
    expect(FormData(), isA<FormData>());
    expect(const DeduplicationConfig(), isA<DeduplicationConfig>());
    expect(
      RemoteClientFactory.create(baseUrl: 'https://api.example.test'),
      isA<RemoteClient>(),
    );
  });

  group('per-request parser', () {
    RemoteClientImpl client() => RemoteClientImpl(
      dio: dioWith(
        ScriptedAdapter(
          (_) => reply(
            200,
            body: <String, Object?>{'auth': 'signed', 'data': 'wrapped'},
          ),
        ),
      ),
      errorHandler: ErrorHandlerImpl(),
    );

    String? dataOf(Either<Failure, BaseResponse<Object?>> result) =>
        switch (result) {
          Right<Failure, BaseResponse<Object?>>(:final value) =>
            value.data is Map
                ? (value.data! as Map<String, Object?>)['auth'] as String?
                : value.data as String?,
          Left<Failure, BaseResponse<Object?>>() => null,
        };

    test('the client-wide parser unwraps the envelope', () async {
      expect(dataOf(await client().get<Object?>('/x')), 'wrapped');
    });

    test('a per-request parser reads the raw body', () async {
      final result = await client().post<Object?>(
        '/auth',
        parser: const DirectResponseParser(),
      );

      expect(dataOf(result), 'signed');
    });
  });

  group('DeduplicationInterceptor', () {
    Dio client(ScriptedAdapter adapter) =>
        dioWith(adapter)..interceptors.add(DeduplicationInterceptor());

    test('a failed request nobody joined raises no uncaught error', () async {
      final uncaught = <Object>[];

      await runZonedGuarded(() async {
        final dio = client(ScriptedAdapter((_) => reply(500)));
        await expectLater(
          dio.get<dynamic>('/x'),
          throwsA(isA<DioException>()),
        );
        await Future<void>.delayed(Duration.zero);
      }, (error, _) => uncaught.add(error));

      expect(uncaught, isEmpty);
    });

    test('a joined duplicate still receives the error', () async {
      final adapter = ScriptedAdapter(
        (_) => reply(500),
        delay: const Duration(milliseconds: 10),
      );
      final dio = client(adapter);

      final first = dio.get<dynamic>('/x');
      final duplicate = dio.get<dynamic>('/x');

      await expectLater(first, throwsA(isA<DioException>()));
      await expectLater(duplicate, throwsA(isA<DioException>()));
      expect(adapter.requests, hasLength(1));
    });
  });
}
