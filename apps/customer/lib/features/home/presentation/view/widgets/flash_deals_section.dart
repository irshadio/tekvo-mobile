import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/product/product_card.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/home/domain/entities/flash_deal.dart';
import 'package:customer/features/home/presentation/view/widgets/countdown_cells.dart';
import 'package:customer/features/home/presentation/view/widgets/section_header.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The flash sale: its countdown and a row of deals, each with how much has
/// sold.
class FlashDealsSection extends StatelessWidget {
  const FlashDealsSection({
    required this.deals,
    required this.remaining,
    required this.onSeeAll,
    required this.onProduct,
    super.key,
  });

  final List<FlashDeal> deals;
  final Duration remaining;
  final VoidCallback onSeeAll;
  final ValueChanged<String> onProduct;

  static const double _card = 160;
  static const double _badge = 28;
  static const double _bolt = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md.h,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
          child: SectionHeader(
            title: context.l10n.homeFlashDeals,
            onSeeAll: onSeeAll,
            leading: Container(
              width: _badge.r,
              height: _badge.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.commerceDeal,
                borderRadius: BorderRadius.circular(AppSpacing.s6.r),
              ),
              child: SvgPicture.asset(
                Assets.iconsBolt,
                width: _bolt.r,
                height: _bolt.r,
                colorFilter: ColorFilter.mode(
                  colors.commerceOnDeal,
                  BlendMode.srcIn,
                ),
              ),
            ),
            trailing: CountdownCells(
              remaining: remaining,
              cellColor: colors.commerceSale,
              textColor: colors.commerceOnSale,
              separatorColor: colors.commerceSale,
            ),
          ),
        ),
        SizedBox(
          height:
              ProductCard.heightOf(context) +
              _soldGaps.h +
              context.textBox(16, size: 11),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
            itemCount: deals.length,
            separatorBuilder: (_, _) => SizedBox(width: AppSpacing.md.w),
            itemBuilder: (context, index) {
              final deal = deals[index];
              return SizedBox(
                width: _card.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.s6.h,
                  children: <Widget>[
                    ProductCard(
                      product: deal.product,
                      width: _card,
                      onOpen: () => onProduct(deal.product.id),
                    ),
                    _SoldBar(deal: deal),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// The gaps and bar under a card, above the sold label.
  static const double _soldGaps = 16;
}

class _SoldBar extends StatelessWidget {
  const _SoldBar({required this.deal});

  final FlashDeal deal;

  static const double _height = 4;
  static const int _whole = 100;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final sale = context.appColors.commerceSale;
    final l10n = context.l10n;
    final fill = deal.almostGone ? sale : scheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s6.h,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(_height.h / 2),
          child: LinearProgressIndicator(
            value: deal.soldPercent / _whole,
            minHeight: _height.h,
            color: fill,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
        ),
        Text(
          deal.almostGone
              ? l10n.homeAlmostGone(deal.soldPercent)
              : l10n.homeSold(deal.soldPercent),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelSmall?.copyWith(
            color: deal.almostGone ? sale : scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
