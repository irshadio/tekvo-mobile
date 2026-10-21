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

/// Explains location access, then shows the system prompt. Whatever the
/// answer, or without asking, it continues to notifications.
class LocationPermissionView extends ConsumerWidget {
  const LocationPermissionView({super.key});

  static const AppPermission _permission = AppPermission.location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = permissionViewModelProvider(_permission);
    void next(NotificationEntry entry) => unawaited(
      context.pushReplacementNamed<void, void>(
        Routes.notificationPermission,
        arguments: entry,
      ),
    );
    ref.listenSubmission(
      provider,
      context,
      onSuccess: (_) => next(NotificationEntry.afterPrompt),
      onFailure: (_) => next(NotificationEntry.afterPrompt),
    );
    final asking = ref.watch(provider).isInProgress;
    final l10n = context.l10n;
    return PermissionPrompt(
      icon: Assets.heroPin,
      title: l10n.locationPermissionTitle,
      body: l10n.locationPermissionBody,
      benefits: <PermissionBenefit>[
        (
          icon: Assets.benefitTruck,
          title: l10n.locationPermissionDatesTitle,
          detail: l10n.locationPermissionDatesBody,
        ),
        (
          icon: Assets.benefitPin,
          title: l10n.locationPermissionCheckoutTitle,
          detail: l10n.locationPermissionCheckoutBody,
        ),
        (
          icon: Assets.benefitShield,
          title: l10n.locationPermissionPrivacyTitle,
          detail: l10n.locationPermissionPrivacyBody,
        ),
      ],
      allowLabel: l10n.locationPermissionAllow,
      declineLabel: l10n.locationPermissionManual,
      note: l10n.locationPermissionNote,
      onAllow: asking
          ? null
          : () => unawaited(ref.read(provider.notifier).request()),
      onDecline: asking ? null : () => next(NotificationEntry.skipped),
    );
  }
}

/// How the notification step was reached, which sets how it comes in.
enum NotificationEntry {
  /// After the location prompt: it dissolves in.
  afterPrompt,

  /// Without asking for location: it slides in.
  skipped,
}
