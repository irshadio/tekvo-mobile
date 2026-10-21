import 'dart:async';

import 'package:core/media/photo_picker.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/view_ready_mixin.dart';
import 'package:core/presentation/view_state_switcher.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/theme/app_effects.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/product/domain/entities/review_form.dart';
import 'package:customer/features/product/presentation/view/widgets/product_page_bar.dart';
import 'package:customer/features/product/presentation/view/widgets/review_inputs.dart';
import 'package:customer/features/product/presentation/view/widgets/write_review_parts.dart';
import 'package:customer/features/product/presentation/view_model/review_draft_view_model.dart';
import 'package:customer/features/product/presentation/view_model/review_form_view_model.dart';
import 'package:customer/features/product/presentation/view_model/submit_review_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The review form for a purchase: stars, what the buyer liked, a headline,
/// the review, photos and whether to show their name.
class WriteReviewView extends ConsumerStatefulWidget {
  const WriteReviewView({required this.id, super.key});

  final String id;

  @override
  ConsumerState<WriteReviewView> createState() => _WriteReviewViewState();
}

class _WriteReviewViewState extends ConsumerState<WriteReviewView>
    with ViewReadyMixin<WriteReviewView> {
  static const double _gap = 20;
  static const double _bottom = 24;
  static const double _barTop = 13;
  static const double _barBottom = 30;

  final TextEditingController _headline = TextEditingController();
  final TextEditingController _body = TextEditingController();
  final FocusNode _headlineFocus = FocusNode();
  final FocusNode _bodyFocus = FocusNode();

  ReviewFormViewModelProvider get _form =>
      reviewFormViewModelProvider(widget.id);
  ReviewDraftViewModelProvider get _draft =>
      reviewDraftViewModelProvider(widget.id);
  SubmitReviewViewModelProvider get _submit =>
      submitReviewViewModelProvider(widget.id);

  @override
  void dispose() {
    _headline.dispose();
    _body.dispose();
    _headlineFocus.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  @override
  void onReady() => _load();

  void _load() => unawaited(ref.read(_form.notifier).load());

  Future<void> _addPhotos(int room) async {
    final picked = await ref.read(photoPickerProvider).pick(limit: room);
    if (picked.isNotEmpty && mounted) {
      ref.read(_draft.notifier).addPhotos(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listenRefreshFailures(_form, context)
      ..listenSubmission(
        _submit,
        context,
        onSuccess: (receipt) => unawaited(
          context.pushReplacementNamed<void, void>(
            Routes.reviewSubmitted,
            arguments: receipt,
          ),
        ),
      );
    final colors = context.colors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(colors),
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLowest,
        body: ViewStateSwitcher<ReviewForm>(
          state: ref.watch(_form),
          onRetry: _load,
          onData: _page,
        ),
      ),
    );
  }

  Widget _page(ReviewForm form) {
    final l10n = context.l10n;
    final draft = ref.watch(_draft);
    final edit = ref.read(_draft.notifier);
    return Column(
      children: <Widget>[
        ProductPageBar(title: l10n.productWriteReview, closes: true),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg.w,
                AppSpacing.lg.h,
                AppSpacing.lg.w,
                _bottom.h,
              ),
              children:
                  <Widget>[
                        ReviewProductCard(form: form),
                        StarRatingInput(stars: draft.stars, onRate: edit.rate),
                        LikeChips(
                          likes: form.likes,
                          liked: draft.liked,
                          onToggle: edit.toggleLike,
                        ),
                        ReviewField(
                          label: l10n.productHeadline,
                          hint: l10n.productHeadlineHint,
                          controller: _headline,
                          focusNode: _headlineFocus,
                          onChanged: edit.headline,
                        ),
                        ReviewField(
                          label: l10n.productYourReview,
                          hint: l10n.productReviewHint,
                          controller: _body,
                          focusNode: _bodyFocus,
                          onChanged: edit.body,
                          maxLength: form.maxLength,
                          note: l10n.productReviewTip,
                        ),
                        ReviewPhotos(
                          photos: draft.photos,
                          max: form.maxPhotos,
                          onAdd: () => unawaited(
                            _addPhotos(form.maxPhotos - draft.photos.length),
                          ),
                          onRemove: edit.removePhoto,
                        ),
                        ShowNameRow(
                          author: form.author,
                          show: draft.showName,
                          onChanged: edit.showName,
                        ),
                        ReviewRewardNote(points: form.rewardPoints),
                      ]
                      .expand(
                        (child) => <Widget>[child, SizedBox(height: _gap.h)],
                      )
                      .toList()
                    ..removeLast(),
            ),
          ),
        ),
        _submitBar(draft),
      ],
    );
  }

  Widget _submitBar(ReviewDraft draft) {
    final colors = context.colors;
    final sending = ref.watch(_submit).isInProgress;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
        boxShadow: AppEffects.bottomBar,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg.w,
          _barTop.h,
          AppSpacing.lg.w,
          context.viewPadding.bottom > 0 ? _barBottom.h : _barTop.h,
        ),
        child: FilledButton(
          onPressed: draft.ready && !sending
              ? () => unawaited(ref.read(_submit.notifier).submit(draft))
              : null,
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(AppSizes.controlLg.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md.r),
            ),
          ),
          child: Text(context.l10n.productSubmitReview),
        ),
      ),
    );
  }
}
