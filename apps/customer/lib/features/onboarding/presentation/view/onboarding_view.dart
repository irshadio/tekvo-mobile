import 'dart:async';

import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/extensions/ref_extensions.dart';
import 'package:core/presentation/widgets/app_logo_mark.dart';
import 'package:core/state/submission_state.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/onboarding/presentation/view/widgets/onboarding_footer.dart';
import 'package:customer/features/onboarding/presentation/view/widgets/onboarding_page.dart';
import 'package:customer/features/onboarding/presentation/view/widgets/onboarding_slide.dart';
import 'package:customer/features/onboarding/presentation/view_model/onboarding_page_view_model.dart';
import 'package:customer/features/onboarding/presentation/view_model/onboarding_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:customer/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Three introduction pages: swipe or tap Next through them; Skip, Get
/// started or Continue as guest record onboarding as completed and go on to
/// the location permission.
class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  /// How long Next takes to bring in the following page.
  static const Duration pageDuration = Duration(milliseconds: 300);

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  static const List<OnboardingSlide> _slides = OnboardingSlide.values;
  static const double _settledTolerance = 0.01;
  static const double _topBarHeight = 52;
  static const double _logo = 32;
  static const double _sidePadding = 20;
  static const double _tapTarget = 48;

  /// Skip's own horizontal padding; the bar's end padding makes up the rest
  /// of the design's 20, so the label sits where designed and the ripple
  /// stays clear of the screen edge.
  static const double _skipPadding = 12;

  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The page on screen or being moved to, fractional while swiping.
  double get _position => _controller.hasClients ? _controller.page ?? 0 : 0;

  bool get _atFirstPage => _position < _settledTolerance;

  void _step(int delta) {
    final target = (_position.round() + delta).clamp(0, _slides.length - 1);
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(target);
      return;
    }
    _controller.animateToPage(
      target,
      duration: OnboardingView.pageDuration,
      curve: Curves.easeInOut,
    );
  }

  void _complete() =>
      unawaited(ref.read(onboardingViewModelProvider.notifier).complete());

  @override
  Widget build(BuildContext context) {
    ref.listenSubmission(
      onboardingViewModelProvider,
      context,
      onSuccess: (_) => unawaited(
        context.pushReplacementNamed<void, void>(Routes.locationPermission),
      ),
      onFailure: (_) => context.showSnackBar(
        context.l10n.onboardingSaveFailed,
        isError: true,
      ),
    );
    final submitting = ref.watch(onboardingViewModelProvider).isInProgress;
    final background = context.colors.surfaceContainerLowest;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => PopScope(
        canPop: _atFirstPage,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _step(-1);
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppSystemBars.over(background),
          child: Scaffold(
            backgroundColor: background,
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  _topBar(
                    context,
                    showSkip: _position.round() < _slides.length - 1,
                    submitting: submitting,
                  ),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        PageView.builder(
                          controller: _controller,
                          itemCount: _slides.length,
                          onPageChanged: (index) =>
                              ref
                                      .read(
                                        onboardingPageViewModelProvider
                                            .notifier,
                                      )
                                      .page =
                                  index,
                          itemBuilder: (context, index) =>
                              OnboardingPage(slide: _slides[index]),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: OnboardingFooter(
                            count: _slides.length,
                            position: _position,
                            onNext: () => _step(1),
                            onFinish: submitting ? null : _complete,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(
    BuildContext context, {
    required bool showSkip,
    required bool submitting,
  }) {
    return SizedBox(
      height: _topBarHeight.h,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: _sidePadding.w,
          end: (_sidePadding - _skipPadding).w,
        ),
        child: Row(
          children: <Widget>[
            ExcludeSemantics(child: AppLogoMark(size: _logo.r)),
            const Spacer(),
            AnimatedOpacity(
              opacity: showSkip ? 1 : 0,
              duration: context.motion(OnboardingView.pageDuration),
              child: IgnorePointer(
                ignoring: !showSkip,
                child: TextButton(
                  onPressed: submitting ? null : _complete,
                  style: TextButton.styleFrom(
                    minimumSize: const Size.square(_tapTarget),
                    padding: EdgeInsets.symmetric(horizontal: _skipPadding.w),
                    foregroundColor: context.colors.onSurfaceVariant,
                  ),
                  child: Text(context.l10n.onboardingSkip),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
