import 'package:customer/features/registration/data/repositories/profile_repository_impl.dart';
import 'package:customer/features/registration/domain/repositories/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Binds the registration contracts; aggregated in `app/run_app.dart`.
final List<Override> registrationOverrides = <Override>[
  profileRepositoryProvider.overrideWith(
    (ref) => const ProfileRepositoryImpl(),
  ),
];
