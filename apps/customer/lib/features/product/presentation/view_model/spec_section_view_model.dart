import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'spec_section_view_model.g.dart';

/// The part of the specification in view, by its jump chip's index; the
/// overview is 0.
@riverpod
class SpecSectionViewModel extends _$SpecSectionViewModel {
  @override
  int build(String id) => 0;

  // The index is the whole state; a setter would read as a field.
  // ignore: use_setters_to_change_properties
  void show(int index) => state = index;
}
