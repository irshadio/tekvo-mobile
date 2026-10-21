import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/money_format.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/money.dart';
import 'package:customer/features/product/domain/entities/product_bundle.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// This product with what is often bought with it: tick the ones to add,
/// see the total and add them all at once.
class ProductBundleSection extends StatelessWidget {
  const ProductBundleSection({
    required this.bundle,
    required this.skipped,
    required this.onToggle,
    required this.onAdd,
    super.key,
  });

  final Bundle bundle;

  /// The ids of the items left out; this product is always in.
  final Set<String> skipped;
  final ValueChanged<String> onToggle;

  /// Adds the ticked items, given by id.
  final ValueChanged<List<String>> onAdd;

  static const double _photo = 84;
  static const double _radius = 10;
  static const double _checkInset = 6;
  static const Duration _fade = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final items = bundle.items;
    final chosen = <BundleItem>[
      for (final (i, item) in items.indexed)
        if (i == 0 || !skipped.contains(item.id)) item,
    ];
    final all = chosen.length == items.length;
    final total = all
        ? bundle.total
        : Money(
            chosen.fold(0, (sum, item) => sum + item.price.minor),
            currency: bundle.total.currency,
          );
    return ProductSection(
      spacing: 14,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(l10n.productBundleTitle, style: text.titleLarge),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: AppSpacing.sm.w,
            children: <Widget>[
              for (final (i, item) in items.indexed) ...<Widget>[
                if (i > 0)
                  ProductIcon(
                    Assets.iconsPlus,
                    size: AppSizes.iconXs,
                    color: colors.onSurfaceVariant,
                  ),
                _photoTile(context, item, first: i == 0),
              ],
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.xs.h,
          children: <Widget>[
            for (final (i, item) in items.indexed)
              AnimatedOpacity(
                duration: context.motion(_fade),
                opacity: i == 0 || !skipped.contains(item.id)
                    ? 1
                    : AppOpacity.disabledContent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.sm.w,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        i == 0
                            ? '${l10n.productBundleThisItem}${item.name}'
                            : item.name,
                        style: text.bodySmall,
                      ),
                    ),
                    Text(context.money(item.price), style: text.labelMedium),
                  ],
                ),
              ),
          ],
        ),
        Row(
          spacing: AppSpacing.md.w,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xxs.h,
                children: <Widget>[
                  Text(
                    l10n.productBundleTotal(chosen.length),
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.s6.w,
                    children: <Widget>[
                      Text(context.money(total), style: text.titleMedium),
                      if (all)
                        Text(
                          l10n.productSaving(context.money(bundle.saving)),
                          style: text.labelMedium?.copyWith(
                            color: context.appColors.commerceSale,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () =>
                  onAdd(<String>[for (final item in chosen) item.id]),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                minimumSize: Size(0, AppSizes.controlMd.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radius.r),
                ),
              ),
              child: Text(
                all
                    ? l10n.productBundleAddAll(chosen.length)
                    : l10n.productBundleAdd(chosen.length),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _photoTile(
    BuildContext context,
    BundleItem item, {
    required bool first,
  }) {
    final checked = first || !skipped.contains(item.id);
    final radius = BorderRadius.circular(_radius.r);
    return Semantics(
      checked: checked,
      enabled: !first,
      label: context.l10n.productBundleItem(item.name),
      excludeSemantics: true,
      child: Material(
        color: context.appColors.commerceProductBg,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: first ? null : () => onToggle(item.id),
          child: SizedBox.square(
            dimension: _photo.r,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.asset(item.image, fit: BoxFit.cover),
                PositionedDirectional(
                  top: _checkInset.r,
                  end: _checkInset.r,
                  child: ProductCheckbox(checked: checked),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
