import 'dart:async';

import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/back_bar_scaffold.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/social_account.dart';
import 'package:customer/features/auth/presentation/view/widgets/mobile_number_form.dart';
import 'package:customer/features/auth/presentation/view/widgets/skip_button.dart';
import 'package:customer/features/auth/presentation/view/widgets/terms_note.dart';
import 'package:customer/features/auth/presentation/view_model/mobile_number_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// After a Google or Apple sign-in: add a mobile number and verify it with a
/// code, or skip to the profile and add it later.
class VerifyMobileView extends StatelessWidget {
  const VerifyMobileView({required this.account, super.key});

  final SocialAccount account;

  static const double _titleGap = 24;
  static const double _sectionGap = 28;
  static const double _noteGap = 14;
  static const double _termsMinGap = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    return BackBarScaffold(
      trailing: SkipButton(
        onPressed: () => unawaited(
          context.pushNamed<void>(Routes.profile, arguments: account),
        ),
      ),
      children: <Widget>[
        SizedBox(height: AppSpacing.sm.h),
        _SignedInBanner(account: account),
        SizedBox(height: _titleGap.h),
        Semantics(
          header: true,
          child: Text(l10n.verifyMobileTitle, style: text.headlineMedium),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          l10n.verifyMobileBody,
          style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
        SizedBox(height: _sectionGap.h),
        MobileNumberForm(
          step: NumberStep.afterSocial,
          submitLabel: l10n.verifyMobileSend,
          account: account,
        ),
        SizedBox(height: _noteGap.h),
        Text(
          l10n.verifyMobileLater,
          textAlign: TextAlign.center,
          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        SizedBox(height: _termsMinGap.h),
        const Spacer(),
        const TermsNote(),
      ],
    );
  }
}

/// Which provider signed in, with the account's email.
class _SignedInBanner extends StatelessWidget {
  const _SignedInBanner({required this.account});

  final SocialAccount account;

  static const double _badge = 28;
  static const double _paddingX = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.textTheme;
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _paddingX.w,
        vertical: AppSpacing.md.h,
      ),
      decoration: BoxDecoration(
        color: colors.statusSuccessContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
      ),
      child: Row(
        spacing: AppSpacing.md.w,
        children: <Widget>[
          Container(
            width: _badge.r,
            height: _badge.r,
            decoration: BoxDecoration(
              color: colors.statusSuccess,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              Assets.iconsCheckLarge,
              colorFilter: ColorFilter.mode(
                colors.statusOnSuccess,
                BlendMode.srcIn,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xxs.h,
              children: <Widget>[
                Text(
                  l10n.verifyMobileSignedIn(
                    l10n.providerName(account.provider),
                  ),
                  style: text.titleSmall?.copyWith(
                    color: colors.statusOnSuccessContainer,
                  ),
                ),
                Text(
                  account.email,
                  style: text.bodySmall?.copyWith(
                    color: colors.statusOnSuccessContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
