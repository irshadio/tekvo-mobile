import 'package:core/presentation/widgets/app_shell.dart';
import 'package:customer/app/route_generator.dart';
import 'package:customer/l10n/generated/app_localizations.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/widgets.dart';

/// Root widget: the shared app shell with this app's routes, starting at
/// splash.
class App extends StatelessWidget {
  const App({required this.title, super.key});

  /// The flavour's app title (task switcher, accessibility).
  final String title;

  @override
  Widget build(BuildContext context) => AppShell(
    title: title,
    onGenerateRoute: onGenerateRoute,
    initialRoute: Routes.splash,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
  );
}
