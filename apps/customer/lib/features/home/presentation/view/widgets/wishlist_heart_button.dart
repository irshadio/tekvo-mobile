import 'package:core/assets/assets.gen.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The white wishlist heart over a product photo. Saving fills it in the
/// sale red with a pop and a ring spreading from it; unsaving pops it back
/// to an outline.
class WishlistHeartButton extends StatefulWidget {
  const WishlistHeartButton({
    required this.saved,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final bool saved;
  final String tooltip;
  final VoidCallback onPressed;

  static const double size = 36;

  @override
  State<WishlistHeartButton> createState() => _WishlistHeartButtonState();
}

class _WishlistHeartButtonState extends State<WishlistHeartButton>
    with SingleTickerProviderStateMixin {
  static const double _icon = 22;
  static const double _ringStart = 0.6;
  static const double _ringEnd = 1.7;
  static const double _ringOpacity = 0.35;
  static const Duration _pop = Duration(milliseconds: 450);
  static const Duration _swap = Duration(milliseconds: 150);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _pop,
  );

  /// Up past its size, a little under, then settled.
  late final Animation<double> _scale = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: 1.35,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.35,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.9,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ],
  ).animate(_controller);

  late final Animation<double> _ring = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void didUpdateWidget(WishlistHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.saved != widget.saved &&
        !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sale = context.appColors.commerceSale;
    final size = WishlistHeartButton.size.r;
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        toggled: widget.saved,
        label: widget.tooltip,
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AppEffects.glassButton,
          ),
          child: Material(
            color: colors.surfaceContainerLowest,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onPressed,
              child: SizedBox.square(
                dimension: size,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    if (widget.saved)
                      AnimatedBuilder(
                        animation: _ring,
                        builder: (context, _) =>
                            _ring.isCompleted || _ring.isDismissed
                            ? const SizedBox.shrink()
                            : Container(
                                width:
                                    size *
                                    (_ringStart +
                                        (_ringEnd - _ringStart) * _ring.value),
                                height:
                                    size *
                                    (_ringStart +
                                        (_ringEnd - _ringStart) * _ring.value),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: sale.withValues(
                                      alpha: _ringOpacity * (1 - _ring.value),
                                    ),
                                    width: 2,
                                  ),
                                ),
                              ),
                      ),
                    ScaleTransition(
                      scale: _scale,
                      child: AnimatedSwitcher(
                        duration: context.motion(_swap),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: SvgPicture.asset(
                          widget.saved
                              ? Assets.iconsHeartFilled
                              : Assets.iconsHeart,
                          key: ValueKey<bool>(widget.saved),
                          width: _icon.r,
                          height: _icon.r,
                          colorFilter: ColorFilter.mode(
                            widget.saved ? sale : colors.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
