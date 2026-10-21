import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Scales `.w` / `.h` / `.r` / `.sp` values against the design canvas.
///
/// Wraps every app root. Build the theme inside [builder]: `.sp` throws until
/// this has initialised.
class DesignScale extends StatelessWidget {
  const DesignScale({required this.builder, super.key});

  /// The canvas the designs are drawn on.
  static const Size designSize = Size(393, 852);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: designSize,
      // Text follows the smaller of the width and height scales, like `.r`,
      // so it neither outgrows a wide screen nor overflows a short one.
      fontSizeResolver: FontSizeResolvers.radius,
      splitScreenMode: true,
      builder: (context, _) => builder(context),
    );
  }
}
