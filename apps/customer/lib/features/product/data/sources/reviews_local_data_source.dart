import 'package:core/assets/assets.gen.dart';
import 'package:customer/features/product/domain/entities/product_reviews.dart';

/// Stand-in until reviews are served: the design's reviews of the Nova X
/// Pro, filtered, sorted and paged here as the server will.
class ReviewsLocalDataSource {
  const ReviewsLocalDataSource();

  static const int pageSize = 4;

  ReviewsPage reviews(
    String id, {
    required ReviewFilter filter,
    required ReviewSort sort,
    required int pages,
  }) {
    final kept = _all.where((review) => _keeps(filter, review)).toList()
      ..sort((a, b) => _compare(sort, a, b));
    final shown = kept.take(pages * pageSize).toList();
    return ReviewsPage(
      product: 'Nova X Pro 5G · 256GB',
      rating: 4.7,
      ratingCount: 2318,
      shares: const <int>[78, 14, 4, 2, 2],
      topics: _topics,
      photos: _photos,
      photoCount: 186,
      withPhotos: 186,
      matching: switch (filter) {
        ReviewFilter.all => 2318,
        ReviewFilter.withPhotos => 186,
        _ => kept.length,
      },
      reviews: shown,
      hasMore: shown.length < kept.length,
    );
  }

  static bool _keeps(ReviewFilter filter, Review review) => switch (filter) {
    ReviewFilter.all => true,
    ReviewFilter.withPhotos => review.photos > 0,
    ReviewFilter.fiveStars => review.stars == 5,
    ReviewFilter.fourStars => review.stars == 4,
    ReviewFilter.threeAndBelow => review.stars <= 3,
    ReviewFilter.verified => review.verified,
  };

  static int _compare(ReviewSort sort, Review a, Review b) => switch (sort) {
    ReviewSort.mostHelpful => b.helpful.compareTo(a.helpful),
    ReviewSort.newest => b.date.compareTo(a.date),
    ReviewSort.highest => b.stars.compareTo(a.stars),
    ReviewSort.lowest => a.stars.compareTo(b.stars),
  };
}

const List<ReviewTopic> _topics = <ReviewTopic>[
  ReviewTopic(label: 'Battery life', count: 412, positive: true),
  ReviewTopic(label: 'Camera', count: 365, positive: true),
  ReviewTopic(label: 'Display', count: 298, positive: true),
  ReviewTopic(label: 'Charging speed', count: 176, positive: true),
  ReviewTopic(label: 'Heats up in games', count: 41, positive: false),
  ReviewTopic(label: 'Price', count: 38, positive: false),
];

const List<String> _photos = <String>[
  Assets.productsNovaXPro,
  Assets.productsNovaSLite,
  Assets.productsNovaXPro,
  Assets.productsNovaSLite,
  Assets.productsNovaXPro,
];

final List<Review> _all = <Review>[
  Review(
    id: 'r-ahmed',
    author: 'Ahmed K.',
    variant: '256 GB',
    date: DateTime.utc(2026, 10, 12),
    stars: 5,
    headline: 'Two days on one charge',
    body:
        'Battery easily lasts two days with heavy use. The camera is sharp '
        'in low light and the screen is bright outdoors.',
    helpful: 24,
    photos: 3,
  ),
  Review(
    id: 'r-priya',
    author: 'Priya N.',
    variant: '512 GB',
    date: DateTime.utc(2026, 10, 8),
    stars: 5,
    headline: 'Fast delivery, great screen',
    body:
        'Arrived next morning in Dubai Marina. Smooth 120 Hz display and the '
        '65 W charger fills it in about 40 minutes.',
    helpful: 17,
  ),
  Review(
    id: 'r-omar',
    author: 'Omar S.',
    variant: '256 GB',
    date: DateTime.utc(2026, 10, 2),
    stars: 4,
    headline: 'Great phone, warm when gaming',
    body:
        'Everything is fast, but it gets warm after 30 minutes of gaming. '
        'Photos are excellent and the build feels premium.',
    helpful: 9,
    photos: 2,
  ),
  Review(
    id: 'r-lina',
    author: 'Lina H.',
    variant: '256 GB',
    date: DateTime.utc(2026, 9, 28),
    stars: 3,
    headline: 'Good, but pricey',
    body:
        'Solid all-rounder. I wish the base model had more storage for the '
        'price, as there is no memory card slot.',
    helpful: 5,
    reply: const SellerReply(
      store: 'Nova Official Store',
      text:
          'Thanks, Lina. The 512 GB model is AED 700 more this week with '
          'code NOVA100.',
    ),
  ),
  Review(
    id: 'r-yusuf',
    author: 'Yusuf A.',
    variant: '512 GB',
    date: DateTime.utc(2026, 9, 24),
    stars: 5,
    headline: 'Best zoom I have used',
    body:
        'The 5× telephoto is sharp even at night. Battery still lasts a full '
        'day of travel with maps and photos.',
    helpful: 4,
    photos: 4,
  ),
  Review(
    id: 'r-meera',
    author: 'Meera P.',
    variant: '256 GB',
    date: DateTime.utc(2026, 9, 19),
    stars: 4,
    headline: 'Lovely screen, heavy in hand',
    body:
        'Colours are accurate and it is easy to read in the sun. It is a '
        'little heavy for one-handed use.',
    helpful: 3,
    verified: false,
  ),
];
