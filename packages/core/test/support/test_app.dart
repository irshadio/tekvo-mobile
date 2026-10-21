import 'package:core/l10n/app_locale.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A [MaterialApp] set up as the app sets it up: design scaling, theme and
/// localizations, in [locale] (default: the app's).
Widget testApp({
  Widget? home,
  Map<String, WidgetBuilder> routes = const <String, WidgetBuilder>{},
  RouteFactory? onGenerateRoute,
  List<NavigatorObserver> navigatorObservers = const <NavigatorObserver>[],
  GlobalKey<NavigatorState>? navigatorKey,
  TransitionBuilder? builder,
  Locale locale = AppLocale.current,
}) => DesignScale(
  builder: (_) => MaterialApp(
    theme: AppTheme.light,
    locale: locale,
    supportedLocales: AppLocale.supported,
    localizationsDelegates: AppLocale.delegates,
    home: home,
    routes: routes,
    onGenerateRoute: onGenerateRoute,
    navigatorObservers: navigatorObservers,
    navigatorKey: navigatorKey,
    builder: builder,
  ),
);
