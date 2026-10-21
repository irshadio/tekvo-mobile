# Tekvo mobile

Flutter apps for Tekvo, an electronics e-commerce platform in the UAE:

- **Customer app** (`apps/customer`, `com.tekvo.customer`): browse, search,
  checkout, delivery or click and collect, tracking, returns, account and
  Tekvo Plus.
- **Rider app** (`apps/rider`, `com.tekvo.rider`): the staff app for
  dispatch-assigned delivery runs, pickups, proof of delivery and cash
  hand-over.

Both are built from the Tekvo Figma designs, in light and dark, on one shared
`core` package.

## Tech stack

- Flutter / Dart 3, Melos 7 with a Dart pub workspace
- Architecture: MVVM with Riverpod (code-generated notifiers)
- Freezed + json_serializable for models, fpdart `Either` for errors
- `envied` for environment config
- `flutter_secure_storage` for tokens, `sembast` for local cache
- `flutter_screenutil` against the 393 x 852 design, Inter
- Theme generated from the Figma variables and text styles
- `very_good_analysis` lints and a custom quality gate

## Getting started

```bash
dart pub global activate melos 7.8.0
cp packages/core/.env.example packages/core/.env
flutter pub get
melos run gen        # generated files are git-ignored; run first
melos run l10n
cd apps/customer
flutter run --flavor dev -t lib/main_dev.dart --dart-define=APP_ENV=dev
```

Or pick an app, flavour and mode in VS Code's Run and Debug panel.

## Flavours

| Flavour | Entrypoint | App ID suffix |
|---|---|---|
| dev | `lib/main_dev.dart` | `.dev` |
| qa | `lib/main_qa.dart` | `.qa` |
| uat | `lib/main_uat.dart` | `.uat` |
| prod | `lib/main_prod.dart` | — |

See `docs/FLAVORS.md`.

## Project structure

```
apps/customer/     Customer app
apps/rider/        Rider app
packages/core/     Shared infrastructure, theme, localization
tool/              Quality gate and generators
docs/              Architecture and flavour docs
```

The rules are in `CLAUDE.md`; the reasoning behind the layout is in
`docs/ARCHITECTURE.md`.

## Quality gate

```bash
melos run gate
```

Runs codegen, formatting, localization, analysis, import boundaries, file
size, feature structure, branding, layout, duplication and every test. It
must pass before every commit, and CI runs it on every push and pull request.
