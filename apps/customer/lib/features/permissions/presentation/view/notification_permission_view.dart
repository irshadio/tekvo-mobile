import 'dart:async';

import 'package:core/assets/assets.gen.dart';
import 'package:core/permissions/permission_service.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/state/submission_state.dart';
import 'package:customer/features/permissions/presentation/view/widgets/permission_benefit.dart';
import 'package:customer/features/permissions/presentation/view/widgets/permission_prompt.dart';
import 'package:customer/features/permissions/presentation/view_model/permission_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Explains notifications, then shows the system prompt. Whatever the
/// answer, or without asking, it continues to sign in.
class NotificationPermissionView extends ConsumerWidget {
  const NotificationPermissionView({super.key});

  /// How long it takes to dissolve in after the location prompt.
  static const Duration entryFade = Duration(milliseconds: 300);

  static const AppPermission _permission = AppPermission.notifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = permissionViewModelProvider(_permission);
    void next() =>
        unawaited(context.pushReplacementNamed<void, void>(Routes.signIn));
    ref.listenSubmission(
      provider,
      context,
      onSuccess: (_) => next(),
      onFailure: (_) => next(),
    );
    final asking = ref.watch(provider).isInProgress;
    final l10n = context.l10n;
    return PermissionPrompt(
      icon: Assets.heroBell,
      title: l10n.notificationPermissionTitle,
      body: l10n.notificationPermissionBody,
      benefits: <PermissionBenefit>[
        (
          icon: Assets.benefitTruck,
          title: l10n.notificationPermissionOrdersTitle,
          detail: l10n.notificationPermissionOrdersBody,
        ),
        (
          icon: Assets.benefitTag,
          title: l10n.notificationPermissionPricesTitle,
          detail: l10n.notificationPermissionPricesBody,
        ),
        (
          icon: Assets.benefitSettings,
          title: l10n.notificationPermissionControlTitle,
          detail: l10n.notificationPermissionControlBody,
        ),
      ],
      allowLabel: l10n.notificationPermissionAllow,
      declineLabel: l10n.notificationPermissionLater,
      note: l10n.notificationPermissionNote,
      onAllow: asking
          ? null
          : () => unawaited(ref.read(provider.notifier).request()),
      onDecline: asking ? null : next,
    );
  }
}
