import 'package:flutter/material.dart';

/// Stands in for a widget that failed to build: a plain fill in place of the
/// framework's error box. It takes no space where the space is unbounded.
class ErrorFallback extends StatelessWidget {
  const ErrorFallback({super.key});

  @override
  Widget build(BuildContext context) => LimitedBox(
    maxWidth: 0,
    maxHeight: 0,
    child: SizedBox.expand(
      child: ColoredBox(color: Theme.of(context).colorScheme.surface),
    ),
  );
}
