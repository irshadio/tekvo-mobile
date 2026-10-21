import 'dart:io';

import 'package:core/vendor/remote_client/remote_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final handler = ErrorHandlerImpl();

  DioException exception(DioExceptionType type, {Object? error}) =>
      DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: type,
        error: error,
      );

  group('handleDioException', () {
    test('dio 5.11 transformTimeout maps to ReceiveTimeout', () {
      final failure = handler.handleDioException(
        exception(DioExceptionType.transformTimeout),
      );

      expect(failure, isA<ReceiveTimeout>());
    });

    for (final type in <DioExceptionType>[
      DioExceptionType.connectionError,
      DioExceptionType.unknown,
    ]) {
      test('${type.name} with a SocketException is NoInternet', () {
        final failure = handler.handleDioException(
          exception(type, error: const SocketException('lookup failed')),
        );

        expect(failure, isA<NoInternet>());
      });
    }

    test('connectionError without a socket failure stays ConnectionError', () {
      final failure = handler.handleDioException(
        exception(DioExceptionType.connectionError, error: StateError('x')),
      );

      expect(failure, isA<ConnectionError>());
    });
  });

  group('validateResponse', () {
    BaseResponse<String> response(
      int status, {
      bool success = true,
      String? message = 'server says no',
    }) => BaseResponse<String>(
      statusCode: status,
      success: success,
      message: message,
      data: 'partial',
    );

    Failure? failureOf(Either<Failure, BaseResponse<String>> result) =>
        switch (result) {
          Left<Failure, BaseResponse<String>>(:final value) => value,
          Right<Failure, BaseResponse<String>>() => null,
        };

    test('a 2xx with success:true passes', () {
      expect(failureOf(handler.validateResponse(response(200))), isNull);
    });

    test('a 2xx with success:false is a BadResponse with the message', () {
      final failure = failureOf(
        handler.validateResponse(response(200, success: false)),
      );

      expect(failure, isA<BadResponse>());
      expect(failure?.message, 'server says no');
      expect(failure?.response?.statusCode, 200);
    });

    test('a 2xx with success:false and no message has no message', () {
      final failure = failureOf(
        handler.validateResponse(
          response(200, success: false, message: null),
        ),
      );

      expect(failure, isA<BadResponse>());
      expect(failure?.message, isNull);
    });

    for (final (status, type) in <(int, Type)>[
      (400, BadRequest),
      (401, Unauthorized),
      (403, Unauthorized),
      (404, NotFound),
      (422, BadRequest),
      (500, InternalServerError),
      (503, ServiceUnavailable),
      (418, BadResponse),
    ]) {
      test('$status keeps its status code', () {
        final failure = failureOf(handler.validateResponse(response(status)));

        expect(failure.runtimeType, type);
        expect(failure?.response?.statusCode, status);
      });
    }
  });
}
