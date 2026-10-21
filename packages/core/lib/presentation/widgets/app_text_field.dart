import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/western_digits_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The design's filled text field with a leading icon: tinted at rest, white
/// with a primary outline while focused.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.focusNode,
    required this.icon,
    required this.hint,
    this.iconSize = AppSizes.iconSm,
    this.iconColor,
    this.height = defaultHeight,
    this.endPadding = AppSpacing.lg,
    this.whiteWhenFocused = true,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters = const <TextInputFormatter>[],
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// An `Assets` icon, drawn in [iconColor] or the variant text colour.
  final String icon;
  final String hint;
  final double iconSize;
  final Color? iconColor;
  final double height;
  final double endPadding;

  /// Whether focus turns the fill white; a search keeps its tint.
  final bool whiteWhenFocused;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  static const double defaultHeight = 54;

  /// The prototype's smart animate into the focused field.
  static const Duration duration = Duration(milliseconds: 300);

  static const double _iconGap = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        final focused = focusNode.hasFocus;
        return AnimatedContainer(
          duration: context.motion(duration),
          curve: Curves.easeOut,
          height: height.h,
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.lg.w,
            end: endPadding.w,
          ),
          decoration: BoxDecoration(
            color: focused && whiteWhenFocused
                ? colors.surfaceContainerLowest
                : colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.sm.r),
            border: Border.all(
              color: focused
                  ? colors.primary
                  : colors.primary.withValues(alpha: 0),
              width: focused ? AppBorders.focus : 0,
            ),
          ),
          child: child,
        );
      },
      child: Row(
        spacing: _iconGap.w,
        children: <Widget>[
          SvgPicture.asset(
            icon,
            width: iconSize.r,
            height: iconSize.r,
            colorFilter: ColorFilter.mode(
              iconColor ?? colors.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              textCapitalization: textCapitalization,
              autofillHints: autofillHints,
              autocorrect: false,
              inputFormatters: <TextInputFormatter>[
                const WesternDigitsFormatter(),
                ...inputFormatters,
              ],
              style: text.bodyLarge?.copyWith(color: colors.onSurface),
              cursorColor: colors.primary,
              onTapOutside: (_) => focusNode.unfocus(),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hint,
                hintStyle: text.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
