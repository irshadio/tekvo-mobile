import 'package:flutter/foundation.dart';

enum AnswerBy { seller, buyer }

/// The order questions are listed in.
enum QuestionSort { mostHelpful, newest }

/// One reply to a question.
@immutable
final class Answer {
  const Answer({
    required this.text,
    required this.author,
    required this.by,
    required this.helpful,
  });

  final String text;

  /// Who answered, such as `Nova Official Store`.
  final String author;
  final AnswerBy by;
  final int helpful;
}

/// A question someone asked, with its answers, the best first.
@immutable
final class ProductQuestion {
  const ProductQuestion({
    required this.id,
    required this.question,
    required this.answers,
    this.topic,
  });

  final String id;
  final String question;
  final List<Answer> answers;

  /// The filter that finds it, such as `Battery`.
  final String? topic;

  Answer get best => answers.first;
}

/// A few questions and how many there are, for the product page.
@immutable
final class Questions {
  const Questions({required this.top, required this.total});

  final List<ProductQuestion> top;
  final int total;
}

/// The questions the filter and search keep, with the screen's summary.
@immutable
final class QuestionsPage {
  const QuestionsPage({
    required this.product,
    required this.topics,
    required this.total,
    required this.answerCount,
    required this.questions,
  });

  /// Such as `Nova X Pro 5G · 256 GB`.
  final String product;

  /// The topics to filter by, such as `Battery`.
  final List<String> topics;

  /// How many questions the product has in all.
  final int total;

  /// How many answers they have in all.
  final int answerCount;
  final List<ProductQuestion> questions;
}
