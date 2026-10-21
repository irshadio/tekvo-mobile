import 'package:core/assets/assets.gen.dart';
import 'package:customer/l10n/generated/app_localizations.dart';

/// One chip floating over a slide's photo.
typedef OnboardingChip = ({
  String icon,
  String Function(AppLocalizations) label,
});

/// The three introduction pages, in order.
enum OnboardingSlide {
  genuine(
    image: Assets.onboardingGenuine,
    leading: (icon: Assets.chipShield, label: _genuineWarranty),
    trailing: (icon: Assets.chipCheck, label: _genuineAuthentic),
  ),
  fast(
    image: Assets.onboardingFast,
    leading: (icon: Assets.chipTruck, label: _fastToday),
    trailing: (icon: Assets.chipPin, label: _fastTracking),
  ),
  pay(
    image: Assets.onboardingPay,
    leading: (icon: Assets.chipCard, label: _payInstalments),
    trailing: (icon: Assets.chipGift, label: _payRewards),
  );

  const OnboardingSlide({
    required this.image,
    required this.leading,
    required this.trailing,
  });

  final String image;

  /// The chip at the photo's top start.
  final OnboardingChip leading;

  /// The chip at the photo's bottom end.
  final OnboardingChip trailing;

  String kicker(AppLocalizations l10n) => switch (this) {
    genuine => l10n.onboardingGenuineKicker,
    fast => l10n.onboardingFastKicker,
    pay => l10n.onboardingPayKicker,
  };

  String title(AppLocalizations l10n) => switch (this) {
    genuine => l10n.onboardingGenuineTitle,
    fast => l10n.onboardingFastTitle,
    pay => l10n.onboardingPayTitle,
  };

  String body(AppLocalizations l10n) => switch (this) {
    genuine => l10n.onboardingGenuineBody,
    fast => l10n.onboardingFastBody,
    pay => l10n.onboardingPayBody,
  };
}

String _genuineWarranty(AppLocalizations l) => l.onboardingGenuineChipWarranty;
String _genuineAuthentic(AppLocalizations l) =>
    l.onboardingGenuineChipAuthentic;
String _fastToday(AppLocalizations l) => l.onboardingFastChipToday;
String _fastTracking(AppLocalizations l) => l.onboardingFastChipTracking;
String _payInstalments(AppLocalizations l) => l.onboardingPayChipInstalments;
String _payRewards(AppLocalizations l) => l.onboardingPayChipRewards;
