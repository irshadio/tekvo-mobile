import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// The app-wide error vocabulary. Every layer that can fail returns a
/// [Failure] on the `Left` of an `Either`; transport failures are translated
/// at the data boundary (`failure_mapper.dart`).
///
/// `message` is safe for users (no status codes, URIs or correlation IDs) but
/// is English: screens show `context.failureMessage`, which is localized and
/// keeps only server-written words (`isServerMessage`) as they are. `detail`
/// holds diagnostic text for error reports and is never rendered.
@freezed
sealed class Failure with _$Failure {
  /// Transport problem (socket, DNS, TLS) without a clean HTTP status.
  const factory Failure.network({required String message, String? detail}) =
      NetworkFailure;

  /// The server answered with a non-2xx status.
  const factory Failure.server({
    required int statusCode,
    required String message,
    String? detail,
  }) = ServerFailure;

  const factory Failure.timeout({
    @Default('The request timed out') String message,
    String? detail,
  }) = TimeoutFailure;

  /// No usable network. Maps to `ViewState.noInternet`.
  const factory Failure.noConnection({
    @Default('No internet connection') String message,
    String? detail,
  }) = NoConnectionFailure;

  /// The session is not valid (401).
  const factory Failure.unauthorized({
    @Default('Your session has expired') String message,
    String? detail,
    @Default(false) bool isServerMessage,
  }) = UnauthorizedFailure;

  /// Signed in, but not allowed to do this (403). The session stays.
  const factory Failure.forbidden({
    @Default("You don't have permission to do that.") String message,
    String? detail,
    @Default(false) bool isServerMessage,
  }) = ForbiddenFailure;

  const factory Failure.cancelled({
    @Default('The request was cancelled') String message,
    String? detail,
  }) = CancelledFailure;

  /// Local persistence (secure storage / sembast) failed.
  const factory Failure.cache({required String message, String? detail}) =
      CacheFailure;

  /// Input or business-rule validation failed.
  const factory Failure.validation({
    required String message,
    String? detail,
    @Default(false) bool isServerMessage,
  }) = ValidationFailure;

  const factory Failure.unexpected({
    @Default('Something went wrong') String message,
    String? detail,
  }) = UnexpectedFailure;
}
