import 'package:core/config/app_environment.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_environment_provider.g.dart';

/// The running flavour, bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
AppEnvironment appEnvironment(Ref ref) => throw UnimplementedError(
  'appEnvironmentProvider must be overridden in ProviderScope (core/bootstrap).',
);
