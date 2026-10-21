import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The thin indeterminate loader: a bar sweeping back and forth along its
/// track. Under reduced motion it rests at the start, as designed.
class SplashLoader extends StatefulWidget {
  const SplashLoader({
    required this.trackColor,
    required this.barColor,
    super.key,
  });

  final Color trackColor;
  final Color barColor;

  /// Design sizes from the Figma "Loader" component.
  static const double width = 120;
  static const double height = 4;
  static const double barWidth = 48;

  /// One sweep from one end of the track to the other.
  static const Duration sweep = Duration(milliseconds: 900);

  @override
  State<SplashLoader> createState() => _SplashLoaderState();
}

class _SplashLoaderState extends State<SplashLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashLoader.sweep,
  );
  late final Animation<double> _position = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SplashLoader.height.r / 2);
    final travel = (SplashLoader.width - SplashLoader.barWidth).w;
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: SplashLoader.width.w,
        height: SplashLoader.height.r,
        child: ColoredBox(
          color: widget.trackColor,
          child: AnimatedBuilder(
            animation: _position,
            builder: (context, child) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: travel * _position.value,
                ),
                child: child,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.barColor,
                borderRadius: radius,
              ),
              child: SizedBox(
                width: SplashLoader.barWidth.w,
                height: SplashLoader.height.r,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
