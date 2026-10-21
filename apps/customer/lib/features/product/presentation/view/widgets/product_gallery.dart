import 'package:core/catalog/product.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/product/product_card_parts.dart';
import 'package:core/presentation/widgets/product/wishlist_heart_button.dart';
import 'package:core/theme/app_promo_colors.dart';
import 'package:core/theme/app_sizes.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The product's photos to swipe through, with its tags, the wishlist
/// heart, a counter, dots and a strip of thumbnails that jump to a photo.
class ProductGallery extends StatefulWidget {
  const ProductGallery({
    required this.images,
    required this.tags,
    required this.current,
    required this.saved,
    required this.onShow,
    required this.onToggleSaved,
    required this.heartTooltip,
    super.key,
  });

  final List<String> images;
  final List<ProductTag> tags;
  final int current;
  final bool saved;
  final ValueChanged<int> onShow;
  final VoidCallback onToggleSaved;
  final String heartTooltip;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  static const double _photoHeight = 380;
  static const double _heart = 44;
  static const double _thumb = 56;
  static const int _thumbSlots = 5;
  static const double _counterOpacity = 0.85;
  static const double _moreOpacity = 0.55;
  static const Duration _jump = Duration(milliseconds: 300);

  late final PageController _pages = PageController(
    initialPage: widget.current,
  );

  @override
  void didUpdateWidget(ProductGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    final page = _pages.hasClients ? _pages.page?.round() : null;
    if (page != null && page != widget.current) {
      _pages.animateToPage(
        widget.current,
        duration: context.motion(_jump),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textTheme;
    final l10n = context.l10n;
    final count = widget.images.length;
    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: _photoHeight.h,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ColoredBox(
                    color: context.appColors.commerceProductBg,
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: count,
                      onPageChanged: widget.onShow,
                      itemBuilder: (context, index) => Image.asset(
                        widget.images[index],
                        fit: BoxFit.cover,
                        semanticLabel: l10n.productPhoto(index + 1, count),
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: AppSpacing.lg.w,
                  top: AppSpacing.lg.h,
                  child: Row(
                    spacing: AppSpacing.s6.w,
                    children: <Widget>[
                      for (final tag in widget.tags) ProductTagChip(tag: tag),
                    ],
                  ),
                ),
                PositionedDirectional(
                  end: AppSpacing.lg.w,
                  top: AppSpacing.lg.h,
                  child: WishlistHeartButton(
                    saved: widget.saved,
                    tooltip: widget.heartTooltip,
                    onPressed: widget.onToggleSaved,
                    size: _heart,
                    iconSize: AppSizes.iconMd,
                  ),
                ),
                PositionedDirectional(
                  end: AppSpacing.lg.w,
                  bottom: AppSpacing.lg.h,
                  child: Opacity(
                    opacity: _counterOpacity,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: AppSpacing.xs.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.inverseSurface,
                        borderRadius: BorderRadius.circular(AppSpacing.s6.r),
                      ),
                      child: Text(
                        l10n.productPhotoCount(widget.current + 1, count),
                        style: text.labelMedium?.copyWith(
                          color: colors.onInverseSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: AppSpacing.lg.h + AppSpacing.xs.h,
                  child: Center(
                    child: _Dots(count: count, current: widget.current),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg.w,
              AppSpacing.md.h,
              AppSpacing.lg.w,
              AppSpacing.md.h,
            ),
            child: Row(
              spacing: AppSpacing.sm.w,
              children: <Widget>[
                for (var i = 0; i < count && i < _thumbSlots; i++)
                  _thumbnail(context, i),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The last slot covers the photos past it with how many there are.
  Widget _thumbnail(BuildContext context, int index) {
    final colors = context.colors;
    final count = widget.images.length;
    final more = index == _thumbSlots - 1 && count > _thumbSlots
        ? count - (_thumbSlots - 1)
        : 0;
    final selected =
        index == widget.current || (more > 0 && widget.current >= index);
    final radius = BorderRadius.circular(AppRadius.sm.r);
    return Semantics(
      selected: selected,
      label: context.l10n.productPhoto(index + 1, count),
      excludeSemantics: true,
      child: Material(
        color: context.appColors.commerceProductBg,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => widget.onShow(index),
          child: Container(
            width: _thumb.r,
            height: _thumb.r,
            foregroundDecoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? colors.primary : colors.outlineVariant,
                width: selected ? AppBorders.focus : AppBorders.thin,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.asset(widget.images[index], fit: BoxFit.cover),
                if (more > 0) ...<Widget>[
                  ColoredBox(
                    color: colors.scrim.withValues(alpha: _moreOpacity),
                  ),
                  Center(
                    child: Text(
                      '+$more',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: AppPromoColors.onNight,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  static const double _dot = 8;
  static const double _active = 24;
  static const Duration _move = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.s6.w,
        children: <Widget>[
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: context.motion(_move),
              width: (i == current ? _active : _dot).w,
              height: _dot.h,
              decoration: BoxDecoration(
                color: i == current ? colors.primary : colors.outlineVariant,
                borderRadius: BorderRadius.circular(_dot.h / 2),
              ),
            ),
        ],
      ),
    );
  }
}
