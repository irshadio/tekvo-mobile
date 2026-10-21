import 'package:core/error/failure.dart';
import 'package:core/l10n/app_locale.dart';
import 'package:core/l10n/generated/core_localizations.dart';
import 'package:core/presentation/extensions/failure_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  final l10n = lookupCoreLocalizations(AppLocale.current);
  String text(Failure failure) => localizedFailureMessage(failure, l10n);

  test('app-written failures use localized text, not their message', () {
    const english = 'english';
    expect(
      text(const Failure.network(message: english)),
      l10n.errorNetwork,
    );
    expect(
      text(const Failure.timeout(message: english)),
      l10n.errorTimeout,
    );
    expect(text(const Failure.noConnection()), l10n.errorNoConnection);
    expect(text(const Failure.unauthorized()), l10n.errorSessionExpired);
    expect(text(const Failure.forbidden()), l10n.errorForbidden);
    expect(text(const Failure.cancelled()), l10n.errorCancelled);
    expect(text(const Failure.cache(message: english)), l10n.errorStorage);
    expect(text(const Failure.unexpected()), l10n.errorUnexpected);
    expect(
      text(const Failure.validation(message: english)),
      l10n.errorValidation,
    );
  });

  test('server failures follow the status code', () {
    String server(int status) =>
        text(Failure.server(statusCode: status, message: 'english'));

    expect(server(404), l10n.errorNotFound);
    expect(server(409), l10n.errorConflict);
    expect(server(429), l10n.errorTooManyRequests);
    expect(server(503), l10n.errorServiceUnavailable);
    expect(server(500), l10n.errorServer);
  });

  test("the server's own words are kept as written", () {
    expect(
      text(
        const Failure.validation(
          message: 'Name is required',
          isServerMessage: true,
        ),
      ),
      'Name is required',
    );
    expect(
      text(
        const Failure.unauthorized(message: 'Blocked', isServerMessage: true),
      ),
      'Blocked',
    );
    expect(
      text(
        const Failure.forbidden(message: 'Admins only', isServerMessage: true),
      ),
      'Admins only',
    );
  });

  testWidgets('the context extension uses the app locale', (tester) async {
    late String message;
    await tester.pumpWidget(
      testApp(
        home: Builder(
          builder: (context) {
            message = context.failureMessage(const Failure.cancelled());
            return const SizedBox();
          },
        ),
      ),
    );

    expect(message, l10n.errorCancelled);
  });
}
