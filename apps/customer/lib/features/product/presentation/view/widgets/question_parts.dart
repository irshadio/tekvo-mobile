import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/product/domain/entities/product_questions.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A question with its badge.
class QuestionLine extends StatelessWidget {
  const QuestionLine({required this.question, super.key});

  final String question;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm.w,
      children: <Widget>[
        QaBadge(
          letter: context.l10n.productQuestionBadge,
          background: colors.primaryContainer,
          ink: colors.onPrimaryContainer,
        ),
        Expanded(child: Text(question, style: context.textTheme.titleSmall)),
      ],
    );
  }
}

/// An answer with its badge, who wrote it and how many found it helpful.
class AnswerLine extends StatelessWidget {
  const AnswerLine({
    required this.answer,
    this.tintBuyer = true,
    super.key,
  });

  final Answer answer;

  /// Shows a buyer's name in the brand colour, like the seller's.
  final bool tintBuyer;

  static const double _shield = 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final small = context.textTheme.bodySmall;
    final seller = answer.by == AnswerBy.seller;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm.w,
      children: <Widget>[
        QaBadge(
          letter: l10n.productAnswerBadge,
          background: colors.surfaceContainerHigh,
          ink: colors.onSurface,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs.h,
            children: <Widget>[
              Text(answer.text, style: context.textTheme.bodyMedium),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm.w,
                children: <Widget>[
                  if (seller)
                    ProductIcon(
                      Assets.iconsShield,
                      size: _shield,
                      color: colors.primary,
                    ),
                  Text(
                    seller
                        ? l10n.productAnswerSeller(answer.author)
                        : l10n.productAnswerBuyer(answer.author),
                    style: small?.copyWith(
                      color: seller || tintBuyer
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '·  ${l10n.productHelpful(answer.helpful)}',
                    style: small?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The Q or A square before a question or an answer.
class QaBadge extends StatelessWidget {
  const QaBadge({
    required this.letter,
    required this.background,
    required this.ink,
    super.key,
  });

  final String letter;
  final Color background;
  final Color ink;

  static const double _size = 22;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: _size.r,
      height: _size.r,
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
}
