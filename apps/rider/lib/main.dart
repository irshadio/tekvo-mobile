import 'package:core/config/app_environment.dart';
import 'package:rider/app/run_app.dart';

/// Flavour-less entrypoint: the flavour comes from `APP_ENV` (default dev).
/// With `--flavor`, use the matching `main_<flavour>.dart`.
void main() => runRiderApp(AppEnvironment.fromEnv());
