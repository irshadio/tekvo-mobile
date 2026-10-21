# Build flavours

Each app has four flavours, each with its own entrypoint, `AppEnvironment` /
`EnvConfig` (API base URL, log level) and app ID, so all four install side by
side.

| Flavour | Entrypoint | `APP_ENV` | Customer app ID | Rider app ID | Name suffix |
|---|---|---|---|---|---|
| dev | `lib/main_dev.dart` | `dev` | `com.tekvo.customer.dev` | `com.tekvo.rider.dev` | Dev |
| qa | `lib/main_qa.dart` | `qa` | `com.tekvo.customer.qa` | `com.tekvo.rider.qa` | QA |
| uat | `lib/main_uat.dart` | `uat` | `com.tekvo.customer.uat` | `com.tekvo.rider.uat` | UAT |
| prod | `lib/main_prod.dart` | `prod` | `com.tekvo.customer` | `com.tekvo.rider` | — |

`lib/main.dart` is a flavour-less default that resolves `APP_ENV` (default
`dev`). The in-app title is `AppEnvironment.appTitle(appName)`, for example
"Tekvo QA" or "Tekvo Rider".

## Run and build

From an app folder (`apps/customer` or `apps/rider`):

```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define=APP_ENV=dev
flutter run --flavor qa -t lib/main_qa.dart --dart-define=APP_ENV=qa
flutter build apk --flavor prod -t lib/main_prod.dart --dart-define=APP_ENV=prod
flutter build ios --flavor uat -t lib/main_uat.dart --dart-define=APP_ENV=uat --no-codesign
```

Once flavours exist, `flutter run` without `--flavor` is rejected. Use the
`.vscode/launch.json` configurations or always pass `--flavor`. `flutter test`
and `flutter analyze` need no flavour.

## Configuration

- Base URLs: `packages/core/.env` (untracked; copy `.env.example`), keys
  `API_BASE_URL_DEV`, `API_BASE_URL_QA`, `API_BASE_URL_UAT`,
  `API_BASE_URL_PROD`, read by `packages/core/lib/config/app_config.dart`
  (envied, obfuscated). HTTPS only: the apps refuse to start otherwise. After
  editing `.env`, run `dart run build_runner clean` in `packages/core` before
  `build`.
- Never put backend secrets or credentials in `.env`: the values ship inside
  the apps.
- Dev, QA and UAT use their own backends and test data, never prod's.

## Android

`android/app/build.gradle.kts`: `productFlavors` in the `env` dimension, with
`applicationIdSuffix` and `versionNameSuffix`. The launcher name
(`app_name`) is the same for every flavour. Release signing reads
`android/key.properties` (untracked); without it, release builds use the
debug key.

## iOS

- Configurations `Debug-<flavour>`, `Release-<flavour>`, `Profile-<flavour>`
  for each flavour, on the project and both targets, alongside the default
  `Debug` / `Release` / `Profile` (used by the `Runner` scheme).
- Shared schemes `dev`, `qa`, `uat`, `prod`; Flutter maps `--flavor dev` to
  the scheme `dev`.
- Per configuration: `PRODUCT_BUNDLE_IDENTIFIER` and `APP_DISPLAY_NAME` (read
  by `CFBundleDisplayName` in `Info.plist`).
- Each flavour configuration has its own `ios/Flutter/<Config>.xcconfig`,
  including its CocoaPods settings and `Generated.xcconfig`; the `Podfile`
  maps every configuration to debug or release.
- Every flavour uses the app's one icon set. Code signing (team, profiles) is
  not configured.

To add a flavour: add its three configurations (copy the base ones), its
xcconfigs, its `Podfile` entries, a shared scheme with its name, the Android
`productFlavors` entry, an `AppEnvironment` case and its `main_<flavour>.dart`.
