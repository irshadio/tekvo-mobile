import 'package:flutter/material.dart';

/// The platform page transition. The type argument is the route's result
/// type and must match the caller's `pushNamed<T>`.
Route<dynamic> materialRoute<T>(Widget page, RouteSettings settings) =>
    MaterialPageRoute<T>(builder: (_) => page, settings: settings);

/// How long [fadeRoute] takes to fade in; the reverse keeps the default.
const Duration fadeInDuration = Duration(milliseconds: 400);

/// A cross-fade instead of the platform slide, over [duration].
Route<dynamic> fadeRoute(
  Widget page,
  RouteSettings settings, {
  Duration duration = fadeInDuration,
}) => PageRouteBuilder<void>(
  settings: settings,
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (context, animation, _, child) => FadeTransition(
    opacity: MediaQuery.disableAnimationsOf(context)
        ? kAlwaysCompleteAnimation
        : animation,
    child: child,
  ),
  transitionDuration: duration,
);

/// How long [pushRoute] takes, the prototype's push between sign-in steps.
const Duration pushDuration = Duration(milliseconds: 350);

/// The prototype's push: the page slides in from the end edge while the
/// page under it, when also a push route, slides out to the start, over
/// [duration]; popping reverses both.
Route<dynamic> pushRoute<T>(
  Widget page,
  RouteSettings settings, {
  Duration duration = pushDuration,
}) => PageRouteBuilder<T>(
  settings: settings,
  transitionDuration: duration,
  reverseTransitionDuration: duration,
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final end = Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: Offset(end, 0),
          end: Offset.zero,
        ).chain(_pushCurve),
      ),
      child: SlideTransition(
        position: secondaryAnimation.drive(
          Tween<Offset>(
            begin: Offset.zero,
            end: Offset(-end, 0),
          ).chain(_pushCurve),
        ),
        child: child,
      ),
    );
  },
);

final Animatable<double> _pushCurve = CurveTween(curve: Curves.easeInOut);

/// Slides the page up from the bottom edge, and back down on pop.
Route<dynamic> slideUpRoute(Widget page, RouteSettings settings) =>
    _SlideUpRoute(page, settings, _SlideUp());

class _SlideUpRoute extends PageRouteBuilder<void> {
  _SlideUpRoute(Widget page, RouteSettings settings, this._slide)
    : super(
        settings: settings,
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (context, animation, _, child) => SlideTransition(
          position: MediaQuery.disableAnimationsOf(context)
              ? const AlwaysStoppedAnimation<Offset>(Offset.zero)
              : _slide.of(animation),
          child: child,
        ),
      );

  final _SlideUp _slide;

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }
}

/// The eased slide over a route's animation, built once and disposed with
/// the route.
class _SlideUp {
  static final Animatable<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  );

  CurvedAnimation? _curve;
  late Animation<Offset> _position;

  Animation<Offset> of(Animation<double> animation) {
    if (_curve?.parent != animation) {
      _curve?.dispose();
      final curve = _curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      _position = _offset.animate(curve);
    }
    return _position;
  }

  void dispose() => _curve?.dispose();
}
