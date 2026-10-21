import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/product/domain/entities/product_questions.dart';
import 'package:customer/features/product/presentation/view/widgets/question_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A question with its best answer, the rest unfolding beneath it, and a
/// way to answer it.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.question,
    required this.open,
    required this.onToggle,
    required this.onAnswer,
    super.key,
  });

  final ProductQuestion question;

  /// Whether the other answers show.
  final bool open;
  final VoidCallback onToggle;
  final VoidCallback onAnswer;

  static const double _padding = 14;
  static const Duration _unfold = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final others = question.answers.skip(1).toList();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _padding.w,
        vertical: _padding.h,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          QuestionLine(question: question.question),
          SizedBox(height: AppSpacing.s6.h),
          AnswerLine(answer: question.best),
          AnimatedSize(
            duration: context.motion(_unfold),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: open && others.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: AppSpacing.md.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.md.h,
                      children: <Widget>[
                        for (final answer in others) AnswerLine(answer: answer),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.only(top: 10.h),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.outlineVariant)),
            ),
            child: Row(
              spacing: AppSpacing.sm.w,
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: InkWell(
                      onTap: others.isEmpty ? null : onToggle,
                      borderRadius: BorderRadius.circular(AppRadius.xs.r),
                      child: Text(
                        open && others.isNotEmpty
                            ? l10n.productFewerAnswers
                            : l10n.productSeeAnswers(question.answers.length),
                        style: text.labelLarge?.copyWith(color: colors.primary),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: onAnswer,
                  borderRadius: BorderRadius.circular(AppRadius.xs.r),
                  child: Text(
                    l10n.productAnswerAction,
                    style: text.labelLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The invitation to ask when the list does not have the answer.
class AskCard extends StatelessWidget {
  const AskCard({required this.onAsk, super.key});

  final VoidCallback onAsk;

  static const double _vertical = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg.w,
        vertical: _vertical.h,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md.h,
        children: <Widget>[
          Text(
            l10n.productCantFind,
            textAlign: TextAlign.center,
            style: text.titleMedium,
          ),
          Text(
            l10n.productCantFindBody,
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          FilledButton(
            onPressed: onAsk,
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(AppSizes.controlLg.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md.r),
              ),
            ),
            child: Text(l10n.productAskQuestion),
          ),
        ],
      ),
    );
  }
}
