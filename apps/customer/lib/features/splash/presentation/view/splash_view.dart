import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/splash/presentation/view/widgets/splash_frame.dart';
import 'package:customer/features/splash/presentation/view/widgets/splash_scene.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The first screen: the logo mark grows and rises, the wordmark slides in,
/// then the lockup settles with the tagline, loader and footer, as in the
/// Figma prototype. Under reduced motion it shows the settled frame at once.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timeline = AnimationController(
    vsync: this,
    duration: SplashFrame.timeline,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _timeline.value = 1;
    } else if (_timeline.isDismissed) {
      _timeline.forward();
    }
  }

  @override
  void dispose() {
    _timeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.over(context.brandColors.background),
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _timeline,
          builder: (context, _) =>
              SplashScene(frame: SplashFrame.at(_timeline.value)),
        ),
      ),
    );
  }
}
