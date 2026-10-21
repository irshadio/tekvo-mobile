import 'package:core/storage/local_store.dart';
import 'package:core/storage/onboarding_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late LocalStore local;
  late OnboardingStore store;

  setUp(() async {
    local = LocalStoreImpl(
      await newDatabaseFactoryMemory().openDatabase('onboarding.db'),
    );
    store = OnboardingStoreImpl(local);
  });

  test('is not completed on a fresh install', () async {
    expect(await store.hasCompletedOnboarding(), isFalse);
  });

  test('stays completed once marked', () async {
    await store.markOnboardingCompleted();

    expect(await store.hasCompletedOnboarding(), isTrue);
  });

  test('treats an unexpected record as not completed', () async {
    await local.write(
      OnboardingStoreImpl.storeName,
      'onboarding',
      <String, Object?>{'completed': 'yes'},
    );

    expect(await store.hasCompletedOnboarding(), isFalse);
  });
}
