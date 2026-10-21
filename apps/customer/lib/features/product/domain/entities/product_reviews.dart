import 'package:flutter/foundation.dart';

/// A topic reviews mention, such as the battery, and how many do.
@immutable
final class ReviewMention {
  const ReviewMention({required this.label, required this.count});

  final String label;
  final int count;
}

/// What a buyer wrote.
@immutable
final class Review {
  const Review({
    required this.id,
    required this.author,
    required this.variant,
    required this.date,
    required this.stars,
    required this.headline,
    required this.body,
    required this.helpful,
  });

  final String id;
  final String author;

  /// What they bought, such as `256 GB`.
  final String variant;
  final DateTime date;
  final int stars;
  final String headline;
  final String body;

  /// How many found it helpful.
  final int helpful;

  /// `AK` for Ahmed K.
  String get initials => author
      .split(' ')
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

/// The ratings, a few reviews and how many there are.
@immutable
final class Reviews {
  const Reviews({
    required this.shares,
    required this.mentions,
    required this.top,
    required this.total,
  });

  /// The percentage of ratings with five stars, then four, down to one.
  final List<int> shares;
  final List<ReviewMention> mentions;
  final List<Review> top;

  /// How many written reviews there are.
  final int total;
}

enum AnswerBy { seller, buyer }

/// A question someone asked, with its best answer.
@immutable
final class ProductQuestion {
  const ProductQuestion({
    required this.question,
    required this.answer,
    required this.answeredBy,
    required this.by,
    required this.helpful,
  });

  final String question;
  final String answer;

  /// Who answered, such as `Nova Official Store`.
  final String answeredBy;
  final AnswerBy by;
  final int helpful;
}

/// A few questions and how many there are.
@immutable
final class Questions {
  const Questions({required this.top, required this.total});

  final List<ProductQuestion> top;
  final int total;
}
