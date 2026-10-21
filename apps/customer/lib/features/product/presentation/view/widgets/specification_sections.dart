import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/product/domain/entities/product_specifications.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The product the specification is for: photo, name, variant and rating.
class SpecificationSummary extends StatelessWidget {
  const SpecificationSummary({required this.specs, super.key});

  final ProductSpecifications specs;

  static const double _photo = 56;
  static const double _star = 14;
  static const double _vertical = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final score = FormatCache.number('0.0', locale).format(specs.rating);
    final variant = text.bodySmall?.copyWith(color: colors.onSurfaceVariant);
    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg.w,
          vertical: _vertical.h,
        ),
        child: Row(
          spacing: AppSpacing.md.w,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm.r),
              child: ColoredBox(
                color: context.appColors.commerceProductBg,
                child: Image.asset(
                  specs.image,
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
                  Text(specs.name, style: text.titleSmall),
                  Text(specs.variant, style: variant),
                  Semantics(
                    label: context.coreL10n.productRating(
                      score,
                      specs.ratingCount,
                    ),
                    excludeSemantics: true,
                    child: Row(
                      spacing: AppSpacing.xs.w,
                      children: <Widget>[
                        ProductIcon(
                          Assets.iconsStarFilled,
                          size: _star,
                          color: context.appColors.commerceRating,
                        ),
                        Text(score, style: text.labelMedium),
                        Text(
                          context.coreL10n.productRatingCount(
                            FormatCache.decimal(
                              locale,
                            ).format(specs.ratingCount),
                          ),
                          style: variant,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the product is about, and its selling points with ticks.
class SpecificationOverview extends StatelessWidget {
  const SpecificationOverview({required this.specs, super.key});

  final ProductSpecifications specs;

  static const double _tick = 20;
  static const double _check = 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return ProductSection(
      spacing: AppSpacing.md,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(context.l10n.productOverview, style: text.titleMedium),
        ),
        Text(specs.overview, style: text.bodyMedium),
        for (final feature in specs.features)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.w,
            children: <Widget>[
              Container(
                width: _tick.r,
                height: _tick.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: ProductIcon(
                  Assets.iconsCheck,
                  size: _check,
                  color: colors.primary,
                ),
              ),
              Expanded(child: Text(feature, style: text.bodyMedium)),
            ],
          ),
      ],
    );
  }
}

/// A titled block of specification lines.
class SpecificationGroup extends StatelessWidget {
  const SpecificationGroup({required this.group, super.key});

  final SpecGroup group;

  static const double _key = 128;
  static const double _headGap = 6;
  static const double _bottom = 8;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg.w,
          AppSpacing.lg.h,
          AppSpacing.lg.w,
          _bottom.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.xs.h,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: _headGap.h),
              child: Row(
                spacing: 10.w,
                children: <Widget>[
                  ProductIcon(
                    _iconOf(group.kind),
                    size: AppSizes.iconSm,
                    color: colors.primary,
                  ),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(group.title, style: text.titleMedium),
                    ),
                  ),
                ],
              ),
            ),
            for (final (i, row) in group.rows.indexed)
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  border: i == group.rows.length - 1
                      ? null
                      : Border(
                          bottom: BorderSide(color: colors.outlineVariant),
                        ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.md.w,
                  children: <Widget>[
                    SizedBox(
                      width: _key.w,
                      child: Text(
                        row.label,
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Text(row.value, style: text.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _iconOf(SpecGroupKind kind) => switch (kind) {
    SpecGroupKind.general => Assets.iconsPhone,
    SpecGroupKind.display => Assets.iconsEye,
    SpecGroupKind.performance => Assets.iconsBolt,
    SpecGroupKind.camera => Assets.iconsCamera,
    SpecGroupKind.battery => Assets.iconsBolt,
    SpecGroupKind.connectivity => Assets.iconsGlobe,
    SpecGroupKind.design => Assets.iconsShield,
    SpecGroupKind.inTheBox => Assets.iconsBag,
  };
}
