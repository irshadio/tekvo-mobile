import 'package:core/l10n/generated/core_localizations.dart';
import 'package:core/theme/app_brand_colors.dart';
import 'package:core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// View utilities as [BuildContext] extensions (no `BaseView` superclass).
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  CoreLocalizations get coreL10n => CoreLocalizations.of(this);
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
  AppBrandColors get brandColors => Theme.of(this).extension<AppBrandColors>()!;
  TextTheme get textTheme => Theme.of(this).textTheme;

  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  bool get isKeyboardOpen => MediaQuery.viewInsetsOf(this).bottom > 0;

  /// [duration], or none when the platform asks for reduced motion: for
  /// animations the design does not have.
  Duration motion(Duration duration) =>
      MediaQuery.disableAnimationsOf(this) ? Duration.zero : duration;

  /// [length] grown by as much as text of [fontSize] grows at the user's text
  /// size; [length] itself at the default size.
  double textScaled(double length, {required double fontSize}) =>
      length * (MediaQuery.textScalerOf(this).scale(fontSize) / fontSize);

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colors.error : null,
        ),
      );
  }

  Future<T?> pushNamed<T>(String route, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(route, arguments: arguments);

  Future<T?> pushReplacementNamed<T, R>(String route, {Object? arguments}) =>
      Navigator.of(
        this,
      ).pushReplacementNamed<T, R>(route, arguments: arguments);

  /// Opens [route] as the only route on the stack.
  Future<T?> pushNamedAndRemoveAll<T>(String route, {Object? arguments}) =>
      Navigator.of(
        this,
      ).pushNamedAndRemoveUntil<T>(route, (_) => false, arguments: arguments);

  void pop<T>([T? result]) => Navigator.of(this).pop<T>(result);
}
