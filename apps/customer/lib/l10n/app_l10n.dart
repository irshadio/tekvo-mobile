import 'package:core/utils/social_account.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension AppL10nX on BuildContext {
  /// The customer app's strings in the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsX on AppLocalizations {
  /// [provider]'s name as shown to the user.
  String providerName(SocialProvider provider) => switch (provider) {
    SocialProvider.google => providerGoogle,
    SocialProvider.apple => providerApple,
  };
}
