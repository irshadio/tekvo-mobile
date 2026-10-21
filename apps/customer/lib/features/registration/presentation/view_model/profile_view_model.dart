import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_view_model.freezed.dart';
part 'profile_view_model.g.dart';

/// The profile being entered.
@freezed
abstract class ProfileFormState with _$ProfileFormState {
  const factory ProfileFormState({
    @Default('') String name,
    @Default('') String email,
  }) = _ProfileFormState;

  const ProfileFormState._();

  static final RegExp _email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// A name, and an email only if it reads as one. For UX only: the server
  /// validates both.
  bool get isComplete =>
      name.trim().isNotEmpty &&
      (email.trim().isEmpty || _email.hasMatch(email.trim()));
}

/// The profile form, filled in from a Google or Apple account when there is
/// one.
@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  ProfileFormState build() => const ProfileFormState();

  void fill({required String name, required String email}) =>
      state = ProfileFormState(name: name, email: email);

  void nameChanged(String name) => state = state.copyWith(name: name);

  void emailChanged(String email) => state = state.copyWith(email: email);
}
