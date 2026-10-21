import 'package:core/assets/assets.gen.dart';
import 'package:core/network/network_banner.dart';
import 'package:core/presentation/extensions/context_extensions.dart';
import 'package:core/theme/app_motion.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Lays the whole app out above a strip saying the device is offline, or
/// briefly that it is back online, so
/// every screen is pushed up instead of covered. Wraps the navigator in
/// `MaterialApp.builder`; screens never place it themselves.
///
/// Offline, the strip fills the bottom inset, behind the home indicator,
/// and grows above it only as far as its text needs; the screens are laid
/// out without the inset. Under Android's button navigation, whose buttons
/// would cover the text, it sits above the inset instead. It takes no space
/// online, and steps aside while the keyboard is up.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({required this.child, super.key});

  final Widget child;

  static const Duration duration = AppMotion.short;

  /// Offline to online: the colour blends while the message slides up.
  static const Duration switchDuration = Duration(milliseconds: 350);
  static const double _iconSize = 16;

  static const Curve _showCurve = Curves.easeOut;
  static const Curve _hideCurve = Curves.easeIn;

  /// The shortest bottom inset that holds Android's navigation buttons
  /// (48 dp) rather than the gesture handle.
  static const double _buttonNavInset = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(networkBannerStatusProvider);
    final visible =
        status != NetworkBanner.hidden &&
        MediaQuery.viewInsetsOf(context).bottom == 0;
    return ColoredBox(
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            // The inset leaves the screens as fast as the strip grows, so
            // nothing jumps while it animates.
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: visible ? 1 : 0),
              duration: context.motion(duration),
              // Run from 1 down to 0, the hide curve is flipped to match.
              curve: visible ? _showCurve : _hideCurve.flipped,
              builder: _withoutInset,
              child: child,
            ),
          ),
          AnimatedSwitcher(
            duration: context.motion(duration),
            switchInCurve: _showCurve,
            switchOutCurve: _hideCurve,
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.topCenter,
              child: child,
            ),
            child: visible
                ? _strip(context, online: status == NetworkBanner.online)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// [child] with [removed] of the bottom inset taken away, 0 to 1. Always
  /// a MediaQuery, so the app below is never remounted.
  static Widget _withoutInset(
    BuildContext context,
    double removed,
    Widget? child,
  ) {
    final data = MediaQuery.of(context);
    final keep = (1 - removed).clamp(0.0, 1.0);
    return MediaQuery(
      data: data.copyWith(
        padding: data.padding.copyWith(bottom: data.padding.bottom * keep),
        viewPadding: data.viewPadding.copyWith(
          bottom: data.viewPadding.bottom * keep,
        ),
      ),
      child: child!,
    );
  }

  Widget _strip(BuildContext context, {required bool online}) {
    final inset = MediaQuery.paddingOf(context).bottom;
    final behindInset =
        defaultTargetPlatform != TargetPlatform.android ||
        inset < _buttonNavInset;
    final switching = context.motion(switchDuration);
    final strip = Semantics(
      liveRegion: true,
      child: AnimatedContainer(
        duration: switching,
        curve: Curves.easeInOut,
        color: online
            ? context.appColors.statusSuccess
            : context.colors.inverseSurface,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: behindInset ? inset : 0),
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xs,
                horizontal: AppSpacing.lg,
              ),
              child: ClipRect(
                child: AnimatedSwitcher(
                  duration: switching,
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => _slide(
                    child,
                    animation,
                    incoming: child.key == ValueKey<bool>(online),
                  ),
                  child: _message(context, online: online),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (behindInset) return strip;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        strip,
        SizedBox(height: inset),
      ],
    );
  }

  /// The incoming message rises from below; the outgoing one leaves upward.
  static Widget _slide(
    Widget child,
    Animation<double> animation, {
    required bool incoming,
  }) {
    final from = Offset(0, incoming ? 0.6 : -0.6);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: from,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Widget _message(BuildContext context, {required bool online}) {
    final foreground = online
        ? context.appColors.statusOnSuccess
        : context.colors.onInverseSurface;
    return Material(
      key: ValueKey<bool>(online),
      type: MaterialType.transparency,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            online ? Assets.iconsOnline : Assets.iconsOffline,
            width: _iconSize.r,
            height: _iconSize.r,
            colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              online
                  ? context.coreL10n.onlineBanner
                  : context.coreL10n.offlineBanner,
              style: context.textTheme.labelMedium?.copyWith(
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
