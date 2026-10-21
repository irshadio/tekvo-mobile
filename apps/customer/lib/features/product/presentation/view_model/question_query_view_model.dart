import 'package:customer/features/product/domain/entities/product_questions.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'question_query_view_model.g.dart';

/// Which questions to show and in what order.
@immutable
final class QuestionQuery {
  const QuestionQuery({
    this.topic,
    this.search = '',
    this.sort = QuestionSort.mostHelpful,
  });

  /// Null for every topic.
  final String? topic;
  final String search;
  final QuestionSort sort;

  @override
  bool operator ==(Object other) =>
      other is QuestionQuery &&
      other.topic == topic &&
      other.search == search &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(topic, search, sort);
}

/// The questions screen's topic, search and sort for a product.
@riverpod
class QuestionQueryViewModel extends _$QuestionQueryViewModel {
  @override
  QuestionQuery build(String productId) => const QuestionQuery();

  void topic(String? topic) => state = QuestionQuery(
    topic: topic,
    search: state.search,
    sort: state.sort,
  );

  void search(String search) => state = QuestionQuery(
    topic: state.topic,
    search: search,
    sort: state.sort,
  );

  void sort(QuestionSort sort) => state = QuestionQuery(
    topic: state.topic,
    search: state.search,
    sort: sort,
  );
}
