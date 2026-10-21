import 'package:core/bootstrap/bootstrap.dart';
import 'package:core/bootstrap/error_handling.dart';
import 'package:core/config/app_environment.dart';
import 'package:core/error/error_reporter.dart';
import 'package:core/logging/app_logger.dart';
import 'package:core/presentation/widgets/startup_failure_app.dart';
import 'package:core/theme/app_fonts.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

/// Starts an app: installs the global error handlers, binds the core
/// overrides and [featureOverrides] for [env], and runs [app] with the
/// flavour's title for [appName].
///
/// The logger and reporter are created here because the global handlers fire
/// outside the widget tree and must share the instances bound for the app.
/// [userDataStores] names the local stores wiped when the session ends.
Future<void> startApp({
  required AppEnvironment env,
  required String appName,
  required List<Override> featureOverrides,
  required Widget Function(String title) app,
  List<String> userDataStores = const <String>[],
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppLogger logger = ConsoleLogger(minLevel: env.config.minLogLevel);
  final ErrorReporter reporter = LoggingErrorReporter(logger);
  installErrorHandlers(reporter);
  AppFonts.registerLicenses();

  logger.info('Starting $appName (${env.config.name})');

  final List<Override> overrides;
  try {
    overrides = [
      ...await buildCoreOverrides(
        env: env,
        logger: logger,
        reporter: reporter,
        userDataStores: userDataStores,
      ),
      ...featureOverrides,
    ];
  } on Object catch (error, stackTrace) {
    // A misconfigured build or unusable storage: never a frozen launch screen.
    reporter.report(error, stackTrace, context: 'startup');
    runApp(const StartupFailureApp());
    return;
  }

  runApp(
    buildRoot(
      reporter: reporter,
      overrides: overrides,
      child: app(env.appTitle(appName)),
    ),
  );
}
