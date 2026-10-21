import 'dart:async';

import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/widgets/country_picker_sheet.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:core/utils/mobile_number.dart';
import 'package:core/utils/otp_input.dart';
import 'package:customer/features/auth/presentation/view/widgets/mobile_number_field.dart';
import 'package:customer/features/auth/presentation/view/widgets/or_divider.dart';
import 'package:customer/features/auth/presentation/view/widgets/sign_in_top_bar.dart';
import 'package:customer/features/auth/presentation/view/widgets/social_sign_in_button.dart';
import 'package:customer/features/auth/presentation/view/widgets/terms_note.dart';
import 'package:customer/features/auth/presentation/view_model/login_view_model.dart';
import 'package:customer/features/auth/presentation/view_model/send_code_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Sign in or create an account with a mobile number, Google or Apple; or
/// skip and browse. Continue texts a code to the number and opens its entry,
/// which pops `true` when the user wants to change the number.
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  /// How long the screen takes to push in from notifications.
  static const Duration entryDuration = Duration(milliseconds: 300);

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  static const double _sectionGap = 28;
  static const double _buttonGap = 20;
  static const double _termsMinGap = 24;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _continue() {
    // A second tap while the code screen slides in would push it twice.
    if (!(ModalRoute.isCurrentOf(context) ?? true)) return;
    final form = ref.read(loginViewModelProvider);
    if (!form.isValid) return;
    _focusNode.unfocus();
    unawaited(ref.read(sendCodeViewModelProvider.notifier).send(form.contact));
  }

  Future<void> _openCodeEntry() async {
    final change = await context.pushNamed<bool>(
      Routes.otp,
      arguments: ref.read(loginViewModelProvider).contact,
    );
    if (mounted && (change ?? false)) _focusNode.requestFocus();
  }

  void _pickCountry() => unawaited(
    CountryPickerSheet.show(
      context,
      selected: ref.read(loginViewModelProvider).country,
      onSelected: (country) {
        ref.read(loginViewModelProvider.notifier).selectCountry(country);
        final text = MobileNumber.group(
          ref.read(loginViewModelProvider).number,
        );
        _controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    ref.listenSubmission(
      sendCodeViewModelProvider,
      context,
      onSuccess: (_) => unawaited(_openCodeEntry()),
    );
    final form = ref.watch(loginViewModelProvider);
    final sending = ref.watch(sendCodeViewModelProvider).isInProgress;
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;

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
                      Text(l10n.signInNumberLabel, style: text.labelLarge),
                      SizedBox(height: AppSpacing.sm.h),
                      MobileNumberField(
                        controller: _controller,
                        focusNode: _focusNode,
                        country: form.country,
                        isValid: form.isValid,
                        onCountryTap: _pickCountry,
                        onChanged: ref
                            .read(loginViewModelProvider.notifier)
                            .numberChanged,
                        onSubmitted: _continue,
                      ),
                      SizedBox(height: _buttonGap.h),
                      FilledButton(
                        onPressed: form.isValid && !sending ? _continue : null,
                        style: FilledButton.styleFrom(
                          minimumSize: Size.fromHeight(AppSizes.controlXl.h),
                          textStyle: text.titleMedium,
                          animationDuration: MobileNumberField.duration,
                        ),
                        child: Text(l10n.signInContinue),
                      ),
                      SizedBox(height: _sectionGap.h),
                      OrDivider(label: l10n.signInOr),
                      SizedBox(height: _buttonGap.h),
                      SocialSignInButton(
                        logo: Assets.socialGoogle,
                        label: l10n.signInGoogle,
                        onPressed: _continueWithProvider,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      SocialSignInButton(
                        logo: Assets.socialApple,
                        label: l10n.signInApple,
                        tintLogo: true,
                        onPressed: _continueWithProvider,
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

  /// Opens the mobile number check that follows a Google or Apple sign-in.
  void _continueWithProvider() =>
      unawaited(context.pushNamed<void>(Routes.verifyMobile));
}
