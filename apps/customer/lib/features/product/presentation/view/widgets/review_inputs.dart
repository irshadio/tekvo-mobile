import 'dart:io';

import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/dashed_border.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/product/presentation/view/widgets/product_section_parts.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A labelled field: one line for the headline, or a box with a counter
/// for the review.
class ReviewField extends StatelessWidget {
  const ReviewField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.maxLength,
    this.note,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  /// Makes this the multi-line review box, counting up to this many.
  final int? maxLength;

  /// A line under the field, such as a tip.
  final String? note;

  static const double _lineHeight = 54;
  static const double _boxRadius = 10;
  static const double _boxHorizontal = 14;
  static const int _boxLines = 3;
  static const double _focus = 1.5;
  static const Duration _focusFade = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final box = maxLength;
    final note = this.note;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm.h,
      children: <Widget>[
        Text(label, style: text.labelLarge),
        ListenableBuilder(
          listenable: Listenable.merge(<Listenable>[focusNode, controller]),
          builder: (context, _) {
            final focused = focusNode.hasFocus;
            final field = TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              maxLength: box,
              maxLines: box == null ? 1 : null,
              minLines: box == null ? 1 : _boxLines,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: box == null
                  ? TextInputAction.next
                  : TextInputAction.newline,
              style: box == null ? text.bodyLarge : text.bodyMedium,
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hint,
                hintStyle: (box == null ? text.bodyLarge : text.bodyMedium)
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              buildCounter: (
                _, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
            );
            return AnimatedContainer(
              duration: context.motion(_focusFade),
              constraints: BoxConstraints(
                minHeight: box == null ? _lineHeight.h : 0,
              ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(
                horizontal: (box == null ? AppSpacing.lg : _boxHorizontal).w,
                vertical: (box == null ? 0 : AppSpacing.md).h,
              ),
              decoration: BoxDecoration(
                color: box == null
                    ? colors.surfaceContainerHigh
                    : colors.surfaceContainer,
                borderRadius: BorderRadius.circular(
                  (box == null ? AppRadius.sm : _boxRadius).r,
                ),
                border: Border.all(
                  color: focused
                      ? colors.primary
                      : (box == null
                            ? colors.surfaceContainerHigh
                            : colors.surfaceContainer),
                  width: _focus,
                ),
              ),
              child: box == null
                  ? field
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.sm.h,
                      children: <Widget>[
                        field,
                        Text(
                          _counter(context, controller.text.length, box),
                          textAlign: TextAlign.end,
                          style: text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
        if (note != null)
          Text(
            note,
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
      ],
    );
  }

  static String _counter(BuildContext context, int count, int max) {
    final decimal = FormatCache.decimal(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return context.l10n.productReviewCounter(
      decimal.format(count),
      decimal.format(max),
    );
  }
}

/// Picked photos with a remove button each, and a tile to add more.
class ReviewPhotos extends StatelessWidget {
  const ReviewPhotos({
    required this.photos,
    required this.max,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  final List<String> photos;
  final int max;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  static const double _tile = 72;
  static const double _remove = 20;
  static const double _removeIcon = 12;
  static const double _camera = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final radius = BorderRadius.circular(AppRadius.sm.r);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10.h,
      children: <Widget>[
        Row(
          spacing: AppSpacing.sm.w,
          children: <Widget>[
            Expanded(
              child: Text(l10n.productAddPhotos, style: text.titleSmall),
            ),
            Text(
              l10n.productPhotosOf(photos.length, max),
              style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
        Wrap(
          spacing: AppSpacing.sm.w,
          runSpacing: AppSpacing.sm.h,
          children: <Widget>[
            for (final photo in photos)
              SizedBox.square(
                dimension: _tile.r,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: radius,
                      child: ColoredBox(
                        color: colors.surfaceContainerHigh,
                        child: Image.file(
                          File(photo),
                          fit: BoxFit.cover,
                          excludeFromSemantics: true,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: AppSpacing.xs.r,
                      end: AppSpacing.xs.r,
                      child: Semantics(
                        button: true,
                        label: l10n.productRemovePhoto,
                        excludeSemantics: true,
                        child: InkResponse(
                          onTap: () => onRemove(photo),
                          child: Container(
                            width: _remove.r,
                            height: _remove.r,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.inverseSurface,
                              shape: BoxShape.circle,
                            ),
                            child: ProductIcon(
                              Assets.iconsClose,
                              size: _removeIcon,
                              color: colors.onInverseSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (photos.length < max)
              Semantics(
                button: true,
                label: l10n.productAddPhotos,
                excludeSemantics: true,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onAdd,
                    borderRadius: radius,
                    child: DashedBorder(
                      color: colors.outline,
                      radius: radius,
                      child: SizedBox.square(
                        dimension: _tile.r,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: AppSpacing.xxs.h,
                          children: <Widget>[
                            ProductIcon(
                              Assets.iconsCamera,
                              size: _camera,
                              color: colors.onSurfaceVariant,
                            ),
                            Text(
                              l10n.productAddPhoto,
                              style: text.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
