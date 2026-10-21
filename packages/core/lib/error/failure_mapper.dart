import 'package:core/error/failure.dart';
import 'package:core/vendor/remote_client/remote_client.dart' as rc;

/// Translates a transport [rc.Failure] into the app [Failure]. The only place
/// the client's failure type is interpreted, so no `rc.*` type leaves `data/`.
///
/// `rc.Failure.errorMessage` is not user-facing: it carries framework text,
/// the request URI, a request ID and the status. It goes to `detail`.
///
/// The user-facing `message` is the server's own words (per-field `errors`,
/// else `message`) only where they are written for users: validation (400 /
/// 422), a 2xx answering `success: false`, and 401 / 403. 404 and 5xx always
/// get app copy, since their bodies can hold internal errors. The envelope
/// keys are pending confirmation against the real API.
Failure mapRemoteFailure(rc.Failure failure) {
  final statusCode = failure.response?.statusCode ?? 0;
  final detail = failure.errorMessage;

  return switch (failure) {
    rc.NoInternet() => Failure.noConnection(detail: detail),
    rc.ConnectionError() || rc.BadCertificate() => Failure.network(
      message: networkFailureMessage,
      detail: detail,
    ),
    rc.ConnectionTimeout() ||
    rc.SendTimeout() ||
    rc.ReceiveTimeout() => Failure.timeout(
      message: _timeoutMessage,
      detail: detail,
    ),
    rc.Unauthorized() when statusCode == 403 => switch (_serverWords(failure)) {
      final String message => Failure.forbidden(
        message: message,
        detail: detail,
        isServerMessage: true,
      ),
      null => Failure.forbidden(detail: detail),
    },
    rc.Unauthorized() => switch (_serverWords(failure)) {
      final String message => Failure.unauthorized(
        message: message,
        detail: detail,
        isServerMessage: true,
      ),
      null => Failure.unauthorized(detail: detail),
    },
    rc.BadRequest() => _validation(failure, detail),
    rc.BadResponse() when _isEnvelopeRejection(statusCode) => _validation(
      failure,
      detail,
    ),
    rc.NotFound() ||
    rc.BadResponse() ||
    rc.InternalServerError() ||
    rc.ServiceUnavailable() => Failure.server(
      statusCode: statusCode,
      message: _serverMessage(statusCode),
      detail: detail,
    ),
    rc.Cancelled() => Failure.cancelled(detail: detail),
    rc.Unexpected() => Failure.unexpected(detail: detail),
  };
}

Failure _validation(rc.Failure failure, String? detail) =>
    switch (_serverWords(failure)) {
      final String message => Failure.validation(
        message: message,
        detail: detail,
        isServerMessage: true,
      ),
      null => Failure.validation(message: _validationMessage, detail: detail),
    };

/// The one wording for "the server could not be reached".
const String networkFailureMessage =
    'We could not reach the server. Please check your connection and try '
    'again.';

const String _timeoutMessage =
    'The server took too long to respond. Please try again.';

const String _validationMessage =
    'We could not process that. Please check the details and try again.';

String _serverMessage(int statusCode) => switch (statusCode) {
  404 => 'We could not find what you were looking for.',
  409 => 'That has already been updated. Please refresh and try again.',
  429 => 'Too many requests. Please wait a moment and try again.',
  503 => 'The service is temporarily unavailable. Please try again shortly.',
  _ => 'Something went wrong on our end. Please try again in a moment.',
};

/// The statuses on which the client turns an envelope's `success: false`
/// into a failure; any other 2xx is an unexpected status.
bool _isEnvelopeRejection(int statusCode) =>
    const <int>{200, 201, 202, 204}.contains(statusCode);

/// What the server told the user, or null when it said nothing usable.
///
/// A non-2xx keeps its body on `response.data`. A 2xx answering
/// `success: false` keeps only a status carrier, and its `message` is the
/// envelope's own text with nothing appended.
String? _serverWords(rc.Failure failure) {
  final response = failure.response;
  final data = response?.data;
  if (data != null) return _fieldErrors(data) ?? _envelopeMessage(data);

  if (!_isEnvelopeRejection(response?.statusCode ?? 0)) return null;
  final message = failure.message?.trim();
  return message == null || message.isEmpty ? null : message;
}

String? _envelopeMessage(Object? data) {
  if (data is! Map<String, dynamic>) return null;
  final message = data['message'];
  if (message is! String || message.trim().isEmpty) return null;
  return message.trim();
}

/// Per-field `errors` (`{"email": ["Already taken."]}`) as one sentence.
String? _fieldErrors(Object? data) {
  if (data is! Map<String, dynamic>) return null;
  final errors = data['errors'];
  if (errors is! Map<String, dynamic> || errors.isEmpty) return null;

  final messages = <String>[
    for (final value in errors.values)
      if (value is List<dynamic>)
        ...value.whereType<String>()
      else if (value is String)
        value,
  ].map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
  return messages.isEmpty ? null : messages.join(' ');
}
