import 'package:core/l10n/app_locale.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/design_scale.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shown when start-up fails before the app can run. Generic text only; the
/// cause is reported, never displayed.
class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DesignScale(
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: AppLocale.current,
        supportedLocales: AppLocale.supported,
        localizationsDelegates: AppLocale.delegates,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                // A Builder: the localizations live below MaterialApp.
                child: Builder(
                  builder: (context) => Text(
                    context.coreL10n.startupFailed,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
