import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main_tab_view_model.g.dart';

/// The main screen's tabs, in bottom navigation order.
enum MainTab { home, explore, cart, wishlist, profile }

/// The tab on screen.
@riverpod
class MainTabViewModel extends _$MainTabViewModel {
  @override
  MainTab build() => MainTab.home;

  MainTab get tab => state;

  set tab(MainTab value) => state = value;
}
