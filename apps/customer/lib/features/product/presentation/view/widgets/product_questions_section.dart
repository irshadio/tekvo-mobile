import 'package:core/catalog/product.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/product/product_row.dart';
import 'package:core/presentation/widgets/section_header.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/product/domain/entities/product_questions.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/features/product/presentation/view/widgets/question_parts.dart';
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

  @override
  Widget build(BuildContext context) {
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
              QuestionLine(question: item.question),
              AnswerLine(answer: item.best, tintBuyer: false),
            ],
          ),
        ProductOutlineButton(label: l10n.productAskQuestion, onPressed: onAsk),
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
