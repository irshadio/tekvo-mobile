import 'dart:math' as math;

import 'package:dio/dio.dart';

import '../models/retry_policy.dart';

/// Added downstream: RFC 9110 date parsing for `Retry-After`. `HttpDate` lives
/// in `dart:io`, which this package avoids so it keeps working on the web, so
/// the two formats are parsed here instead.
abstract final class HttpDate {
  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Parses the IMF-fixdate form, e.g. `Wed, 21 Oct 2015 07:28:00 GMT`, which
  /// is the only form a conforming server may send. Returns null for anything
  /// else rather than throwing — an unparseable header just means "no advice".
  static DateTime? tryParse(String value) {
    final RegExpMatch? match = RegExp(
      r'^\w{3}, (\d{2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) GMT$',
    ).firstMatch(value.trim());
    if (match == null) {
      return null;
    }
    final int monthIndex = _months.indexOf(match.group(2)!);
    if (monthIndex < 0) {
      return null;
    }
    return DateTime.utc(
      int.parse(match.group(3)!),
      monthIndex + 1,
      int.parse(match.group(1)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6)!),
    );
  }
}

/// Interceptor that implements retry logic with exponential backoff and jitter
/// Follows enterprise best practices for HTTP retry mechanisms
/// Performance-optimized: Uses efficient retry logic with minimal overhead
class RetryInterceptor extends Interceptor {
  final RetryPolicy _policy;
  final Dio _dio;
  final math.Random _random = math.Random();

  RetryInterceptor({required Dio dio, RetryPolicy? policy})
    : _dio = dio,
      _policy = policy ?? RetryPolicy.defaultPolicy;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final int retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    // Check if we should retry (early exit for performance)
    if (!_shouldRetry(err, retryCount)) {
      handler.next(err);
      return;
    }

    // Calculate delay with exponential backoff and jitter, or honour the
    // server's own Retry-After. Null means "do not retry after all".
    final int? delay = _calculateDelay(retryCount, err);
    if (delay == null) {
      handler.next(err);
      return;
    }

    // Added downstream: a retry that would land past the caller's wall-clock
    // deadline is not a retry, it is a longer wait for the same failure. See
    // kRetryDeadlineExtraKey.
    if (_exceedsDeadline(err.requestOptions, delay)) {
      handler.next(err);
      return;
    }

    // Wait before retrying
    await Future<void>.delayed(Duration(milliseconds: delay));

    // Update retry count
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    // Clone the request options to avoid modifying the original
    final RequestOptions options = err.requestOptions;

    // Retry the request
    try {
      final Response<dynamic> response = await _retryRequest(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    } on Object {
      // If retry also fails with non-Dio error, proceed with the original error
      handler.next(err);
    }
  }

