import 'package:customer/features/product/domain/entities/product_reviews.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_query_view_model.g.dart';

/// Which reviews to show, in what order, and how many pages.
@immutable
final class ReviewQuery {
  const ReviewQuery({
    this.filter = ReviewFilter.all,
    this.sort = ReviewSort.mostHelpful,
    this.pages = 1,
  });

  final ReviewFilter filter;
  final ReviewSort sort;
  final int pages;

  @override
  bool operator ==(Object other) =>
      other is ReviewQuery &&
      other.filter == filter &&
      other.sort == sort &&
      other.pages == pages;

  @override
  int get hashCode => Object.hash(filter, sort, pages);
}

/// The reviews screen's filter, sort and paging for a product.
@riverpod
class ReviewQueryViewModel extends _$ReviewQueryViewModel {
  @override
  ReviewQuery build(String productId) => const ReviewQuery();

  /// A new filter starts again from the first page.
  void filter(ReviewFilter filter) =>
      state = ReviewQuery(filter: filter, sort: state.sort);

  void sort(ReviewSort sort) =>
      state = ReviewQuery(filter: state.filter, sort: sort);

  void more() => state = ReviewQuery(
    filter: state.filter,
    sort: state.sort,
    pages: state.pages + 1,
  );
}
