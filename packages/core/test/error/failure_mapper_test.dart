import 'package:core/error/failure.dart';
import 'package:core/error/failure_mapper.dart';
import 'package:core/vendor/remote_client/remote_client.dart' as rc;
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const diagnostic =
      'DioException [connection error] [Request ID: abc] '
      '[URI: https://api.example.test/x?page=1] [Status: 0]';

  Response<dynamic> response(int status, [Object? data]) => Response<dynamic>(
    requestOptions: RequestOptions(),
    statusCode: status,
    data: data,
  );

  group('every case maps to its app Failure', () {
    final cases = <rc.Failure, Matcher>{
      const rc.NoInternet(): isA<NoConnectionFailure>(),
      const rc.ConnectionError(): isA<NetworkFailure>(),
      const rc.BadCertificate(): isA<NetworkFailure>(),
      const rc.ConnectionTimeout(): isA<TimeoutFailure>(),
      const rc.SendTimeout(): isA<TimeoutFailure>(),
      const rc.ReceiveTimeout(): isA<TimeoutFailure>(),
      const rc.Unauthorized(): isA<UnauthorizedFailure>(),
      rc.Unauthorized(response: response(403)): isA<ForbiddenFailure>(),
      const rc.BadRequest(): isA<ValidationFailure>(),
      const rc.NotFound(): isA<ServerFailure>(),
      const rc.BadResponse(): isA<ServerFailure>(),
      const rc.InternalServerError(): isA<ServerFailure>(),
      const rc.ServiceUnavailable(): isA<ServerFailure>(),
      const rc.Cancelled(): isA<CancelledFailure>(),
      const rc.Unexpected(): isA<UnexpectedFailure>(),
    };
    for (final MapEntry(key: failure, value: matcher) in cases.entries) {
      test('${failure.runtimeType}', () {
        expect(mapRemoteFailure(failure), matcher);
      });
    }
  });

  test('transport diagnostics go to detail, never to message', () {
    const failures = <rc.Failure>[
      rc.ConnectionError(message: diagnostic),
      rc.ReceiveTimeout(message: diagnostic),
      rc.InternalServerError(message: diagnostic),
      rc.BadRequest(message: diagnostic),
      rc.Unexpected(message: diagnostic),
    ];
    for (final failure in failures) {
      final mapped = mapRemoteFailure(failure);

      expect(mapped.message, isNot(contains('https://')));
      expect(mapped.message, isNot(contains('Request ID')));
      expect(mapped.detail, diagnostic);
    }
  });

  test("per-field errors win over the envelope's message", () {
    final mapped = mapRemoteFailure(
      rc.BadRequest(
        message: diagnostic,
        response: response(422, <String, dynamic>{
          'message': 'Invalid data.',
          'errors': <String, dynamic>{
            'email': <dynamic>['Already taken.'],
            'phone': 'Required.',
          },
        }),
      ),
    );

    expect(mapped, isA<ValidationFailure>());
    expect(mapped.message, 'Already taken. Required.');
    expect((mapped as ValidationFailure).isServerMessage, isTrue);
  });

  test("the envelope's message is used when there are no field errors", () {
    final mapped = mapRemoteFailure(
      rc.Unauthorized(
        response: response(403, <String, dynamic>{
          'message': 'This account has been deactivated.',
        }),
      ),
    );

    expect(mapped.message, 'This account has been deactivated.');
    expect((mapped as ForbiddenFailure).isServerMessage, isTrue);
  });

  test('a 2xx with success:false is a validation failure in its own words', () {
    final mapped = mapRemoteFailure(
      rc.BadResponse(
        message: 'Slot no longer available',
        response: response(200),
      ),
    );

    expect(mapped, isA<ValidationFailure>());
    expect(mapped.message, 'Slot no longer available');
    expect((mapped as ValidationFailure).isServerMessage, isTrue);
  });

  test('a 2xx with success:false and no message gets app copy', () {
    final mapped = mapRemoteFailure(rc.BadResponse(response: response(200)));

    expect(mapped, isA<ValidationFailure>());
    expect((mapped as ValidationFailure).isServerMessage, isFalse);
  });

  test('an unexpected 2xx gets app copy, not the client text', () {
    final mapped = mapRemoteFailure(
      rc.BadResponse(message: 'Unknown error: x', response: response(206)),
    );

    expect(mapped, isA<ServerFailure>());
    expect(mapped.message, isNot(contains('Unknown error')));
  });

  test('404 and 5xx bodies never reach the user', () {
    const leak = 'SQLSTATE[23000]: Integrity constraint violation';
    for (final failure in <rc.Failure>[
      rc.NotFound(response: response(404, <String, dynamic>{'message': leak})),
      rc.InternalServerError(
        response: response(500, <String, dynamic>{'message': leak}),
      ),
      rc.ServiceUnavailable(
        response: response(503, <String, dynamic>{
          'errors': <String, dynamic>{'db': leak},
        }),
      ),
    ]) {
      expect(mapRemoteFailure(failure).message, isNot(contains('SQLSTATE')));
    }
  });

  test('403 is forbidden, not an expired session', () {
    final bare = mapRemoteFailure(rc.Unauthorized(response: response(403)));
    final worded = mapRemoteFailure(
      rc.Unauthorized(
        response: response(403, <String, dynamic>{'message': 'Admins only.'}),
      ),
    );
    final expired = mapRemoteFailure(rc.Unauthorized(response: response(401)));

    expect(bare, isA<ForbiddenFailure>());
    expect(bare.message, isNot(contains('expired')));
    expect(worded.message, 'Admins only.');
    expect((bare as ForbiddenFailure).isServerMessage, isFalse);
    expect((worded as ForbiddenFailure).isServerMessage, isTrue);
    expect(expired, isA<UnauthorizedFailure>());
  });

  test('without server words, the copy follows the status', () {
    final notFound = mapRemoteFailure(
      rc.NotFound(message: diagnostic, response: response(404)),
    );
    final tooMany = mapRemoteFailure(
      rc.BadResponse(message: diagnostic, response: response(429)),
    );
    final noResponse = mapRemoteFailure(const rc.InternalServerError());

    expect(notFound.message, contains('could not find'));
    expect(tooMany.message, contains('Too many requests'));
    expect(noResponse, isA<ServerFailure>());
    expect((noResponse as ServerFailure).statusCode, 0);
  });

  test('field errors skip nulls and nested values', () {
    final mapped = mapRemoteFailure(
      rc.BadRequest(
        response: response(422, <String, dynamic>{
          'errors': <String, dynamic>{
            'a': null,
            'b': <String, dynamic>{'x': 'y'},
            'c': <dynamic>['Real reason.', 3, null],
          },
        }),
      ),
    );

    expect(mapped.message, 'Real reason.');
  });

  test('blank or non-string server words fall back to app copy', () {
    final mapped = mapRemoteFailure(
      rc.BadRequest(
        response: response(400, <String, dynamic>{
          'message': '  ',
          'errors': <String, dynamic>{},
        }),
      ),
    );

    expect(mapped.message, contains('check the details'));
    expect((mapped as ValidationFailure).isServerMessage, isFalse);
  });
}
