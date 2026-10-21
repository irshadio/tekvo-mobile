import 'package:core/storage/local_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_store.g.dart';

/// Whether onboarding has been completed on this install.
///
/// Core, not a feature's: splash reads it and onboarding writes it, and
/// neither feature may import the other.
abstract interface class OnboardingStore {
  Future<bool> hasCompletedOnboarding();
  Future<void> markOnboardingCompleted();
}

/// [OnboardingStore] in the local database. Not a user-data store, so ending
/// a session keeps it; an uninstall clears it.
class OnboardingStoreImpl implements OnboardingStore {
  OnboardingStoreImpl(this._store);

  final LocalStore _store;

  static const String storeName = 'app_flags';
  static const String _key = 'onboarding';

  @override
  Future<bool> hasCompletedOnboarding() async {
    final record = await _store.read(storeName, _key);
    return record?['completed'] == true;
  }

  @override
  Future<void> markOnboardingCompleted() =>
      _store.write(storeName, _key, <String, Object?>{'completed': true});
}

/// Bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
OnboardingStore onboardingStore(Ref ref) => throw UnimplementedError(
  'onboardingStoreProvider must be overridden in ProviderScope '
  '(core/bootstrap).',
);
