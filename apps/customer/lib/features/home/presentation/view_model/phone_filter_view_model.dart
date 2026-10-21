import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'phone_filter_view_model.g.dart';

/// The phones row's chosen filter: null for all phones, else the index of
/// the server's facet.
@riverpod
class PhoneFilterViewModel extends _$PhoneFilterViewModel {
  @override
  int? build() => null;

  // A setter would hide that null clears the filter.
  // ignore: use_setters_to_change_properties
  void select(int? facet) => state = facet;
}
