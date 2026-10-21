import 'dart:async';

import 'package:dio/dio.dart';

import '../contracts/token_provider.dart';
import '../contracts/unauthorized_handler.dart';

/// HTTP interceptor that adds authentication headers and handles unauthorized responses
/// Uses QueuedInterceptor to serialize 401 handling and prevent concurrent token refreshes
///
/// Features:
/// - Async token retrieval from secure storage
/// - Automatic token refresh on 401 responses
/// - Request queueing during token refresh (prevents thundering herd)
/// - Automatic retry of failed requests after successful refresh
class AuthInterceptor extends QueuedInterceptor {
  final TokenProvider _tokenProvider;
  final UnauthorizedHandler _unauthorizedHandler;
  final Dio _dio;
  final String? _locale;

  /// Flag to prevent infinite refresh loops
  bool _isRefreshing = false;

  /// Completer to queue requests during token refresh
  Completer<String?>? _refreshCompleter;

  /// Dio used ONLY to replay a request after a successful refresh.
  ///
  /// Deliberately interceptor-free, and deliberately NOT [_dio]. Retrying
  /// through [_dio] re-enters this interceptor: `QueuedInterceptor` gives
  /// `onError` a single-slot queue, so a retry that is itself rejected needs
  /// the very slot the `onError` awaiting that retry is holding. The request
  /// then never completes, and because the slot is never released, EVERY later
  /// error in this interceptor queues behind it forever.
  ///
  /// It inherits [_dio]'s options so the replay keeps the same base URL and —
  /// importantly — the same timeouts; a bare `Dio` would wait forever.
  Dio? _retryClient;

  Dio get _retryDio =>
      _retryClient ??= Dio(_dio.options)
        ..httpClientAdapter = _dio.httpClientAdapter;

  /// Creates an [AuthInterceptor] that injects tokens and handles unauthorized responses.
  ///
  /// [dio] is required for retrying requests after token refresh.
  /// [tokenProvider] supplies access tokens for outbound requests.
  /// [unauthorizedHandler] is invoked when token refresh fails or is not possible.
  /// Optionally provide [locale] to include a locale header on each request.
  AuthInterceptor({
    required Dio dio,
    required TokenProvider tokenProvider,
    required UnauthorizedHandler unauthorizedHandler,
    String? locale,
  }) : _dio = dio,
       _tokenProvider = tokenProvider,
       _unauthorizedHandler = unauthorizedHandler,
       _locale = locale;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add authorization header if token is available
    final String? token = await _tokenProvider.getAccessToken();
    final bool hasValid = await _tokenProvider.hasValidToken();

    if (token != null && hasValid) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add locale header if provided
    if (_locale != null) {
      options.headers['locale'] = _locale;
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 unauthorized responses
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Check if this request already attempted refresh (prevent infinite loop)
    if (err.requestOptions.extra['_retryAfterRefresh'] == true) {
      await _unauthorizedHandler.handleUnauthorized();
      handler.next(err);
      return;
    }

    // Attempt token refresh
    final String? newToken = await _attemptTokenRefresh();

    if (newToken == null) {
      // Token refresh failed - notify unauthorized handler and pass error through
      await _unauthorizedHandler.handleUnauthorized();
      handler.next(err);
      return;
    }

    // Retry the original request with new token
    try {
      final RequestOptions retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';
      // Vestigial now that the replay cannot re-enter this interceptor, but
      // kept: it records the intent, and it still guards the branch above if
      // anyone installs interceptors on the retry client.
      retryOptions.extra['_retryAfterRefresh'] = true;

      final Response<dynamic> response = await _retryDio.fetch(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      // The replay bypasses this interceptor, so a 401 on it will not come
      // back through `onError` — this is the only place that can report it.
      // A token minted seconds ago being refused is as final as an answer
      // gets: the session is over.
      if (retryError.response?.statusCode == 401) {
        await _unauthorizedHandler.handleUnauthorized();
      }
      handler.next(retryError);
    } on Object {
      handler.next(err);
    }
  }

  /// Attempt to refresh the token, queuing concurrent requests
  ///
  /// Uses a Completer pattern to ensure:
  /// 1. Only one refresh operation runs at a time
  /// 2. All waiting requests receive the same result
  /// 3. No race condition when cleaning up state
  Future<String?> _attemptTokenRefresh() async {
    // If already refreshing, wait for the ongoing refresh
    if (_isRefreshing && _refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    // Capture completer in local variable to prevent race condition
    // This ensures the completer reference is stable during the operation
    final Completer<String?> completer = Completer<String?>();
    _isRefreshing = true;
    _refreshCompleter = completer;

    try {
      final String? newToken = await _tokenProvider.refreshToken();
      completer.complete(newToken);
      return newToken;
    } on Object {
      completer.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
      // Use microtask to delay cleanup, ensuring all waiters have received
      // the result before we null out the shared reference
      await Future<void>.microtask(() {
        if (_refreshCompleter == completer) {
          _refreshCompleter = null;
        }
      });
    }
  }
}
