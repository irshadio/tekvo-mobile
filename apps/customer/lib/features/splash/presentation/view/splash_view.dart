import 'dart:async';

import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/splash/presentation/view/widgets/splash_frame.dart';
import 'package:customer/features/splash/presentation/view/widgets/splash_scene.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The first screen: the logo mark grows and rises, the wordmark slides in,
/// then the lockup settles with the tagline, loader and footer, as in the
/// Figma prototype. Under reduced motion it shows the settled frame at once.
/// After [hold] on the settled frame it dissolves into onboarding.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  /// How long the settled frame stays before onboarding.
  static const Duration hold = Duration(milliseconds: 1200);

  /// How long onboarding takes to dissolve in.
  static const Duration handOff = Duration(milliseconds: 300);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timeline = AnimationController(
    vsync: this,
    duration: SplashFrame.timeline,
  )..addStatusListener(_onTimeline);

  Timer? _holdTimer;

  void _onTimeline(AnimationStatus status) {
    if (status != AnimationStatus.completed || _holdTimer != null) return;
    _holdTimer = Timer(SplashView.hold, _openOnboarding);
  }

  void _openOnboarding() {
    if (!mounted) return;
    unawaited(context.pushReplacementNamed<void, void>(Routes.onboarding));
  }

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
    _holdTimer?.cancel();
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
