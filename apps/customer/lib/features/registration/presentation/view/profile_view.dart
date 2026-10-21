import 'dart:async';

import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/widgets/app_text_field.dart';
import 'package:core/presentation/widgets/back_bar_scaffold.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/social_account.dart';
import 'package:customer/features/registration/presentation/view/widgets/step_progress.dart';
import 'package:customer/features/registration/presentation/view_model/profile_view_model.dart';
import 'package:customer/features/registration/presentation/view_model/save_profile_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The last sign-up step: the user's name and, optionally, email. After a
/// Google or Apple sign-in both come filled in from [account] to check.
/// Saving opens home on its own.
class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({this.account, super.key});

  final SocialAccount? account;

  /// The sign-up steps, all done by this one.
  static const int steps = 3;

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  static const double _titleGap = 20;
  static const double _fieldsGap = 28;
  static const double _noteIcon = 18;

  late final TextEditingController _name = TextEditingController(
    text: widget.account?.name,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.account?.email,
  );
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    if (account != null) {
      // Filled after the first frame: a provider can't change while the
      // tree builds.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(profileViewModelProvider.notifier)
            .fill(name: account.name, email: account.email);
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _save() {
    final form = ref.read(profileViewModelProvider);
    if (!form.isComplete) return;
    FocusScope.of(context).unfocus();
    unawaited(ref.read(saveProfileViewModelProvider.notifier).save(form));
  }

  @override
  Widget build(BuildContext context) {
    ref.listenSubmission(
      saveProfileViewModelProvider,
      context,
      onSuccess: (_) =>
          unawaited(context.pushNamedAndRemoveAll<void>(Routes.home)),
    );
    final form = ref.watch(profileViewModelProvider);
    final saving = ref.watch(saveProfileViewModelProvider).isInProgress;
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final account = widget.account;
    final provider = account == null
        ? null
        : l10n.providerName(account.provider);

    return BackBarScaffold(
      children: <Widget>[
        SizedBox(height: AppSpacing.sm.h),
        const StepProgress(
          steps: ProfileView.steps,
          done: ProfileView.steps,
        ),
        SizedBox(height: _titleGap.h),
        Semantics(
          header: true,
          child: Text(
            provider == null ? l10n.profileTitle : l10n.profileCheckTitle,
            style: text.headlineMedium,
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          provider == null ? l10n.profileBody : l10n.profileCheckBody(provider),
          style: text.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: _fieldsGap.h),
        _labelled(
          context,
          l10n.profileNameLabel,
          AppTextField(
            controller: _name,
            focusNode: _nameFocus,
            icon: Assets.iconsPerson,
            hint: l10n.profileNameHint,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[
              AutofillHints.name,
            ],
            onChanged: ref.read(profileViewModelProvider.notifier).nameChanged,
            onSubmitted: (_) => _emailFocus.requestFocus(),
          ),
        ),
        SizedBox(height: AppSpacing.s20.h),
        _labelled(
          context,
          l10n.profileEmailLabel,
          AppTextField(
            controller: _email,
            focusNode: _emailFocus,
            icon: Assets.iconsMail,
            iconColor: colors.onSurface,
            hint: l10n.profileEmailHint,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[
              AutofillHints.email,
            ],
            onChanged: ref.read(profileViewModelProvider.notifier).emailChanged,
            onSubmitted: (_) => _save(),
          ),
        ),
        SizedBox(height: AppSpacing.s20.h),
        _note(
          context,
          icon: provider == null ? Assets.iconsMail : Assets.benefitShield,
          text: provider == null
              ? l10n.profileEmailNote
              : l10n.profileVerifiedNote(provider),
        ),
        SizedBox(height: _fieldsGap.h),
        const Spacer(),
        FilledButton(
          onPressed: form.isComplete && !saving ? _save : null,
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(
              AppSizes.controlXl.h,
            ),
            textStyle: text.titleMedium,
          ),
          child: Text(
            provider == null ? l10n.profileContinue : l10n.profileLooksGood,
          ),
        ),
      ],
    );
  }

  Widget _labelled(BuildContext context, String label, Widget field) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: AppSpacing.sm.h,
    children: <Widget>[
      Text(label, style: context.textTheme.labelLarge),
      field,
    ],
  );

  Widget _note(
    BuildContext context, {
    required String icon,
    required String text,
  }) {
    final colors = context.colors;
    return Row(
      spacing: AppSpacing.sm.w,
      children: <Widget>[
        SvgPicture.asset(
          icon,
          width: _noteIcon.r,
          height: _noteIcon.r,
          colorFilter: ColorFilter.mode(
            colors.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
