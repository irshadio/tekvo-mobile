import 'package:core/error/failure.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/failure_message.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Default view for `ViewState.loading`.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          if (message != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(message),
          ],
        ],
      ),
    );
  }
}

/// Default view for `ViewState.error`: the failure's user-facing message and
/// an optional retry.
class AppErrorView extends StatelessWidget {
  const AppErrorView({required this.failure, super.key, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => _MessageView(
    icon: Icons.error_outline,
    iconColor: Theme.of(context).colorScheme.error,
    message: context.failureMessage(failure),
    onRetry: onRetry,
  );
}

/// Default view for `ViewState.noInternet`.
class AppNoInternetView extends StatelessWidget {
  const AppNoInternetView({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => _MessageView(
    icon: Icons.wifi_off,
    message: context.coreL10n.errorNoConnection,
    onRetry: onRetry,
  );
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.message,
    this.iconColor,
    this.onRetry,
  });

  final IconData icon;
  final Color? iconColor;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final onRetry = this.onRetry;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: onRetry,
                child: Text(context.coreL10n.commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
