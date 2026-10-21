import 'package:core/assets/assets.gen.dart';
import 'package:core/catalog/product.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/product/product_row.dart';
import 'package:core/presentation/widgets/section_header.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A few questions with their best answers, and a way to ask one.
class ProductQuestionsSection extends StatelessWidget {
  const ProductQuestionsSection({
    required this.questions,
    required this.onAll,
    required this.onAsk,
    super.key,
  });

  final Questions questions;
  final VoidCallback onAll;
  final VoidCallback onAsk;

  static const double _badge = 22;
  static const double _shield = 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    return ProductSection(
      spacing: 14,
      children: <Widget>[
        SectionHeader(
          title: l10n.productQuestionsTitle,
          seeAll: l10n.productSeeAllCount(questions.total),
          onSeeAll: onAll,
        ),
        for (final item in questions.top)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.s6.h,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.sm.w,
                children: <Widget>[
                  _badgeOf(
                    context,
                    l10n.productQuestionBadge,
                    colors.primaryContainer,
                    colors.onPrimaryContainer,
                  ),
                  Expanded(child: Text(item.question, style: text.titleSmall)),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.sm.w,
                children: <Widget>[
                  _badgeOf(
                    context,
                    l10n.productAnswerBadge,
                    colors.surfaceContainerHigh,
                    colors.onSurface,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.xs.h,
                      children: <Widget>[
                        Text(item.answer, style: text.bodyMedium),
                        _meta(context, item),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ProductOutlineButton(label: l10n.productAskQuestion, onPressed: onAsk),
      ],
    );
  }

  Widget _badgeOf(
    BuildContext context,
    String letter,
    Color background,
    Color ink,
  ) => ExcludeSemantics(
    child: Container(
      width: _badge.r,
      height: _badge.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.s6.r),
      ),
      child: Text(
        letter,
        style: context.textTheme.labelMedium?.copyWith(color: ink),
      ),
    ),
  );

  Widget _meta(BuildContext context, ProductQuestion item) {
    final colors = context.colors;
    final l10n = context.l10n;
    final small = context.textTheme.bodySmall;
    final seller = item.by == AnswerBy.seller;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm.w,
      children: <Widget>[
        if (seller)
          ProductIcon(Assets.iconsShield, size: _shield, color: colors.primary),
        Text(
          seller
              ? l10n.productAnswerSeller(item.answeredBy)
              : l10n.productAnswerBuyer(item.answeredBy),
          style: small?.copyWith(
            color: seller ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
        Text(
          '·  ${l10n.productHelpful(item.helpful)}',
          style: small?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Products other shoppers looked at, in a row that scrolls sideways.
class ProductAlsoViewedSection extends StatelessWidget {
  const ProductAlsoViewedSection({
    required this.products,
    required this.onProduct,
    required this.onSeeAll,
    super.key,
  });

  final List<Product> products;
  final ValueChanged<String> onProduct;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.surfaceContainerLowest,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md.h,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
            child: SectionHeader(
              title: context.l10n.productAlsoViewed,
              onSeeAll: onSeeAll,
            ),
          ),
          ProductRow(products: products, onProduct: onProduct),
        ],
      ),
    ),
  );
}
