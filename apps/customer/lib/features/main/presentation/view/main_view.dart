import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:customer/features/main/presentation/view/widgets/main_nav_bar.dart';
import 'package:customer/features/main/presentation/view/widgets/main_placeholder_page.dart';
import 'package:customer/features/main/presentation/view_model/main_tab_view_model.dart';
import 'package:customer/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The signed-in shell: one page per [MainTab] behind the bottom
/// navigation, dissolving in when its tab is picked. Pages keep their state
/// while another tab is on screen. Back on any tab but home returns to
/// home; back on home leaves the app.
class MainView extends ConsumerWidget {
  const MainView({this.pages = const <MainTab, Widget>{}, super.key});

  /// Each tab's page, supplied by `app/` since features cannot import one
  /// another; a tab without one shows a placeholder.
  final Map<MainTab, Widget> pages;

  /// How long the shell takes to dissolve in after sign-up.
  static const Duration entryFade = Duration(milliseconds: 350);

  /// How long a tab's page takes to dissolve in, as in the prototype.
  static const Duration tabFade = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(mainTabViewModelProvider);
    final l10n = context.l10n;
    final colors = context.colors;
    void select(MainTab value) =>
        ref.read(mainTabViewModelProvider.notifier).tab = value;

    return PopScope(
      canPop: tab == MainTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) select(MainTab.home);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemBars.surface(colors),
        child: Scaffold(
          backgroundColor: colors.surface,
          body: _FadeIndexedStack(
            index: tab.index,
            duration: context.motion(tabFade),
            children: <Widget>[
              for (final page in MainTab.values)
                // Hidden pages keep their state but not their animations.
                TickerMode(
                  enabled: page == tab,
                  child:
                      pages[page] ??
                      MainPlaceholderPage(title: tabLabel(page, l10n)),
                ),
            ],
          ),
          bottomNavigationBar: MainNavBar(selected: tab, onSelect: select),
        ),
      ),
    );
  }
}

/// An [IndexedStack] that dissolves the page in when [index] changes.
class _FadeIndexedStack extends StatefulWidget {
  const _FadeIndexedStack({
    required this.index,
    required this.duration,
    required this.children,
  });

  final int index;
  final Duration duration;
  final List<Widget> children;

  @override
  State<_FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<_FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );

  @override
  void didUpdateWidget(_FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fade.duration = widget.duration;
    if (oldWidget.index != widget.index) _fade.forward(from: 0);
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: IndexedStack(index: widget.index, children: widget.children),
  );
}
