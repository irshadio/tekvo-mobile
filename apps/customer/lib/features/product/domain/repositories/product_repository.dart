import 'package:core/error/failure.dart';
import 'package:customer/features/product/domain/entities/product_details.dart';
import 'package:customer/features/product/domain/entities/product_questions.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/domain/entities/product_specifications.dart';
import 'package:customer/features/product/domain/entities/review_form.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_repository.g.dart';

/// Serves a product's details and the screens they open.
abstract interface class ProductRepository {
  Future<Either<Failure, ProductDetails>> details(String id);

  Future<Either<Failure, ProductSpecifications>> specifications(String id);

  /// The first [pages] pages of reviews that [filter] keeps, in [sort]
  /// order.
  Future<Either<Failure, ReviewsPage>> reviews(
    String id, {
    required ReviewFilter filter,
    required ReviewSort sort,
    required int pages,
  });

  Future<Either<Failure, ReviewForm>> reviewForm(String id);

  Future<Either<Failure, ReviewReceipt>> submitReview(
    String id,
    ReviewDraft draft,
  );

  /// The questions about [topic], or all, that match [search].
  Future<Either<Failure, QuestionsPage>> questions(
    String id, {
    required String? topic,
    required String search,
    required QuestionSort sort,
  });

  /// Posts a question, or an answer to [questionId] when given.
  Future<Either<Failure, Unit>> post(
    String id,
    String text, {
    String? questionId,
    bool notify = true,
  });
}

/// Bound in `product_overrides.dart`.
@riverpod
ProductRepository productRepository(Ref ref) => throw UnimplementedError(
  'productRepositoryProvider must be overridden; see product_overrides.dart.',
);
