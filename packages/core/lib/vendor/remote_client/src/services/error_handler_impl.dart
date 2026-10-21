import 'package:dio/dio.dart';

import '../contracts/error_handler.dart';
import '../models/base_response.dart';
import '../types/either.dart';
import '../types/failure.dart';

/// Default error handler implementation
class ErrorHandlerImpl implements ErrorHandler {
  @override
  Failure handleDioException(DioException exception) {
    // Extract request ID for better error context
    final String? requestId =
        exception.requestOptions.extra['requestId'] as String?;
    final String requestIdContext = requestId != null
        ? ' [Request ID: $requestId]'
        : '';

    // Build enhanced error message with context
    String buildMessage(String baseMessage) {
      final String message = baseMessage + requestIdContext;
      if (exception.requestOptions.uri.toString().isNotEmpty) {
        return '$message [URI: ${exception.requestOptions.uri}]';
      }
      return message;
    }

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return ConnectionTimeout(
          message: buildMessage(exception.message ?? 'Connection timeout'),
          response: exception.response,
        );

      case DioExceptionType.sendTimeout:
        return SendTimeout(
          message: buildMessage(exception.message ?? 'Send timeout'),
          response: exception.response,
        );

      case DioExceptionType.receiveTimeout:
        return ReceiveTimeout(
          message: buildMessage(exception.message ?? 'Receive timeout'),
          response: exception.response,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(exception.response, requestIdContext);

      case DioExceptionType.cancel:
        return Cancelled(message: 'Request cancelled$requestIdContext');

      case DioExceptionType.unknown:
        if (_isSocketFailure(exception)) {
          return NoInternet(
            message:
                'Network error, please check your internet connection$requestIdContext',
          );
        }
        return ConnectionError(
          message: buildMessage(exception.message ?? 'Connection error'),
          response: exception.response,
        );

      case DioExceptionType.badCertificate:
        return BadCertificate(
          message: buildMessage(exception.message ?? 'Bad certificate'),
          response: exception.response,
        );

      // Modified downstream: `connectionError` is where a device with no
      // network actually arrives. dio's IO adapter catches the `SocketException`
      // and raises THIS type (dio 5.11 `src/adapters/io_adapter.dart:131`), not
      // `unknown` — so upstream's socket check above never fired and `NoInternet`
      // was unreachable. See VENDOR.md (divergence 4).
      case DioExceptionType.connectionError:
        if (_isSocketFailure(exception)) {
          return NoInternet(
            message:
                'Network error, please check your internet connection$requestIdContext',
          );
        }
        return ConnectionError(
          message: buildMessage(exception.message ?? 'Connection error'),
          response: exception.response,
        );

      // Added downstream: dio 5.11 introduced this case after upstream 1.0.1
      // was published. Raised when transforming the response body exceeds the
      // budget, so it is reported as a receive-side timeout rather than adding
      // a new Failure subtype to the sealed union (which would be a breaking
      // API change). See VENDOR.md (divergence 2).
      case DioExceptionType.transformTimeout:
        return ReceiveTimeout(
          message: buildMessage(exception.message ?? 'Transform timeout'),
          response: exception.response,
        );
    }
  }

