import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/home/domain/entities/promo.dart';
import 'package:customer/features/home/presentation/view/widgets/page_dots.dart';
import 'package:customer/features/home/presentation/view/widgets/promo_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The promotions as cards that snap one at a time, the next one peeking
/// in at the edge, with a dot per card below.
class HeroCarousel extends StatefulWidget {
  const HeroCarousel({
    required this.promos,
    required this.flashSaleRemaining,
    required this.onPromo,
    super.key,
  });

  final List<Promo> promos;
  final Duration flashSaleRemaining;
  final ValueChanged<Promo> onPromo;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  static const double _height = 200;
  static const double _card = 345;
  static const double _gap = 12;

  PageController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A page is a card and its gap, as a share of the row after the start
    // margin; the row spans the screen.
    final row = context.screenSize.width - AppSpacing.lg.w;
    final fraction = (_card + _gap).w / row;
    final current = _controller;
    if (current != null && current.viewportFraction == fraction) return;
    final page = current != null && current.hasClients
        ? (current.page ?? 0).round()
        : 0;
    current?.dispose();
    _controller = PageController(viewportFraction: fraction, initialPage: page);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return Column(
      spacing: AppSpacing.md.h,
      children: <Widget>[
        SizedBox(
          height: _height.h,
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: AppSpacing.lg.w),
            child: PageView.builder(
              controller: controller,
              padEnds: false,
              clipBehavior: Clip.none,
              itemCount: widget.promos.length,
              itemBuilder: (context, index) {
                final promo = widget.promos[index];
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: _gap.w),
                  child: PromoBanner(
                    promo: promo,
                    remaining: widget.flashSaleRemaining,
                    onTap: () => widget.onPromo(promo),
                  ),
                );
              },
            ),
          ),
        ),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => PageDots(
            count: widget.promos.length,
            current: controller.hasClients
                ? (controller.page ?? 0).round()
                : controller.initialPage,
          ),
        ),
      ],
    );
  }
}
