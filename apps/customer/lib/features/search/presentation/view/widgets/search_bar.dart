import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/app_icon_button.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Search's pinned bar: back and the field, which clears once there are
/// words in it and otherwise offers search by photo. A read-only bar
/// opens [onTap] instead, such as editing the search from its results.
class ShopSearchBar extends StatelessWidget {
  const ShopSearchBar({
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onPhoto,
    this.onTap,
    this.bottom,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onPhoto;

  /// Makes the field read-only and opens this when tapped.
  final VoidCallback? onTap;

  /// A row under the field, such as sort and filters.
  final Widget? bottom;

  static const double _fieldHeight = 44;
  static const double _radius = 10;
  static const double _icon = 20;
  static const double _trailing = 32;
  static const double _clearDot = 20;
  static const double _clearIcon = 12;
  static const double _focus = 1.5;
  static const double _barBottom = 10;
  static const double _barIcon = 22;
  static const Duration _fade = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottom = this.bottom;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.sm.w,
              context.viewPadding.top + AppSpacing.xs.h,
              AppSpacing.lg.w,
              _barBottom.h,
            ),
            child: Row(
              spacing: AppSpacing.xs.w,
              children: <Widget>[
                AppIconButton(
                  icon: Assets.iconsChevronLeft,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () => Navigator.of(context).maybePop(),
                  variant: AppIconButtonVariant.plain,
                  iconSize: _barIcon,
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: Listenable.merge(<Listenable?>[
                      controller,
                      focusNode,
                    ]),
                    builder: (context, _) => _field(context),
                  ),
                ),
              ],
            ),
          ),
          ?bottom,
        ],
      ),
    );
  }

  Widget _field(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final focused = focusNode?.hasFocus ?? false;
    final empty = controller.text.isEmpty;
    return AnimatedContainer(
      duration: context.motion(_fade),
      height: _fieldHeight.h,
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.md.w,
        end: AppSpacing.s6.w,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(_radius.r),
        border: Border.all(
          color: focused ? colors.primary : colors.surfaceContainer,
          width: _focus,
        ),
      ),
      child: Row(
        spacing: AppSpacing.sm.w,
        children: <Widget>[
          SvgPicture.asset(
            Assets.iconsSearch,
            width: _icon.r,
            height: _icon.r,
            colorFilter: ColorFilter.mode(
              colors.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: onTap != null,
              onTap: onTap,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: text.bodyLarge,
              cursorColor: colors.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: l10n.searchHint,
                hintStyle: text.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (!empty)
            IconButton(
              onPressed: () {
                controller.clear();
                onChanged?.call('');
                onTap?.call();
              },
              tooltip: l10n.searchClear,
              style: IconButton.styleFrom(
                fixedSize: Size.square(_trailing.r),
                minimumSize: Size.square(_trailing.r),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Container(
                width: _clearDot.r,
                height: _clearDot.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  Assets.iconsClose,
                  width: _clearIcon.r,
                  height: _clearIcon.r,
                  colorFilter: ColorFilter.mode(
                    colors.surfaceContainerLowest,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            )
          else if (onPhoto case final photo?)
            AppIconButton(
              icon: Assets.iconsCamera,
              tooltip: l10n.searchByPhoto,
              onPressed: photo,
              variant: AppIconButtonVariant.plain,
              size: _trailing,
            ),
        ],
      ),
    );
  }
}
