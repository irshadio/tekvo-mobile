import 'package:core/presentation/widgets/not_found_view.dart';
import 'package:core/routing/route_transitions.dart';
import 'package:flutter/material.dart';
import 'package:rider/features/splash/presentation/view/splash_view.dart';
import 'package:rider/routing/app_routes.dart';

/// Maps route names to screens. Lives in `app/` because it imports feature
/// views.
///
/// A route's type argument is its result type and must match the caller's
/// `pushNamed<T>`, or Navigator's internal cast throws on push.
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  return switch (settings.name) {
    Routes.splash => materialRoute<void>(const SplashView(), settings),
    _ => materialRoute<void>(const NotFoundView(), settings),
  };
}
