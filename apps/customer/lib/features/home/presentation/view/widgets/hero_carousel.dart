import 'dart:async';

import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:customer/features/home/domain/entities/promo.dart';
import 'package:customer/features/home/presentation/view/widgets/page_dots.dart';
import 'package:customer/features/home/presentation/view/widgets/promo_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The promotions as cards that snap one at a time, the next one peeking
/// in at the edge, with a dot per card below. The cards loop either way
/// and move on by themselves every [autoAdvance], pausing while the user
/// drags and when motion is reduced.
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

  /// How long a card stays before the next one slides in.
  static const Duration autoAdvance = Duration(seconds: 4);

  /// How long the slide to the next card takes.
  static const Duration slide = Duration(milliseconds: 600);

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  static const double _height = 200;
  static const double _card = 345;
  static const double _gap = 12;

  /// Rounds of the cards on either side of the first, so the loop has no
  /// end in any real use while scroll offsets stay small enough to be
  /// exact.
  static const int _loops = 100;

  PageController? _controller;
  Timer? _timer;

  int get _count => widget.promos.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A page is a card and its gap, as a share of the row after the start
    // margin less the gap, which leads each card.
    final row = context.screenSize.width - (AppSpacing.lg - _gap).w;
    // A whole-pixel page keeps far scroll offsets exact.
    final fraction = (_card + _gap).w.roundToDouble() / row;
    final current = _controller;
    if (current == null || current.viewportFraction != fraction) {
      final page = current != null && current.hasClients
          ? (current.page ?? 0).round()
          : _count * _loops;
      current?.dispose();
      _controller = PageController(
        viewportFraction: fraction,
        initialPage: page,
      );
    }
    _restart();
  }

  @override
  void didUpdateWidget(HeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.promos.length != _count) _restart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _restart() {
    _timer?.cancel();
    if (_count < 2 || MediaQuery.disableAnimationsOf(context)) return;
    _timer = Timer.periodic(HeroCarousel.autoAdvance, (_) => _advance());
  }

  void _advance() {
    final controller = _controller;
    // Not while another tab is on screen.
    if (!mounted || !TickerMode.valuesOf(context).enabled) return;
    if (controller == null || !controller.hasClients) return;
    controller.nextPage(
      duration: HeroCarousel.slide,
      curve: Curves.easeInOutCubic,
    );
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _timer?.cancel();
    } else if (notification is ScrollEndNotification) {
      _restart();
    }
    return false;
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
            padding: EdgeInsetsDirectional.only(
              start: (AppSpacing.lg - _gap).w,
            ),
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: PageView.builder(
                controller: controller,
                padEnds: false,
                itemBuilder: (context, index) {
                  final promo = widget.promos[index % _count];
                  return Padding(
                    padding: EdgeInsetsDirectional.only(start: _gap.w),
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
        ),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => PageDots(
            count: _count,
            current:
                (controller.hasClients
                    ? (controller.page ?? 0).round()
                    : controller.initialPage) %
                _count,
          ),
        ),
      ],
    );
  }
}
