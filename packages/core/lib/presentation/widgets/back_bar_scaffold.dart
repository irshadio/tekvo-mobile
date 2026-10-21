import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/presentation/widgets/app_back_button.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_system_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A step screen: a bar with the back button and an optional [trailing]
/// action over [children] in a column that fills the screen, so a
/// `Spacer` pins the last child to the bottom, and scrolls when the screen
/// or the keyboard leaves too little room.
class BackBarScaffold extends StatelessWidget {
  const BackBarScaffold({required this.children, this.trailing, super.key});

  final List<Widget> children;
  final Widget? trailing;

  static const double _barHeight = 60;
  static const double _barStart = 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.surface(colors),
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: _barHeight.h,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: _barStart.w,
                    end: AppSpacing.lg.w,
                  ),
                  child: Row(
                    children: <Widget>[
                      const AppBackButton(),
                      const Spacer(),
                      ?trailing,
                    ],
                  ),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg.w,
                      ),
                      sliver: SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
