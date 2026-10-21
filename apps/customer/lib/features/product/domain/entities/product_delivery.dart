import 'package:core/utils/money.dart';
import 'package:flutter/foundation.dart';

enum DeliverySpeed { standard, express }

/// A way the order can arrive.
@immutable
final class DeliveryOption {
  const DeliveryOption({
    required this.speed,
    required this.title,
    required this.detail,
    this.highlight,
  });

  final DeliverySpeed speed;

  /// Drawn before [title] in the brand colour, such as `FREE delivery`.
  final String? highlight;

  /// Such as `tomorrow, 21 Oct`.
  final String title;

  /// Such as `Order within 3 h 12 min`.
  final String detail;
}

/// Where and how the order arrives, and who sells it.
@immutable
final class Delivery {
  const Delivery({
    required this.recipient,
    required this.place,
    required this.options,
    required this.returnDays,
    required this.warrantyYears,
    required this.seller,
    required this.fulfiller,
  });

  final String recipient;

  /// Such as `Dubai Marina, Dubai`.
  final String place;
  final List<DeliveryOption> options;
  final int returnDays;
  final int warrantyYears;
  final String seller;
  final String fulfiller;
}

/// Cover bought with the product.
@immutable
final class ProtectionPlan {
  const ProtectionPlan({
    required this.id,
    required this.title,
    required this.detail,
    required this.price,
  });

  final String id;

  /// Such as `Care+ Accidental damage · 1 year`.
  final String title;
  final String detail;

  final Money price;
}
