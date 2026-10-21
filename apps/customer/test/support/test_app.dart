import 'package:core/l10n/app_locale.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/theme/app_theme.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// A [MaterialApp] set up as the customer app sets it up: design scaling,
/// both themes and both sets of localizations.
Widget testApp({
  Widget? home,
  RouteFactory? onGenerateRoute,
  ThemeMode themeMode = ThemeMode.light,
}) => DesignScale(
  builder: (_) => MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      ...AppLocalizations.localizationsDelegates,
      ...AppLocale.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
    onGenerateRoute: onGenerateRoute,
  ),
);
