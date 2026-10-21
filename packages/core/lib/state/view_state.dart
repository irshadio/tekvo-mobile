import 'package:core/error/failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'view_state.freezed.dart';

/// The display-state union every reading ViewModel exposes and every View
/// renders through `ViewStateSwitcher`.
///
/// `loading`, `error` and `noInternet` carry the last loaded value as
/// `previous`, so a refresh keeps the current data on screen.
@freezed
sealed class ViewState<T> with _$ViewState<T> {
  /// Nothing requested yet.
  const factory ViewState.idle() = ViewIdle<T>;

  const factory ViewState.loading({T? previous}) = ViewLoading<T>;

  const factory ViewState.data(T value) = ViewData<T>;

  const factory ViewState.error(Failure failure, {T? previous}) = ViewError<T>;

  const factory ViewState.noInternet({T? previous}) = ViewNoInternet<T>;
}

extension ViewStateX<T> on ViewState<T> {
  /// The latest successful value, including one carried as `previous`.
  T? get dataOrNull => switch (this) {
    ViewData<T>(:final value) => value,
    ViewLoading<T>(:final previous) => previous,
    ViewError<T>(:final previous) => previous,
    ViewNoInternet<T>(:final previous) => previous,
    ViewIdle<T>() => null,
  };

  bool get isLoading => this is ViewLoading<T>;
}
