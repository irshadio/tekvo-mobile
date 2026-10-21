import 'package:flutter/material.dart';

/// The platform page transition. The type argument is the route's result
/// type and must match the caller's `pushNamed<T>`.
Route<dynamic> materialRoute<T>(Widget page, RouteSettings settings) =>
    MaterialPageRoute<T>(builder: (_) => page, settings: settings);

/// How long [fadeRoute] takes to fade in; the reverse keeps the default.
const Duration fadeInDuration = Duration(milliseconds: 400);

/// A cross-fade instead of the platform slide.
Route<dynamic> fadeRoute(Widget page, RouteSettings settings) =>
    PageRouteBuilder<void>(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (context, animation, _, child) => FadeTransition(
        opacity: MediaQuery.disableAnimationsOf(context)
            ? kAlwaysCompleteAnimation
            : animation,
        child: child,
      ),
      transitionDuration: fadeInDuration,
    );

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
