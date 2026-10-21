import 'package:core/vendor/remote_client/remote_client.dart' as rc;
import 'package:dio/dio.dart';

/// Idempotent methods only: retrying a `POST` or `PATCH` after a timeout or
/// 5xx can duplicate a write the server already applied.
const Set<String> _idempotentMethods = <String>{
  'GET',
  'HEAD',
  'OPTIONS',
  'PUT',
  'DELETE',
};

/// The default retry triggers (connection errors, timeouts, 5xx) plus 429,
/// gated to idempotent methods. Backoff and `Retry-After` handling come from
/// the vendored `RetryInterceptor`.
const rc.RetryPolicy idempotentRetryPolicy = rc.RetryPolicy(
  shouldRetry: shouldRetryIdempotent,
);

bool shouldRetryIdempotent(Object? error) {
  if (error is! DioException) return false;
  if (!_idempotentMethods.contains(error.requestOptions.method.toUpperCase())) {
    return false;
  }
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.unknown => true,
    DioExceptionType.badResponse => const <int>{
      429,
      500,
      502,
      503,
      504,
    }.contains(error.response?.statusCode),
    DioExceptionType.badCertificate || DioExceptionType.cancel => false,
  };
}
