import 'package:flutter/foundation.dart';

/// Which reviews to list.
enum ReviewFilter {
  all,
  withPhotos,
  fiveStars,
  fourStars,
  threeAndBelow,
  verified,
}

/// The order reviews are listed in.
enum ReviewSort { mostHelpful, newest, highest, lowest }

/// A topic reviews mention, such as the battery, and how many do.
@immutable
final class ReviewMention {
  const ReviewMention({required this.label, required this.count, this.filter});

  final String label;
  final int count;

  /// The filter that lists these reviews, when there is one.
  final ReviewFilter? filter;
}

/// Something buyers praise or complain about, summarised from reviews.
@immutable
final class ReviewTopic {
  const ReviewTopic({
    required this.label,
    required this.count,
    required this.positive,
  });

  final String label;
  final int count;
  final bool positive;
}

/// The store's answer to a review.
@immutable
final class SellerReply {
  const SellerReply({required this.store, required this.text});

  final String store;
  final String text;
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
    this.photos = 0,
    this.verified = true,
    this.reply,
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

  /// How many photos the buyer added.
  final int photos;
  final bool verified;
  final SellerReply? reply;

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

/// One page of a product's reviews, with the summary above them.
@immutable
final class ReviewsPage {
  const ReviewsPage({
    required this.product,
    required this.rating,
    required this.ratingCount,
    required this.shares,
    required this.topics,
    required this.photos,
    required this.photoCount,
    required this.withPhotos,
    required this.matching,
    required this.reviews,
    required this.hasMore,
  });

  /// Such as `Nova X Pro 5G · 256GB`.
  final String product;
  final double rating;
  final int ratingCount;

  /// The percentage of ratings with five stars, then four, down to one.
  final List<int> shares;
  final List<ReviewTopic> topics;

  /// The first few buyers' photos, as bundled image keys.
  final List<String> photos;
  final int photoCount;

  /// How many reviews have photos.
  final int withPhotos;

  /// How many reviews the filter keeps.
  final int matching;
  final List<Review> reviews;
  final bool hasMore;
}
