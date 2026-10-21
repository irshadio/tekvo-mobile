/// Format check for a one-time code. For UX only: the server verifies it.
abstract final class OtpInput {
  static const int length = 6;

  static final RegExp _code = RegExp('^[0-9]{$length}\$');

  static bool isComplete(String code) => _code.hasMatch(code);
}
