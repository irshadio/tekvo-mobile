import 'package:customer/features/main/presentation/view_model/main_tab_view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows [tab] in the main shell from a screen pushed over it, closing the
/// screens in between. Lives in `app/` because it joins features.
void openShellTab(BuildContext context, MainTab tab) {
  ProviderScope.containerOf(
    context,
    listen: false,
  ).read(mainTabViewModelProvider.notifier).tab = tab;
  Navigator.of(context).popUntil((route) => route.isFirst);
}
