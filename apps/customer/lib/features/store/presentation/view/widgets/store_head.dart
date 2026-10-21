import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/app_icon_button.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/utils/format_cache.dart';
import 'package:customer/features/store/domain/entities/store.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The store's cover and logo, chat and follow, name, numbers and tabs.
class StoreHead extends StatelessWidget {
  const StoreHead({
    required this.store,
    required this.following,
    required this.tab,
    required this.onChat,
    required this.onFollow,
    required this.onTab,
    super.key,
  });

  final Store store;
  final bool following;

  /// The chosen tab: home, products, categories or reviews.
  final int tab;
  final VoidCallback onChat;
  final VoidCallback onFollow;
  final ValueChanged<int> onTab;

  static const double _cover = 148;
  static const double _logo = 72;
  static const double _logoTop = 110;
  static const double _logoRadius = 16;
  static const double _logoRing = 3;
  static const double _badge = 18;
  static const double _badgeIcon = 12;
  static const double _followRadius = 10;
  static const double _outline = 1.5;
  static const double _chatIcon = 22;
  static const double _star = 14;
  static const Duration _swap = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.md.h,
            children: <Widget>[
              SizedBox(
                height: _cover.h,
                child: Image.asset(
                  store.cover,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: AppSpacing.sm.w,
                  children: <Widget>[
                    AppIconButton(
                      icon: Assets.iconsChat,
                      tooltip: l10n.storeChat,
                      onPressed: onChat,
                      iconSize: _chatIcon,
                    ),
                    AnimatedSwitcher(
                      duration: context.motion(_swap),
                      child: following
                          ? OutlinedButton(
                              key: const ValueKey<bool>(true),
                              onPressed: onFollow,
                              style: _buttonStyle(context, outlined: true),
                              child: Text(l10n.storeFollowing),
                            )
                          : FilledButton(
                              key: const ValueKey<bool>(false),
                              onPressed: onFollow,
                              style: _buttonStyle(context, outlined: false),
                              child: Text(l10n.storeFollow),
                            ),
                    ),
                  ],
                ),
              ),
              _identity(context),
              _stats(context),
              _tabs(context),
            ],
          ),
          PositionedDirectional(
            start: AppSpacing.lg.w,
            top: _logoTop.h,
            child: Container(
              width: _logo.r,
              height: _logo.r,
              padding: EdgeInsets.all(_logoRing.r),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(_logoRadius.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  (_logoRadius - _logoRing).r,
                ),
                child: Image.asset(
                  store.logo,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(BuildContext context, {required bool outlined}) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_followRadius.r),
    );
    final size = Size(0, AppSizes.controlMd.h);
    final padding = EdgeInsets.symmetric(horizontal: 18.w);
    return outlined
        ? OutlinedButton.styleFrom(
            minimumSize: size,
            padding: padding,
            shape: shape,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: context.colors.onSurface,
            side: BorderSide(
              color: context.colors.outlineVariant,
              width: _outline,
            ),
          )
        : FilledButton.styleFrom(
            minimumSize: size,
            padding: padding,
            shape: shape,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
  }

  Widget _identity(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs.h,
        children: <Widget>[
          Row(
            spacing: AppSpacing.s6.w,
            children: <Widget>[
              Flexible(
                child: Semantics(
                  header: true,
                  child: Text(store.name, style: text.titleLarge),
                ),
              ),
              if (store.verified)
                Semantics(
                  label: context.l10n.storeVerified,
                  child: Container(
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
                ),
            ],
          ),
          Text(
            store.about,
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _stats(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    const thousand = 1000;
    final followers = store.followers < thousand
        ? FormatCache.decimal(locale).format(store.followers)
        : context.coreL10n.productThousands(
            FormatCache.decimal(locale).format(store.followers ~/ thousand),
          );
    final cells = <(String, String, bool)>[
      (
        FormatCache.number('0.0', locale).format(store.rating),
        l10n.storeRating,
        true,
      ),
      (l10n.storePercent(store.positive), l10n.storePositive, false),
      (followers, l10n.storeFollowers, false),
      (l10n.storeHours(store.shipsWithinHours), l10n.storeShipsWithin, false),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final (i, (value, label, star)) in cells.indexed)
              Expanded(
                child: _stat(context, value, label, star, first: i == 0),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stat(
    BuildContext context,
    String value,
    String label,
    bool star, {
    required bool first,
  }) {
    final colors = context.colors;
    final text = context.textTheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s6.h),
      decoration: BoxDecoration(
        border: first
            ? null
            : BorderDirectional(
                start: BorderSide(color: colors.outlineVariant),
              ),
      ),
      child: MergeSemantics(
        child: Column(
          spacing: AppSpacing.xxs.h,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 3.w,
              children: <Widget>[
                Text(value, style: text.titleMedium),
                if (star)
                  SvgPicture.asset(
                    Assets.iconsStarFilled,
                    width: _star.r,
                    height: _star.r,
                    colorFilter: ColorFilter.mode(
                      context.appColors.commerceRating,
                      BlendMode.srcIn,
                    ),
                  ),
              ],
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final labels = <String>[
      l10n.storeTabHome,
      l10n.storeTabProducts,
      l10n.storeTabCategories,
      l10n.storeTabReviews,
    ];
    // A container leaves room for its border, as the design does.
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: <Widget>[
          for (final (i, label) in labels.indexed)
            Expanded(
              child: Semantics(
                selected: i == tab,
                button: true,
                child: InkWell(
                  onTap: () => onTab(i),
                  child: AnimatedContainer(
                    duration: context.motion(_swap),
                    padding: EdgeInsets.only(
                      top: AppSpacing.md.h,
                      bottom: 10.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: i == tab
                              ? colors.primary
                              : colors.surfaceContainerLowest.withValues(
                                  alpha: 0,
                                ),
                          width: AppBorders.thick,
                        ),
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: i == tab
                          ? text.titleSmall?.copyWith(color: colors.primary)
                          : text.labelLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
