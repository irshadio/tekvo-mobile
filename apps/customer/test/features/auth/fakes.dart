import 'dart:async';

import 'package:core/error/failure.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:core/utils/social_account.dart';
import 'package:customer/features/auth/domain/repositories/otp_repository.dart';
import 'package:customer/features/auth/domain/repositories/social_auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Records each send and check; fails with [failure] when given, and holds
/// each call open until [answer] completes, when given.
class FakeOtpRepository implements OtpRepository {
  FakeOtpRepository({this.failure, this.answer});

  final Failure? failure;
  final Completer<void>? answer;
  final List<MobileContact> sent = <MobileContact>[];
  final List<String> checked = <String>[];

  @override
  Future<Either<Failure, Unit>> send(MobileContact contact) async {
    sent.add(contact);
    await answer?.future;
    final failure = this.failure;
    return failure == null ? right(unit) : left(failure);
  }

  @override
  Future<Either<Failure, Unit>> verify({
    required MobileContact contact,
    required String code,
  }) async {
    checked.add(code);
    await answer?.future;
    final failure = this.failure;
    return failure == null ? right(unit) : left(failure);
  }
}

/// Signs every provider in as [name] and [email], or fails with [failure].
class FakeSocialAuthRepository implements SocialAuthRepository {
  FakeSocialAuthRepository({this.failure});

  static const String name = 'Sam Rivera';
  static const String email = 'sam.rivera@gmail.com';

  final Failure? failure;

  @override
  Future<Either<Failure, SocialAccount>> signIn(
    SocialProvider provider,
  ) async {
    final failure = this.failure;
    return failure == null
        ? right(SocialAccount(provider: provider, name: name, email: email))
        : left(failure);
  }
}
