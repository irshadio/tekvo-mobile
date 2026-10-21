import 'package:core/assets/assets.gen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bundled font families (see `packages/core/pubspec.yaml`).
abstract final class AppFonts {
  static const String inter = 'Inter';

  static const Map<String, String> _licenses = <String, String>{
    inter: Assets.interOfl,
  };

  /// Adds the fonts' licences to the app's licence page, as the OFL requires.
  static void registerLicenses() {
    LicenseRegistry.addLicense(() async* {
      for (final MapEntry(key: family, value: path) in _licenses.entries) {
        yield LicenseEntryWithLineBreaks(<String>[
          family,
        ], await rootBundle.loadString(path));
      }
    });
  }
}