  @override
  Either<Failure, BaseResponse<T>> validateResponse<T>(
    BaseResponse<T> response,
  ) {
    // Modified downstream: every failure below now carries `_statusCarrier`.
    // Upstream built them with no `response:` at all, so a consumer reading
    // `failure.response?.statusCode` got null and reported the status as 0.
    // See VENDOR.md (divergence 4).
    final Response<dynamic> carrier = _statusCarrier(response);

    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
        // Modified downstream: the envelope's `success` flag is authoritative,
        // and upstream never consulted it — `BaseResponse.isSuccess` exists and
        // was dead code. A 2xx carrying `{"success": false}` was handed back as
        // a success with a null or partial payload, which shows a write that did
        // not happen as having happened. See VENDOR.md (divergence 4).
        // The message is the server's own or null: consumers supply their
        // own (localized) copy when the server gave none.
        if (!response.success) {
          return Left<Failure, BaseResponse<T>>(
            BadResponse(message: response.message, response: carrier),
          );
        }
        return Right<Failure, BaseResponse<T>>(response);
      case 400:
        return Left<Failure, BaseResponse<T>>(
          BadRequest(message: response.message, response: carrier),
        );
      case 401:
        return Left<Failure, BaseResponse<T>>(
          Unauthorized(message: response.message, response: carrier),
        );
      case 403:
        return Left<Failure, BaseResponse<T>>(
          Unauthorized(message: response.message, response: carrier),
        );
      case 404:
        return Left<Failure, BaseResponse<T>>(
          NotFound(message: response.message, response: carrier),
        );
      case 422:
        return Left<Failure, BaseResponse<T>>(
          BadRequest(message: response.message, response: carrier),
        );
      case 500:
        return Left<Failure, BaseResponse<T>>(
          InternalServerError(message: response.message, response: carrier),
        );
      case 503:
        return Left<Failure, BaseResponse<T>>(
          ServiceUnavailable(
            message:
                "Service temporarily unavailable. ${response.message ?? ''}",
            response: carrier,
          ),
        );
      default:
        return Left<Failure, BaseResponse<T>>(
          BadResponse(
            message: "Unknown error: ${response.message ?? ''}",
            response: carrier,
          ),
        );
    }
  }

  /// Added downstream: whether a `DioException` was ultimately caused by the
  /// device being unable to use the network at all.
  ///
  /// Kept as a runtimeType check rather than an `is SocketException`, following
  /// upstream's own reason for the technique: this file must not import
  /// `dart:io`, which would cost the package its web support.
  static bool _isSocketFailure(DioException exception) {
    final String errorType = exception.error?.runtimeType.toString() ?? '';
    return errorType.contains('SocketException') ||
        errorType.contains('NetworkException');
  }

  /// Added downstream: carries a validated response's HTTP status on the
  /// `Response` that every `Failure` already has a slot for.
  ///
  /// `validateResponse` is handed a parsed `BaseResponse`, not the original
  /// `Response`, so there is nothing else to attach; this is a carrier for the
  /// status code, not a reconstruction of the wire response.
  static Response<dynamic> _statusCarrier(BaseResponse<dynamic> response) =>
      Response<dynamic>(
        requestOptions: RequestOptions(),
        statusCode: response.statusCode,
      );

  Failure _handleBadResponse(
    Response<dynamic>? response,
    String requestIdContext,
  ) {
    String? message;

    // Try to extract message from response
    if (response?.data is Map<String, dynamic>) {
      final Map<String, dynamic> dataMap =
          response?.data as Map<String, dynamic>;
      message = dataMap['message'] as String?;
    }

    message ??= response?.statusMessage ?? 'Invalid server response';

    // Add request ID context to message
    final String enhancedMessage = message + requestIdContext;

    // Add status code context if available
    final String statusCodeContext = response?.statusCode != null
        ? ' [Status: ${response?.statusCode}]'
        : '';

    switch (response?.statusCode) {
      case 400:
        return BadRequest(
          message: enhancedMessage + statusCodeContext,
          response: response,
        );
      case 401:
      case 403:
        return Unauthorized(
          message: enhancedMessage + statusCodeContext,
          response: response,
        );
      case 404:
        return NotFound(
          message: enhancedMessage + statusCodeContext,
          response: response,
        );
      case 422:
        return BadRequest(
          message: enhancedMessage + statusCodeContext,
          response: response,
        );
      case 500:
        return InternalServerError(
          message: enhancedMessage + statusCodeContext,
          response: response,
        );
      case 503:
        return ServiceUnavailable(
          message: enhancedMessage + statusCodeContext,
          response: response,
        );
      default:
        return BadResponse(
          message: enhancedMessage + statusCodeContext,
          response: response,
        );
    }
  }
}
