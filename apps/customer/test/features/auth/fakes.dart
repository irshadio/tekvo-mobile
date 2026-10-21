import 'dart:async';

import 'package:core/error/failure.dart';
import 'package:core/utils/mobile_contact.dart';
import 'package:customer/features/auth/domain/repositories/otp_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Records each send; fails with [failure] when given, and holds the send
/// open until [answer] completes, when given.
class FakeOtpRepository implements OtpRepository {
  FakeOtpRepository({this.failure, this.answer});

  final Failure? failure;
  final Completer<void>? answer;
  final List<MobileContact> sent = <MobileContact>[];

  @override
  Future<Either<Failure, Unit>> send(MobileContact contact) async {
    sent.add(contact);
    await answer?.future;
    final failure = this.failure;
    return failure == null ? right(unit) : left(failure);
  }
}
