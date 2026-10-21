import 'package:core/config/app_environment_provider.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rider/config/app_identity.dart';

/// The first screen: the flavour's app title on the surface until the
/// designed splash replaces it.
class SplashView extends ConsumerWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(appEnvironmentProvider).appTitle(appName);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(context.colors),
      child: Scaffold(
        body: Center(
          child: Text(title, style: context.textTheme.headlineSmall),
        ),
      ),
    );
  }
}
