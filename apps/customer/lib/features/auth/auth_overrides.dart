import 'package:customer/features/auth/data/repositories/otp_repository_impl.dart';
import 'package:customer/features/auth/domain/repositories/otp_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Binds the auth contracts; aggregated in `app/run_app.dart`.
final List<Override> authOverrides = <Override>[
  otpRepositoryProvider.overrideWith((ref) => const OtpRepositoryImpl()),
];
