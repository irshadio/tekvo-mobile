import 'package:customer/features/home/presentation/view/home_view.dart';
import 'package:customer/features/main/presentation/view/main_view.dart';
import 'package:customer/features/main/presentation/view_model/main_tab_view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The main shell with each built tab's page. Lives in `app/` because it
/// joins features that cannot import one another.
class CustomerShell extends ConsumerWidget {
  const CustomerShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void open(MainTab tab) =>
        ref.read(mainTabViewModelProvider.notifier).tab = tab;
    return MainView(
      pages: <MainTab, Widget>{
        MainTab.home: HomeView(
          onOpenExplore: () => open(MainTab.explore),
          onOpenCart: () => open(MainTab.cart),
        ),
      },
    );
  }
}
