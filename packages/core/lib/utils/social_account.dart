import 'package:flutter/foundation.dart';

/// A provider a user can sign in with instead of a mobile number.
enum SocialProvider { google, apple }

/// The account a Google or Apple sign-in returned, which fills in the new
/// profile.
@immutable
final class SocialAccount {
  const SocialAccount({
    required this.provider,
    required this.name,
    required this.email,
  });

  final SocialProvider provider;
  final String name;

  /// As the provider shares it; Apple may share a relay address.
  final String email;

  @override
  bool operator ==(Object other) =>
      other is SocialAccount &&
      other.provider == provider &&
      other.name == name &&
      other.email == email;

  @override
  int get hashCode => Object.hash(provider, name, email);
}
