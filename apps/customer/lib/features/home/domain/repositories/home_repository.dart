import 'package:core/error/failure.dart';
import 'package:customer/features/home/domain/entities/home_feed.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository.g.dart';

/// Serves the home tab's feed.
// A contract, bound per build in the overrides.
// ignore: one_member_abstracts
abstract interface class HomeRepository {
  Future<Either<Failure, HomeFeed>> feed();
}

/// Bound in `home_overrides.dart`.
@riverpod
HomeRepository homeRepository(Ref ref) => throw UnimplementedError(
  'homeRepositoryProvider must be overridden; see home_overrides.dart.',
);
