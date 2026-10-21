import 'package:core/error/failure.dart';
import 'package:customer/features/product/data/sources/product_local_data_source.dart';
import 'package:customer/features/product/data/sources/questions_local_data_source.dart';
import 'package:customer/features/product/data/sources/reviews_local_data_source.dart';
import 'package:customer/features/product/domain/entities/product_details.dart';
import 'package:customer/features/product/domain/entities/product_questions.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:customer/features/product/domain/entities/product_specifications.dart';
import 'package:customer/features/product/domain/entities/review_form.dart';
import 'package:customer/features/product/domain/repositories/product_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Serves products from the stand-in source until the catalogue is served.
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({
    this._local = const ProductLocalDataSource(),
    this._reviews = const ReviewsLocalDataSource(),
    this._questions = const QuestionsLocalDataSource(),
  });

  final ProductLocalDataSource _local;
  final ReviewsLocalDataSource _reviews;
  final QuestionsLocalDataSource _questions;

  @override
  Future<Either<Failure, ProductDetails>> details(String id) async =>
      right(_local.details(id));

  @override
  Future<Either<Failure, ProductSpecifications>> specifications(
    String id,
  ) async => right(_local.specifications(id));

  @override
  Future<Either<Failure, ReviewsPage>> reviews(
    String id, {
    required ReviewFilter filter,
    required ReviewSort sort,
    required int pages,
  }) async => right(
    _reviews.reviews(id, filter: filter, sort: sort, pages: pages),
  );

  /// The sample product every id shows.
  static ProductDetails get sample =>
      const ProductLocalDataSource().details('');

  @override
  Future<Either<Failure, ReviewForm>> reviewForm(String id) async =>
      right(_reviews.form(id));

  @override
  Future<Either<Failure, ReviewReceipt>> submitReview(
    String id,
    ReviewDraft draft,
  ) async => right(_reviews.submit(id, draft));

  @override
  Future<Either<Failure, QuestionsPage>> questions(
    String id, {
    required String? topic,
    required String search,
    required QuestionSort sort,
  }) async => right(
    _questions.questions(id, topic: topic, search: search, sort: sort),
  );

  @override
  Future<Either<Failure, Unit>> post(
    String id,
    String text, {
    String? questionId,
    bool notify = true,
  }) async => right(unit);
}
