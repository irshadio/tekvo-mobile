import 'package:core/assets/assets.gen.dart';
import 'package:core/catalog/product.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/money_format.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_emphasis.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/search/domain/entities/search.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A way to finish the query: what was typed in plain, the rest in bold.
class SuggestionRow extends StatelessWidget {
  const SuggestionRow({
    required this.suggestion,
    required this.typed,
    required this.onTap,
    super.key,
  });

  final Suggestion suggestion;

  /// What the user typed, to set apart from the completion.
  final String typed;
  final VoidCallback onTap;

  static const double _icon = 18;
  static const double _vertical = 11;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final query = suggestion.query;
    final starts = query.toLowerCase().startsWith(typed.trim().toLowerCase());
    final split = starts ? typed.trim().length : 0;
    final category = suggestion.categoryName;
    final base = text.bodyLarge;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: _vertical.h),
        child: Row(
          spacing: AppSpacing.md.w,
          children: <Widget>[
            SvgPicture.asset(
              category == null ? Assets.iconsSearch : Assets.iconsCategories,
              width: _icon.r,
              height: _icon.r,
              colorFilter: ColorFilter.mode(
                colors.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(text: query.substring(0, split)),
                    TextSpan(
                      text: query.substring(split),
                      style: base?.emphasized,
                    ),
                    if (category != null)
                      TextSpan(
                        text: context.l10n.searchIn(category),
                        style: base?.copyWith(color: colors.primary),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: base,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The store a query matches, with a way in.
class StoreHitCard extends StatelessWidget {
  const StoreHitCard({required this.store, required this.onVisit, super.key});

  final StoreHit store;
  final VoidCallback onVisit;

  static const double _logo = 44;
  static const double _logoRadius = 10;
  static const double _badge = 16;
  static const double _badgeIcon = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final radius = BorderRadius.circular(AppRadius.md.r);
    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: radius,
      child: InkWell(
        onTap: onVisit,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.md.h,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            spacing: AppSpacing.md.w,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(_logoRadius.r),
                child: Image.asset(
                  store.logo,
                  width: _logo.r,
                  height: _logo.r,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xxs.h,
                  children: <Widget>[
                    Row(
                      spacing: AppSpacing.s6.w,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            store.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleSmall,
                          ),
                        ),
                        if (store.verified)
                          Container(
                            width: _badge.r,
                            height: _badge.r,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              Assets.iconsCheck,
                              width: _badgeIcon.r,
                              height: _badgeIcon.r,
                              colorFilter: ColorFilter.mode(
                                colors.onPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      l10n.searchStoreLine(
                        FormatCache.decimal(locale).format(store.productCount),
                        FormatCache.number('0.0', locale).format(store.rating),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.searchVisit,
                style: text.labelLarge?.copyWith(color: colors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A product as a line: photo, name, price and rating.
class ProductLine extends StatelessWidget {
  const ProductLine({required this.product, required this.onTap, super.key});

  final Product product;
  final VoidCallback onTap;

  static const double _photo = 56;
  static const double _star = 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final was = product.was;
    return InkWell(
      onTap: onTap,
      child: Row(
        spacing: AppSpacing.md.w,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm.r),
            child: ColoredBox(
              color: context.appColors.commerceProductBg,
              child: Image.asset(
                product.image,
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
              spacing: 3.h,
              children: <Widget>[
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium,
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.s6.w,
                  children: <Widget>[
                    Text(
                      context.money(product.price),
                      style: text.titleSmall?.copyWith(
                        color: product.onSale
                            ? context.appColors.commerceSale
                            : context.appColors.commercePrice,
                      ),
                    ),
                    if (was != null)
                      Text(
                        context.money(was),
                        style: text.bodySmall?.copyWith(
                          color: context.appColors.commercePriceStrike,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 3.w,
            children: <Widget>[
              SvgPicture.asset(
                Assets.iconsStarFilled,
                width: _star.r,
                height: _star.r,
                colorFilter: ColorFilter.mode(
                  context.appColors.commerceRating,
                  BlendMode.srcIn,
                ),
              ),
              Text(
                FormatCache.number('0.0', locale).format(product.rating),
                style: text.labelMedium?.copyWith(color: colors.onSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
