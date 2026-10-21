import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/money_format.dart';
import 'package:core/theme/app_effects.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/money.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The pinned foot of the product page: the price, and Add to cart, which
/// turns into a quantity stepper once the product is in the cart.
class ProductBottomBar extends StatelessWidget {
  const ProductBottomBar({
    required this.price,
    required this.freeDelivery,
    required this.quantity,
    required this.onAdd,
    required this.onIncrease,
    required this.onDecrease,
    this.soldOut = false,
    this.alerting = false,
    this.onNotify,
    super.key,
  });

  final Money price;
  final bool freeDelivery;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  /// The chosen option has run out: Add to cart becomes Notify me.
  final bool soldOut;

  /// The user already asked to hear when it is back.
  final bool alerting;
  final VoidCallback? onNotify;

  static const double _action = 150;
  static const double _top = 13;
  static const double _bottom = 30;
  static const Duration _swap = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
        boxShadow: AppEffects.bottomBar,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg.w,
          _top.h,
          AppSpacing.lg.w,
          context.viewPadding.bottom > 0 ? _bottom.h : _top.h,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    context.money(price),
                    style: text.titleMedium?.copyWith(
                      color: context.appColors.commercePrice,
                    ),
                  ),
                  if (soldOut)
                    Text(
                      l10n.productOutOfStock,
                      style: text.bodySmall?.copyWith(color: colors.error),
                    )
                  else if (freeDelivery)
                    Text(
                      l10n.productFreeDeliveryLine,
                      style: text.bodySmall?.copyWith(color: colors.primary),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: _action.w,
              height: AppSizes.controlLg.h,
              child: AnimatedSwitcher(
                duration: context.motion(_swap),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.92,
                      end: 1,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: soldOut
                    ? _NotifyButton(
                        key: ValueKey<bool>(alerting),
                        alerting: alerting,
                        onNotify: onNotify,
                      )
                    : quantity == 0
                    ? FilledButton(
                        key: const ValueKey<String>('add'),
                        onPressed: onAdd,
                        style: FilledButton.styleFrom(
                          minimumSize: Size.fromHeight(AppSizes.controlLg.h),
                          textStyle: text.labelLarge,
                        ),
                        // The button keeps the design's width at any text
                        // size; a very large label shrinks to fit.
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(l10n.productAddToCart),
                        ),
                      )
                    : _Stepper(
                        key: const ValueKey<String>('stepper'),
                        quantity: quantity,
                        onIncrease: onIncrease,
                        onDecrease: onDecrease,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks to hear when a sold-out option is back; quiet once asked.
class _NotifyButton extends StatelessWidget {
  const _NotifyButton({
    required this.alerting,
    required this.onNotify,
    super.key,
  });

  final bool alerting;
  final VoidCallback? onNotify;

  static const double _bell = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return FilledButton(
      onPressed: alerting ? null : onNotify,
      style: FilledButton.styleFrom(
        minimumSize: Size.fromHeight(AppSizes.controlLg.h),
        textStyle: context.textTheme.labelLarge,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.sm.w,
          children: <Widget>[
            if (!alerting)
              SvgPicture.asset(
                Assets.iconsBell,
                width: _bell.r,
                height: _bell.r,
                colorFilter: ColorFilter.mode(
                  colors.onPrimary,
                  BlendMode.srcIn,
                ),
              ),
            Text(alerting ? l10n.productNotifying : l10n.productRestockNotify),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    super.key,
  });

  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  static const double _button = 32;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    Widget step(String icon, String tooltip, VoidCallback onPressed) =>
        IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          style: IconButton.styleFrom(
            backgroundColor: colors.surfaceContainerLowest,
            fixedSize: Size.square(_button.r),
            minimumSize: Size.square(_button.r),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs.r),
            ),
          ),
          icon: SvgPicture.asset(
            icon,
            width: AppSizes.iconXs.r,
            height: AppSizes.iconXs.r,
            colorFilter: ColorFilter.mode(colors.onSurface, BlendMode.srcIn),
          ),
        );
    return Container(
      padding: EdgeInsets.all(AppSpacing.xs.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.s6.r),
      ),
      child: Row(
        children: <Widget>[
          step(Assets.iconsMinus, l10n.productDecrease, onDecrease),
          Expanded(
            child: AnimatedSwitcher(
              duration: context.motion(const Duration(milliseconds: 150)),
              child: Text(
                '$quantity',
                key: ValueKey<int>(quantity),
                textAlign: TextAlign.center,
                style: context.textTheme.titleSmall,
                semanticsLabel: l10n.productQuantity(quantity),
              ),
            ),
          ),
          step(Assets.iconsPlus, l10n.productIncrease, onIncrease),
        ],
      ),
    );
  }
}
