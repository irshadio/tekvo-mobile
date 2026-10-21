import 'package:core/error/failure.dart';
import 'package:core/presentation/widgets/state_views.dart';
import 'package:core/state/view_state.dart';
import 'package:flutter/material.dart';

/// Renders a [ViewState]. Only [onData] is required; other states fall back
/// to the default loading, error and no-internet views.
///
/// A refresh or a failed refresh keeps the previous data on screen (pair it
/// with `listenRefreshFailures`); only a first load without data shows the
/// loading, error or no-internet view.
class ViewStateSwitcher<T> extends StatelessWidget {
  const ViewStateSwitcher({
    required this.state,
    required this.onData,
    super.key,
    this.onIdle,
    this.onLoading,
    this.onError,
    this.onNoInternet,
    this.onRetry,
  });

  final ViewState<T> state;
  final Widget Function(T data) onData;
  final WidgetBuilder? onIdle;
  final WidgetBuilder? onLoading;
  final Widget Function(BuildContext context, Failure failure)? onError;
  final WidgetBuilder? onNoInternet;

  /// Passed to the default error and no-internet views.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ViewIdle<T>() => onIdle?.call(context) ?? const SizedBox.shrink(),
      ViewLoading<T>(:final previous) =>
        previous != null
            ? onData(previous)
            : (onLoading?.call(context) ?? const AppLoadingView()),
      ViewData<T>(:final value) => onData(value),
      ViewError<T>(:final failure, :final previous) =>
        previous != null
            ? onData(previous)
            : (onError?.call(context, failure) ??
                  AppErrorView(failure: failure, onRetry: onRetry)),
      ViewNoInternet<T>(:final previous) =>
        previous != null
            ? onData(previous)
            : (onNoInternet?.call(context) ??
                  AppNoInternetView(onRetry: onRetry)),
    };
  }
}
