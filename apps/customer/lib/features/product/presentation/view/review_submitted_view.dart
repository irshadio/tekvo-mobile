import 'dart:async';

import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/product/domain/entities/review_form.dart';
import 'package:customer/features/product/presentation/view/widgets/product_page_bar.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Thanks for a sent review, with the next purchase to rate and the ways
/// back. [onContinueShopping] shows the shop, which the shell owns.
class ReviewSubmittedView extends StatelessWidget {
  const ReviewSubmittedView({
    required this.receipt,
    required this.onContinueShopping,
    super.key,
  });

  final ReviewReceipt receipt;
  final void Function(BuildContext context) onContinueShopping;

  static const double _badge = 128;
  static const double _star = 80;
  static const double _starIcon = 40;
  static const double _bottom = 34;
  static const Duration _pop = Duration(milliseconds: 600);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final next = receipt.next;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(colors),
      child: Scaffold(
        backgroundColor: colors.surfaceContainer,
        body: Padding(
          padding: EdgeInsets.only(
            top: context.viewPadding.top,
            bottom: _bottom.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w),
                  child: ProductPageBar.action(
                    icon: Assets.iconsClose,
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          context.screenSize.height -
                          context.viewPadding.top -
                          AppSizes.touchTargetMin.h -
                          _bottom.h,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.lg.h,
                      children: <Widget>[
                        Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.6, end: 1),
                            duration: context.motion(_pop),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) =>
                                Transform.scale(scale: scale, child: child),
                            child: Container(
                              width: _badge.r,
                              height: _badge.r,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                width: _star.r,
                                height: _star.r,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: ProductIcon(
                                  Assets.iconsStarFilled,
                                  size: _starIcon,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.productReviewThanks,
                            textAlign: TextAlign.center,
                            style: text.headlineSmall,
                          ),
                        ),
                        Text(
                          l10n.productReviewThanksBody(receipt.rewardPoints),
                          textAlign: TextAlign.center,
                          style: text.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        if (next != null) _NextPrompt(prompt: next),
                        Padding(
                          padding: EdgeInsets.only(top: AppSpacing.sm.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 10.h,
                            children: <Widget>[
                              FilledButton(
                                onPressed: () => unawaited(
                                  context.pushNamed<void>(Routes.orders),
                                ),
                                style: FilledButton.styleFrom(
                                  minimumSize: Size.fromHeight(
                                    AppSizes.controlLg.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md.r,
                                    ),
                                  ),
                                ),
                                child: Text(l10n.productBackToOrders),
                              ),
                              OutlinedButton(
                                onPressed: () => onContinueShopping(context),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size.fromHeight(
                                    AppSizes.controlLg.h,
                                  ),
                                  foregroundColor: colors.onSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md.r,
                                    ),
                                  ),
                                  side: BorderSide(
                                    color: colors.outlineVariant,
                                    width: _outline,
                                  ),
                                ),
                                child: Text(l10n.productContinueShopping),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const double _outline = 1.5;
}

/// Another purchase to review, opening its form in place of this screen.
class _NextPrompt extends StatelessWidget {
  const _NextPrompt({required this.prompt});

  final ReviewPrompt prompt;

  static const double _photo = 44;
  static const double _padding = 14;
  static const double _star = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final radius = BorderRadius.circular(AppRadius.md.r);
    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => unawaited(
          context.pushReplacementNamed<void, void>(
            Routes.writeReview,
            arguments: prompt.productId,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _padding.w,
            vertical: _padding.h,
          ),
          child: Row(
            spacing: AppSpacing.md.w,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm.r),
                child: ColoredBox(
                  color: context.appColors.commerceProductBg,
                  child: Image.asset(
                    prompt.image,
                    width: _photo.r,
                    height: _photo.r,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xxs.h,
                  children: <Widget>[
                    Text(
                      context.l10n.productRateAnother,
                      style: text.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(prompt.name, style: text.titleSmall),
                  ],
                ),
              ),
              ExcludeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.xxs.w,
                  children: <Widget>[
                    for (var i = 0; i < 5; i++)
                      ProductIcon(
                        Assets.iconsStar,
                        size: _star,
                        color: colors.outline,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
