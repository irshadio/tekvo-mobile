import 'package:core/l10n/app_locale.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/presentation/widgets/offline_banner.dart';
import 'package:core/routing/app_routes.dart';
import 'package:core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The root every app renders: Navigator 1.0 through [onGenerateRoute],
/// always starting at [initialRoute], in the light or dark theme the system
/// asks for, with design scaling, localizations and the offline banner.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.title,
    required this.onGenerateRoute,
    required this.initialRoute,
    super.key,
  });

  /// The flavour's app title (task switcher, accessibility).
  final String title;

  final RouteFactory onGenerateRoute;

  final String initialRoute;

  /// The largest system text size the app follows; smaller sizes pass
  /// through unchanged.
  static const double maxTextScale = 1.3;

  @override
  Widget build(BuildContext context) {
    return DesignScale(
      builder: (context) => MaterialApp(
        title: title,
        debugShowCheckedModeBanner: false,
        navigatorKey: rootNavigatorKey,
        onGenerateRoute: onGenerateRoute,
        initialRoute: initialRoute,
        // A platform-supplied initial route (deep link) has no screen yet and
        // would stack "Page not found" pages.
        onGenerateInitialRoutes: (_) => <Route<dynamic>>[
          onGenerateRoute(RouteSettings(name: initialRoute))!,
        ],
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: AppLocale.current,
        supportedLocales: AppLocale.supported,
        localizationsDelegates: AppLocale.delegates,
        builder: (context, child) => MediaQuery.withClampedTextScaling(
          maxScaleFactor: maxTextScale,
          child: OfflineBanner(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
