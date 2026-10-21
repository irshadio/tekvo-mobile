import 'package:core/l10n/generated/core_localizations.dart';
import 'package:flutter/widgets.dart';

/// Localization setup shared by every app root.
abstract final class AppLocale {
  /// The language shown until a language setting exists. Arabic is supported
  /// but not selected yet.
  static const Locale current = Locale('en');

  static const List<Locale> supported = CoreLocalizations.supportedLocales;

  static const List<LocalizationsDelegate<dynamic>> delegates =
      CoreLocalizations.localizationsDelegates;
}
