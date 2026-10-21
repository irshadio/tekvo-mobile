import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Shown for a route name no screen answers to.
class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(context.coreL10n.routeNotFound)),
    );
  }
}
