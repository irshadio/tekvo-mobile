import 'dart:async';

import 'package:core/assets/assets.gen.dart';
import 'package:core/error/failure.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/failure_message.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:core/utils/otp_input.dart';
import 'package:core/utils/social_account.dart';
import 'package:customer/features/auth/presentation/view/widgets/mobile_number_form.dart';
import 'package:customer/features/auth/presentation/view/widgets/or_divider.dart';
import 'package:customer/features/auth/presentation/view/widgets/sign_in_top_bar.dart';
import 'package:customer/features/auth/presentation/view/widgets/social_sign_in_button.dart';
import 'package:customer/features/auth/presentation/view/widgets/terms_note.dart';
import 'package:customer/features/auth/presentation/view_model/mobile_number_view_model.dart';
import 'package:customer/features/auth/presentation/view_model/social_sign_in_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Sign in or create an account with a mobile number, Google or Apple; or
/// skip and browse. A Google or Apple sign-in goes on to add a mobile
/// number.
class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  /// How long the screen takes to push in from notifications.
  static const Duration entryDuration = Duration(milliseconds: 300);

  static const double _sectionGap = 28;
  static const double _termsMinGap = 24;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listenSubmission(
      socialSignInViewModelProvider,
      context,
      onSuccess: (account) => unawaited(
        context.pushNamed<void>(Routes.verifyMobile, arguments: account),
      ),
      // A cancelled sign-in needs no message.
      onFailure: (failure) {
        if (failure is CancelledFailure) return;
        context.showSnackBar(context.failureMessage(failure), isError: true);
      },
    );
    final signingIn = ref.watch(socialSignInViewModelProvider).isInProgress;
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    void signIn(SocialProvider provider) => unawaited(
      ref.read(socialSignInViewModelProvider.notifier).signIn(provider),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(colors),
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SignInTopBar(
                        onSkip: () => unawaited(
                          context.pushNamedAndRemoveAll<void>(Routes.home),
                        ),
                      ),
                      SizedBox(height: _sectionGap.h),
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.signInTitle,
                          style: text.headlineMedium,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        l10n.signInBody(OtpInput.length),
                        style: text.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: _sectionGap.h),
                      MobileNumberForm(
                        step: NumberStep.signIn,
                        submitLabel: l10n.signInContinue,
                      ),
                      SizedBox(height: _sectionGap.h),
                      OrDivider(label: l10n.signInOr),
                      SizedBox(height: AppSpacing.s20.h),
                      SocialSignInButton(
                        logo: Assets.socialGoogle,
                        label: l10n.signInGoogle,
                        onPressed: signingIn
                            ? null
                            : () => signIn(SocialProvider.google),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      SocialSignInButton(
                        logo: Assets.socialApple,
                        label: l10n.signInApple,
                        tintLogo: true,
                        onPressed: signingIn
                            ? null
                            : () => signIn(SocialProvider.apple),
                      ),
                      SizedBox(height: _termsMinGap.h),
                      const Spacer(),
                      const TermsNote(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