  /// Determines if a request should be retried based on error type and retry policy
  bool _shouldRetry(DioException error, int retryCount) {
    // Don't retry if max retries exceeded
    if (retryCount >= _policy.maxRetries) {
      return false;
    }

    // Don't retry if request was cancelled
    if (error.type == DioExceptionType.cancel) {
      return false;
    }

    // Custom retry logic
    if (_policy.shouldRetry != null) {
      return _policy.shouldRetry!(error);
    }

    // Check error type
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return _policy.retryOnTimeout;

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return _policy.retryOnConnectionError;

      case DioExceptionType.badResponse:
        return _shouldRetryOnStatus(error.response?.statusCode);

      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        // Don't retry on certificate errors or cancelled requests
        return false;

      // Added downstream: dio 5.11 introduced this case after upstream 1.0.1
      // was published. A transform timeout is a timeout, so it follows
      // retryOnTimeout like the three above. See VENDOR.md (divergence 2).
      case DioExceptionType.transformTimeout:
        return _policy.retryOnTimeout;
    }
  }

  /// Determines if a status code should trigger a retry
  bool _shouldRetryOnStatus(int? statusCode) {
    if (statusCode == null) {
      return false;
    }

    // Never retry on 4xx client errors (except 429 if in retryable codes)
    if (statusCode >= 400 && statusCode < 500) {
      // 429 (Too Many Requests) might be retryable
      return _policy.retryableStatusCodes.contains(statusCode);
    }

    // Retry on 5xx server errors if enabled
    if (statusCode >= 500 && statusCode < 600) {
      if (!_policy.retryOnServerError) {
        return false;
      }
      // If specific status codes are set, only retry those
      if (_policy.retryableStatusCodes.isNotEmpty) {
        return _policy.retryableStatusCodes.contains(statusCode);
      }
      return true;
    }

    return false;
  }

  /// Calculates the wait before the next attempt, or null when the answer is
  /// "do not retry".
  ///
  /// Modified downstream in two ways. See VENDOR.md (divergence 5).
  ///
  /// **`Retry-After` is honoured.** A server shedding load (429, or a 503
  /// during a deploy) says how long to wait; ignoring it and retrying on our
  /// own schedule is what turns a busy server into an unavailable one. A value
  /// longer than `maxDelayMs` returns null instead: making the customer stare
  /// at a spinner for a minute is worse than telling them now.
  ///
  /// **Jitter has a floor.** Upstream used full jitter — `nextInt(delay)`,
  /// uniform on `[0, delay)` — so a retry could fire ~0ms after the failure and
  /// the exponential backoff it had just computed meant nothing. This is equal
  /// jitter: half the delay fixed, half random, which keeps the spread that
  /// prevents a thundering herd AND the growth that gives a struggling server
  /// room.
  int? _calculateDelay(int retryCount, DioException error) {
    final int? retryAfterMs = _retryAfterMs(error.response);
    if (retryAfterMs != null) {
      if (retryAfterMs > _policy.maxDelayMs) {
        return null;
      }
      return retryAfterMs;
    }

    // Exponential backoff: initialDelay * (multiplier ^ retryCount)
    final int exponentialDelay =
        (_policy.initialDelayMs *
                math.pow(_policy.backoffMultiplier, retryCount))
            .round();

    // Cap first, so the jitter is spread across the delay actually used.
    final int cappedDelay = math.min(exponentialDelay, _policy.maxDelayMs);

    if (!_policy.useJitter) {
      return cappedDelay;
    }

    // Equal jitter: half fixed, half random.
    final int half = cappedDelay ~/ 2;
    return half + (half > 0 ? _random.nextInt(half) : 0);
  }

  /// Added downstream: the server's own `Retry-After`, in milliseconds.
  ///
  /// Both forms of the header are accepted — delta-seconds (`Retry-After: 30`)
  /// and an HTTP date (RFC 9110 §10.2.3). A date already in the past means
  /// "now", so it clamps to zero.
  int? _retryAfterMs(Response<dynamic>? response) {
    final String? header = response?.headers.value('retry-after');
    if (header == null) {
      return null;
    }

    final int? seconds = int.tryParse(header.trim());
    if (seconds != null) {
      return seconds < 0 ? 0 : seconds * 1000;
    }

    final DateTime? until = HttpDate.tryParse(header);
    if (until == null) {
      return null;
    }
    final int ms = until.difference(DateTime.now()).inMilliseconds;
    return ms < 0 ? 0 : ms;
  }

  /// Added downstream: whether waiting [delayMs] and trying again would carry
  /// the request past the wall-clock deadline its caller set.
  ///
  /// No deadline in `extra` means no budget to exceed, and the request keeps
  /// upstream's behaviour.
  bool _exceedsDeadline(RequestOptions options, int delayMs) {
    final Object? raw = options.extra[kRetryDeadlineExtraKey];
    if (raw is! int) {
      return false;
    }
    final int nextAttemptAt = DateTime.now().millisecondsSinceEpoch + delayMs;
    return nextAttemptAt >= raw;
  }

  /// Retries the request using the same Dio instance
  Future<Response<dynamic>> _retryRequest(RequestOptions options) {
    // Use Dio's fetch method to retry the request with the same options
    return _dio.fetch(options);
  }
}
