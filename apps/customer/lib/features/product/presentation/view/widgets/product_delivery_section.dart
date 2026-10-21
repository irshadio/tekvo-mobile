import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/money_format.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_emphasis.dart';
import 'package:customer/features/product/domain/entities/product_delivery.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Where the order goes, how soon it arrives, the store's promises and who
/// sells it.
class ProductDeliverySection extends StatelessWidget {
  const ProductDeliverySection({
    required this.delivery,
    required this.onChangeAddress,
    super.key,
  });

  final Delivery delivery;
  final VoidCallback onChangeAddress;

  static const double _speedTile = 36;
  static const double _promiseIcon = 22;
  static const double _promiseRadius = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final variant = text.bodySmall?.copyWith(color: colors.onSurfaceVariant);
    return ProductSection(
      spacing: 14,
      children: <Widget>[
        Row(
          spacing: AppSpacing.sm.w,
          children: <Widget>[
            ProductIcon(
              Assets.iconsPin,
              size: AppSizes.iconSm,
              color: colors.onSurface,
            ),
            Expanded(
              child: Text(
                l10n.productDeliverTo(delivery.recipient, delivery.place),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelLarge,
              ),
            ),
            InkWell(
              onTap: onChangeAddress,
              borderRadius: BorderRadius.circular(AppRadius.xs.r),
              child: Text(
                l10n.productDeliveryChange,
                style: text.labelLarge?.copyWith(color: colors.primary),
              ),
            ),
          ],
        ),
        Divider(height: 1, thickness: 1, color: colors.outlineVariant),
        for (final option in delivery.options)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.md.w,
            children: <Widget>[
              Container(
                width: _speedTile.r,
                height: _speedTile.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm.r),
                ),
                child: ProductIcon(
                  switch (option.speed) {
                    DeliverySpeed.standard => Assets.iconsTruck,
                    DeliverySpeed.express => Assets.iconsBolt,
                  },
                  size: AppSizes.iconSm,
                  color: colors.onPrimaryContainer,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xxs.h,
                  children: <Widget>[
                    Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          if (option.highlight case final lead?)
                            TextSpan(
                              text: '$lead ',
                              style: text.titleSmall?.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          TextSpan(text: option.title),
                        ],
                      ),
                      style: text.titleSmall,
                    ),
                    Text(option.detail, style: variant),
                  ],
                ),
              ),
            ],
          ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.sm.w,
            children: <Widget>[
              _promise(
                context,
                Assets.iconsReturns,
                l10n.productReturns(delivery.returnDays),
              ),
              _promise(
                context,
                Assets.iconsShield,
                l10n.productWarranty(delivery.warrantyYears),
              ),
              _promise(context, Assets.iconsLock, l10n.productSecurePayment),
            ],
          ),
        ),
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(text: l10n.productSoldBy),
              TextSpan(
                text: delivery.seller,
                style: text.bodySmall?.emphasized.copyWith(
                  color: colors.onSurface,
                ),
              ),
              TextSpan(text: l10n.productFulfilledBy(delivery.fulfiller)),
            ],
          ),
          style: variant,
        ),
      ],
    );
  }

  Widget _promise(BuildContext context, String icon, String label) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs.w,
        vertical: AppSpacing.md.h,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(_promiseRadius.r),
      ),
      child: Column(
        spacing: AppSpacing.s6.h,
        children: <Widget>[
          ProductIcon(
            icon,
            size: _promiseIcon,
            color: context.colors.onSurface,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.labelMedium,
          ),
        ],
      ),
    ),
  );
}

/// Cover to buy with the product, each ticked on or off.
class ProductProtectionSection extends StatelessWidget {
  const ProductProtectionSection({
    required this.plans,
    required this.chosen,
    required this.onToggle,
    super.key,
  });

  final List<ProtectionPlan> plans;
  final Set<String> chosen;
  final ValueChanged<String> onToggle;

  static const double _minHeight = 64;
  static const Duration _swap = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return ProductSection(
      spacing: 10,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            context.l10n.productProtectTitle,
            style: text.titleMedium,
          ),
        ),
        for (final plan in plans)
          Semantics(
            checked: chosen.contains(plan.id),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => onToggle(plan.id),
                borderRadius: BorderRadius.circular(AppRadius.md.r),
                child: AnimatedContainer(
                  duration: context.motion(_swap),
                  constraints: BoxConstraints(minHeight: _minHeight.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md.w,
                    vertical: AppSpacing.md.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md.r),
                    border: Border.all(
                      color: chosen.contains(plan.id)
                          ? colors.primary
                          : colors.outlineVariant,
                    ),
                  ),
                  child: Row(
                    spacing: AppSpacing.md.w,
                    children: <Widget>[
                      ProductCheckbox(checked: chosen.contains(plan.id)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(plan.title, style: text.titleSmall),
                            Text(
                              plan.detail,
                              style: text.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        context.money(plan.price),
                        style: text.titleSmall?.copyWith(
                          color: context.appColors.commercePrice,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
