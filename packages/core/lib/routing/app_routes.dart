import 'package:flutter/widgets.dart';

/// For navigation from non-widget code, e.g. redirecting after a 401. Each
/// app attaches it to its `MaterialApp`; route names live in the app's own
/// `routing/app_routes.dart`.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
