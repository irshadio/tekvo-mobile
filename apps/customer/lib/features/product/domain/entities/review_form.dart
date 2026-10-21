import 'package:flutter/foundation.dart';

/// What the review form needs to know about the purchase being reviewed.
@immutable
final class ReviewForm {
  const ReviewForm({
    required this.productId,
    required this.name,
    required this.purchase,
    required this.image,
    required this.author,
    required this.likes,
    required this.maxLength,
    required this.maxPhotos,
    required this.rewardPoints,
  });

  final String productId;
  final String name;

  /// Such as `Delivered 16 Oct · #TK-19876`.
  final String purchase;

  /// A bundled image key from `Assets`.
  final String image;

  /// The name the review is posted under, such as `Sam R.`.
  final String author;

  /// What a buyer can say they liked, such as `Battery life`.
  final List<String> likes;
  final int maxLength;
  final int maxPhotos;

  /// Tekvo Rewards points the review earns once it is live.
  final int rewardPoints;
}

/// A review as the buyer is writing it.
@immutable
final class ReviewDraft {
  const ReviewDraft({
    this.stars = 0,
    this.liked = const <String>{},
    this.headline = '',
    this.body = '',
    this.photos = const <String>[],
    this.showName = true,
  });

  final int stars;
  final Set<String> liked;
  final String headline;
  final String body;

  /// Picked photos, as file paths.
  final List<String> photos;
  final bool showName;

  /// A review needs stars and some words.
  bool get ready => stars > 0 && body.trim().isNotEmpty;

  ReviewDraft copyWith({
    int? stars,
    Set<String>? liked,
    String? headline,
    String? body,
    List<String>? photos,
    bool? showName,
  }) => ReviewDraft(
    stars: stars ?? this.stars,
    liked: liked ?? this.liked,
    headline: headline ?? this.headline,
    body: body ?? this.body,
    photos: photos ?? this.photos,
    showName: showName ?? this.showName,
  );
}

/// Another purchase waiting for a review.
@immutable
final class ReviewPrompt {
  const ReviewPrompt({
    required this.productId,
    required this.name,
    required this.image,
  });

  final String productId;
  final String name;

  /// A bundled image key from `Assets`.
  final String image;
}

/// What the store says once a review is sent.
@immutable
final class ReviewReceipt {
  const ReviewReceipt({required this.rewardPoints, this.next});

  final int rewardPoints;
  final ReviewPrompt? next;
}
