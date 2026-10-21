import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_page_view_model.g.dart';

/// The onboarding page on screen.
@riverpod
class OnboardingPageViewModel extends _$OnboardingPageViewModel {
  @override
  int build() => 0;

  int get page => state;

  set page(int value) => state = value;
}
