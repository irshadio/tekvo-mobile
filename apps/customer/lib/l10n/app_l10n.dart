import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension AppL10nX on BuildContext {
  /// The customer app's strings in the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
