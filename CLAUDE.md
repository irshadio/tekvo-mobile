# CLAUDE.md — Tekvo mobile

Flutter apps for **Tekvo**, an electronics e-commerce platform: the customer
app and the rider (delivery staff) app, in one Melos workspace. Packages:
**`core`** (shared), **`customer`**, **`rider`**.

The apps follow the MVVM architecture described in this file. When something
is not covered here, follow the shapes already in `packages/core/` and the
existing features rather than inventing a pattern. Designs come from the
Tekvo Figma file; every screen has a light and a dark version.

---

## 0. Golden rules (read first)

1. **Run codegen before anything else.** `melos run gen` (and `melos run l10n`).
   Missing `*.g.dart` / `*.freezed.dart` / l10n files are EXPECTED before
   codegen — they are git-ignored, not errors. Re-run after editing any
   annotated file or ARB.
2. **Never `setState`.** State belongs to a ViewModel. `StatefulWidget` is fine
   for lifecycle (`initState`, controllers, tickers) — `setState` is not the
   state mechanism (vendored code excepted).
3. **One ViewModel pattern only** (§4), one display-state type
   (`ViewState<T>`), one write-state type (`SubmissionState<T>`).
4. **Every contract is an `abstract interface class` + an `Impl`**, wired by a
   `ProviderScope` override at startup — never `new`-ed directly (§5).
5. **Pattern-match with Dart 3 `switch`, never `.when` / `.map`.**
6. **`remote_client` types (`rc.*`) never leave `data/`** (core/app excepted).
   The remote data source maps them via `mapRemoteFailure` (§6).
7. **The feature folder/file layout is MANDATORY** (§3).
8. **Colours, text styles and sizes come from the theme** (§6, design system).
9. **Security baseline applies to every change** (§8).
10. **Every file ≤ 500 lines** (§9).
11. **Name only this project** in tracked files (§10).
12. **The gate must pass before every commit** (§9).

---

## 1. Workspace

```
apps/customer/      Customer app (com.tekvo.customer).
apps/rider/         Rider app (com.tekvo.rider).
packages/core/      Shared infrastructure, theme, localization, vendored code.
tool/               The quality gate and generators (run from the root).
test/tool/          Tests for tool/.
docs/               Tracked project docs.
local_dev/          Local, untracked reference material and notes (git-ignored).
```

Dart pub workspace (one root `pubspec.lock`) driven by Melos 7. Install Melos
once: `dart pub global activate melos 7.8.0`.

---

## 2. Commands

```bash
flutter pub get                      # resolve the whole workspace
melos run gen                        # build_runner in every package (RUN FIRST)
melos run l10n                       # flutter gen-l10n in every package with l10n.yaml
melos run tokens                     # regenerate core/theme from the Figma tokens
melos run assets                     # regenerate Assets after changing core/assets/
melos run format                     # format hand-written files (never vendor/)
melos run test                       # flutter test in every package
melos run gate                       # the full gate (dart run tool/gate.dart)
```

Individual checks run from the root: `dart run tool/check_boundaries.dart`,
`check_loc`, `check_structure`, `check_branding`, `check_layout`,
`check_duplicates`. The `tool/` scripts are the quality gate; keep them passing
and extend them when a new rule needs enforcing.

`packages/core/.env` is required for `envied` codegen and is untracked: copy
`.env.example` to `.env` and fill it in.

> **Gotcha:** `envied` does not track `.env` as a build input. After editing
> it, run `dart run build_runner clean` in `packages/core` before `build`, or
> the old value stays baked into the generated config.

---

## 3. Layers, import boundaries & mandatory layout

```
packages/core/lib/       Generic infrastructure. MUST NOT import an app.
  assets/                assets.gen.dart: generated `Assets` path constants.
  bootstrap/             buildCoreOverrides(), startApp(), error handlers.
  config/                envied AppConfig + AppEnvironment/EnvConfig (flavours).
  error/                 Failure union, failure_mapper, ErrorReporter.
  l10n/                  Shared strings (CoreLocalizations, English + Arabic).
  logging/               AppLogger (never `print`).
  network/               remote client provider, token/unauthorized, connectivity.
  presentation/          ViewStateSwitcher, ViewReadyMixin, extensions, widgets
                         (AppShell, DesignScale, OfflineBanner, state views).
  routing/               rootNavigatorKey, route transitions.
  state/                 ViewState, SubmissionState, the two state mixins.
  storage/               SecureStore (tokens), LocalStore (sembast).
  theme/                 Generated tokens (AppPalette, AppColors, AppSpacing,
                         AppRadius, AppSizes, AppMotion, AppShadows,
                         AppTypeScale) + AppTheme, AppFonts, AppSystemBars.
  utils/                 Pure helpers.
  vendor/                Vendored third-party source. A LEAF. Not linted.
                         Each package has a VENDOR.md.
apps/<app>/lib/
  main.dart              Default entrypoint (+ main_dev/qa/uat/prod.dart, §7).
  app/                   Top layer. MAY import anything.
    run_app.dart         Composition root: feature overrides, user-data stores.
    app.dart             Root widget (AppShell with this app's routes).
    route_generator.dart Route names -> feature views.
  config/                App identity (name before the flavour suffix).
  routing/app_routes.dart Route constants.
  features/<name>/       One feature. MUST NOT import another feature, or app/.
```

**Import boundaries** (`tool/check_boundaries.dart`):

- `core` may not import an app; an app may not import another app.
- `features/A/**` may not import `features/B/**`, nor `app/**`.
- Within a feature: `domain/` imports neither `data/` nor `presentation/`;
  `data/` does not import `presentation/`.
- `vendor/**` may import only `vendor/**`.
- `rc.*` only in `core`, `app/**`, or a feature's `data/`.
- `$Notifier` only in `core/lib/state/` (§4).
- App code uses no colour literals, `Colors.*` (other than transparent),
  `TextStyle(`, `fontSize:`, `fontWeight:` or `fontFamily:` (§6).
- Use `package:` imports, never relative (vendored code excepted).
- Editing anything under `core/lib/vendor/**` must be recorded in that
  package's `VENDOR.md`.

**Mandatory feature layout** (`tool/check_structure.dart`). Every feature uses
this layout **exactly** — no other directories or file suffixes:

```
apps/<app>/lib/features/<name>/
  <name>_overrides.dart          List<Override> binding this feature's contracts.
                                 The only file allowed at the feature root.
                                 REQUIRED once the feature has a repository.
  domain/
    entities/<x>.dart            @freezed entities. No JSON, no wire types.
    repositories/<x>_repository.dart
                                 abstract interface class + throwing @riverpod provider.
  data/
    dtos/<x>_dto.dart            @freezed + fromJson + a toEntity() extension.
    sources/<x>_remote_data_source.dart
                                 abstract + Impl(rc.RemoteClient) + throwing provider.
    sources/<x>_local_data_source.dart      (only if the feature caches)
    repositories/<x>_repository_impl.dart   DTO -> entity, cache/offline logic.
  presentation/
    view/<x>_view.dart           Screens end in _view.dart.
    view/widgets/                Widgets private to this feature.
    view_model/<x>_view_model.dart
```

- ❌ No ad-hoc state classes standing in for `ViewState` / `SubmissionState`. A
  ViewModel that fetches or submits MUST use the mixin pair. Only a notifier
  for **local, ephemeral UI** (a selected index) that touches no repository may
  hold a custom state class — and it still lives in `view_model/`.
- ❌ No repository, DTO or data source outside `data/`.
- ❌ No business logic in `view/`. Views hold controllers and keys; everything
  else is a notifier method.
- A **presentation-only** feature (static screen, no data) may omit `data/`
  and `domain/`, but must still use `presentation/view/`.
- ❌ **No fixtures or `Future.delayed` stand-ins inside a ViewModel.** Until the
  Tekvo API exists, declare the repository contract, put the stand-in (the
  design's sample data) in `data/repositories/`, and bind it in
  `<name>_overrides.dart`. A ViewModel whose request runs against a **core**
  contract instead opts out with a `// check_structure: no-repository —
  <reason>` line.

---

## 4. State & the ViewModel pattern

**Reads:** `ViewState<T>` — `idle` / `loading(previous)` / `data` /
`error(failure, previous)` / `noInternet(previous)`. `previous` makes a refresh
non-destructive. Render with `ViewStateSwitcher<T>`; read current data with
`state.dataOrNull`. Do **not** use `AsyncValue` for screen state.

```dart
@riverpod
class FooViewModel extends _$FooViewModel with RemoteStateMixin<List<Foo>> {
  @override
  ViewState<List<Foo>> build() => const ViewState.idle();

  Future<void> load() =>
      runRequest(() => ref.read(fooRepositoryProvider).getFoos());
}
```

Views are `ConsumerStatefulWidget` + `ViewReadyMixin`, trigger the first load
in `onReady()`, and MUST call once in `build`:

```dart
ref.listenRefreshFailures(fooViewModelProvider, context);
```

When state feeds a widget directly instead of a `ViewStateSwitcher`, also pass
`includeFirstLoad: true`, or the first failure is silent.

**Writes:** `SubmissionState<T>` (`idle` / `inProgress` / `success` /
`failure`) + `MutationStateMixin` (`runMutation`) + `ref.listenSubmission`.
Form fields and controllers live in the View; the ViewModel tracks only the
submission. Disable submit while `state.isInProgress`.

View utilities come from **`BuildContext` extensions** (`context.colors`,
`context.appColors`, `context.textTheme`, `context.showSnackBar`,
`context.pushNamed`), never a `BaseView` superclass.

> **`$Notifier` quarantine.** The two state mixins are declared
> `on $Notifier<...>`, a `riverpod_generator` internal. Only
> `core/lib/state/remote_state_mixin.dart` and
> `core/lib/state/mutation_state_mixin.dart` may name it. After any Riverpod
> bump, run the two guard tests in `packages/core/test/state/`.

---

## 5. Dependency injection

Contract (`abstract interface class`) + a `@riverpod` provider that **throws**,
bound to its `Impl` by an override at startup:

- Core contracts (`AppLogger`, `ErrorReporter`, `SecureStore`, `LocalStore`,
  `RemoteClient`, `TokenProvider`, `UnauthorizedHandler`,
  `ConnectivityService`) are bound in `core/lib/bootstrap/bootstrap.dart`.
- Each feature exposes `<name>_overrides.dart`; an app aggregates its features
  in `app/run_app.dart` (passed to `startApp`).
- `Override` comes from `riverpod_annotation`, not `flutter_riverpod`.
- Override closures compose other contracts via `ref.watch(otherProvider)`.

---

## 6. Errors, network, storage & the design system

- `Failure` (`core/lib/error/failure.dart`) is the app-wide sealed error
  vocabulary; every case carries `message`. Users see
  `context.failureMessage(failure)`.
- Repositories / data sources return `Future<Either<Failure, T>>` (fpdart).
- The **remote data source** is the only place that sees `rc.*`: it calls
  `mapRemoteFailure(...)` and unwraps the response. The **repository** maps
  DTO → entity and owns cache / offline fallback.
- HTTP: the single `remoteClientProvider`. Tokens: `SecureStore`
  (`flutter_secure_storage`). Cache: `LocalStore` (sembast). Logs: `AppLogger`,
  never `print`. Crashes: `ErrorReporter`, wired in `startApp`.
- Routing is Navigator 1.0: route names in each app's
  `routing/app_routes.dart` (never hard-coded strings), mapped in
  `app/route_generator.dart`; transitions from `core/lib/routing/`.

### Design system

- The theme is generated from the Figma variables, text styles and effect
  styles: `tool/figma/export_tokens.js` (run with figmcp's `use_figma` in the
  Tekvo file) writes `packages/core/tokens/tekvo_tokens.json`; `melos run
  tokens` regenerates `packages/core/lib/theme/`. Never edit a generated token
  file; the gate fails when they drift from the JSON.
- Colours: Material roles from `context.colors`, Tekvo roles (status,
  commerce, rider, map) from `context.appColors`. Both have light and dark
  sets. `AppPalette` primitives are for the theme only.
- Text: the Figma type scale through `context.textTheme` (`bodySmall`,
  `titleMedium`, ...). Never build a `TextStyle` in an app.
- Spacing, radii, sizes and durations: `AppSpacing`, `AppRadius`, `AppSizes`,
  `AppMotion`.

### Assets and sizing

- Asset paths come only from `Assets` (`core/lib/assets/assets.gen.dart`),
  never a string literal. After adding, renaming or removing any file under
  `packages/core/assets/`, declare it in `packages/core/pubspec.yaml` and run
  `melos run assets`; commit the regenerated file. Icons come from the Tekvo
  icon set in Figma, never redrawn.
- Sizes scale to the 393 x 852 design with `flutter_screenutil`: `.w`
  horizontal, `.h` vertical, `.r` radii and square sizes, `.sp` text. Do not
  scale the 48 px minimum tap target, durations or ratios. Every app root is
  wrapped in `DesignScale` (through `AppShell`); build the theme inside it
  (`.sp` throws before it initialises), and wrap test apps in it too.

### Localization

- Shared strings (errors, retry, offline banner, start-up failure) live in
  `core/lib/l10n/arb/core_*.arb` (`context.coreL10n`); each app keeps its own
  ARBs for its screens. English is the template; every key has an
  `@description`. Arabic files hold the same keys and placeholders (English
  copies until translated) — `test/l10n/arb_test.dart` keeps them in step.
  Layouts must be RTL-safe (`check_layout`).

---

## 7. Flavours (dev / qa / uat / prod)

| Flavour | Entrypoint | `APP_ENV` | App ID suffix |
|---|---|---|---|
| dev | `lib/main_dev.dart` | `dev` | `.dev` |
| qa | `lib/main_qa.dart` | `qa` | `.qa` |
| uat | `lib/main_uat.dart` | `uat` | `.uat` |
| prod | `lib/main_prod.dart` | `prod` | — |

- `lib/main.dart` is a flavour-less default resolving `APP_ENV` (default `dev`).
- Each entrypoint calls its app's composition root in `app/run_app.dart`.
- Per-flavour values live in `AppEnvironment` / `EnvConfig`
  (`core/lib/config/`). Each flavour has its **own** API base URL and
  credentials; never reuse prod credentials or prod data in dev/qa/uat.
- Android: `productFlavors` in `android/app/build.gradle.kts` (dimension
  `env`). iOS: `Debug-/Release-/Profile-<flavour>` configurations and one
  shared scheme per flavour.

```bash
cd apps/customer
flutter run --flavor dev -t lib/main_dev.dart --dart-define=APP_ENV=dev
```

Full detail: `docs/FLAVORS.md`. VS Code: `.vscode/launch.json` has every app ×
flavour × mode.

---

## 8. Security baseline (mandatory)

OWASP Top 10, OWASP API Security Top 10 and OWASP MASVS are the minimum
reference. Rules that apply to these apps:

**Secrets & environments**
- Never hard-code or commit API keys, private keys, backend secrets or
  credentials. The apps must never hold backend/server secrets at all.
- Client-side config that must ship uses `envied` with `obfuscate: true`;
  `.env*` files stay untracked.
- Separate dev / qa / uat / prod configuration and credentials (§7).

**Tokens & sessions**
- Store tokens only in `SecureStore`. Never in `LocalStore`, shared
  preferences, logs, or URLs / query strings.
- Clear tokens and cached user data on logout and on `401` (via
  `UnauthorizedHandler`). Support refresh-token rotation where the API does.

**Transport**
- HTTPS only (`requireHttpsUrl`). Never disable or bypass certificate
  verification, even to work around an integration problem.

**Errors & logging**
- Show users localized failure messages — never raw exceptions, stack traces,
  server errors, file paths or endpoints.
- Never log passwords, OTPs, full tokens, card data or unnecessary personal
  data. Use `AppLogger` only.

**Input, business logic & data**
- Validate input (type, length, range, format) with allow-lists — for UX only.
  The server is the authority; never rely on client-side checks for security.
- Never make security or pricing decisions on the client (prices, quantities,
  coupons, delivery fees, roles, permissions, workflow state, cash amounts).
  Hiding a button is not authorization.
- File uploads (rider documents, proof of delivery): check type, size and name
  before sending; never trust filenames for paths.
- Request, cache and persist only the data the screen genuinely needs.
- Prevent duplicate submits (`SubmissionState.isInProgress`) for OTP, payment,
  cash collection and other abuse-sensitive actions.

**Dependencies & review**
- Add only well-known, maintained packages; remove unused ones; keep
  `pubspec.lock` committed. Do not install unknown or untrusted packages.
- Review every change for: auth bypass, insecure storage, hard-coded secrets,
  unsafe file handling, sensitive logging, and trusting client-side state.

**Mindset** — before implementing a feature, ask: *what if the user modifies
the request, changes an ID, bypasses the UI, repeats the request 10,000
times, sends unexpected input, or calls the API directly?* Raise backend-side
gaps as questions to the owner rather than patching around them in the app.

---

## 9. Quality gates (before every commit)

`melos run gate` (`dart run tool/gate.dart`) runs, in order, stopping at the
first failure:

1. `generate_assets --check` (`Assets` current and used) and
   `generate_tokens --check` (theme matches the Figma tokens).
2. `build_runner build` in every package (codegen current).
3. Format check (`melos run format` writes; never `dart format .`: that
   rewrites `vendor/`).
4. `flutter gen-l10n` in every package with an `l10n.yaml`.
5. `flutter analyze` in every package and `dart analyze tool test/tool` →
   **No issues found** (very_good_analysis).
6. `check_boundaries` → OK.
7. `check_loc` → every hand-written Dart file in `lib/` and `test/` is
   **≤ 500 lines**. Generated and vendored files are exempt.
8. `check_structure` → OK.
9. `check_branding` → OK.
10. `check_layout` → OK. `rtl-*` and `semantics-gesture` apply to app code;
    an existing site is allow-listed with its reason:
    - `image-network`: `Image.network(` outside `AppNetworkImage`.
    - `media-query-of`: `MediaQuery.of(`; read one aspect (`sizeOf`, ...).
    - `modal-sheet`: `showModalBottomSheet(` outside `showAppSheet`.
    - `semantics-gesture`: `Semantics(button: true)` over a bare `GestureDetector`.
    - `rtl-text-align`: `TextAlign.left` / `.right`.
    - `rtl-positioned`: one-sided `Positioned(left:/right:)`.
    - `rtl-edge-insets`: one-sided `EdgeInsets.only(left:/right:)`.
    - `rtl-edge-insets-ltrb`: `EdgeInsets.fromLTRB(` whose left and right differ.
    - `format-cache`: `DateFormat` / `NumberFormat` built outside `FormatCache`.
11. `check_duplicates` → OK: no top-level class name or 20+ identical lines
    shared between two features or apps; shared code belongs in `core`, and an
    intentional case is allow-listed with its reason.
12. `flutter test` in every package and `dart test test/tool` green.

CI (`.github/workflows/ci.yml`) runs the same gate on every push and pull
request.

---

## 10. Branding

Tracked files (code, comments, docs, file names and commit messages) name only
this project. Say what a thing is for, not where it came from.

- `tool/check_branding.dart` enforces a list of forbidden words, stored as
  **hashes** so the checker never spells them out. Add one with
  `dart run tool/check_branding.dart --hash <word>` and a comment saying what
  the word is, never what it says.
- `local_dev/` is git-ignored and not scanned.

---

## 11. Documentation

| Doc type | Location |
|---|---|
| Implementation notes, guides, plans, investigations, working docs | `local_dev/notes/` |
| Project docs valid for tracking and pushing (architecture, flavours, API contracts) | `docs/` |

Do not create development docs anywhere else.

---

## 12. Adding a feature (runbook)

1. `domain/entities/<x>.dart` — `@freezed` entity.
2. `domain/repositories/<x>_repository.dart` — contract + throwing provider.
3. `data/dtos/<x>_dto.dart` — `@freezed` + `fromJson` + `toEntity()`.
4. `data/sources/<x>_remote_data_source.dart` — confines `rc.*`.
5. `data/sources/<x>_local_data_source.dart` — only if caching.
6. `data/repositories/<x>_repository_impl.dart` — DTO → entity (or the
   stand-in serving the design's data until the API exists).
7. `presentation/view_model/<x>_view_model.dart` — §4.
8. `presentation/view/<x>_view.dart` — `ViewReadyMixin` + `ViewStateSwitcher`,
   built from the Figma frame in light and dark, using only theme tokens.
9. `<x>_overrides.dart` — bind every contract.
10. Wire into the app's `app/run_app.dart`, `app/route_generator.dart` and
    `routing/app_routes.dart`; add its strings to the app's ARBs.
11. Check the feature against §8.
12. `melos run gate`.

---

## 13. Git

Commit rules: short conventional messages (`feat(customer): add cart`), one
logical change per commit, no co-author trailers. Never commit generated files
(`*.g.dart`, `*.freezed.dart`, l10n output) or `local_dev/`
(`assets.gen.dart` and the generated theme tokens are the exception: they are
tracked); a commit must pass the gate (§9). Author:
`irshadio <irshad.kp@icloud.com>`. Ask the owner before pushing.

---

## 14. Do NOT

- ❌ `setState`.
- ❌ `.when` / `.map` / `.maybeWhen` — use `switch`.
- ❌ `AsyncValue` screen state, `go_router`, `dartz`, or a `usecase/` layer.
- ❌ Name `$Notifier` outside `core/lib/state/`.
- ❌ Let `rc.*` appear outside `data/` (core/app excepted).
- ❌ Construct an `Impl` directly in a feature — bind it via an override.
- ❌ Import one feature from another, an app from core, or one app from another.
- ❌ Relative imports (vendored code excepted).
- ❌ Fixtures or fake `Future.delayed` requests inside a ViewModel.
- ❌ Edit `vendor/**` without recording it in its `VENDOR.md`.
- ❌ Colour literals, `Colors.*`, or hand-built `TextStyle`s in app code.
- ❌ Edit generated theme tokens by hand — change Figma and re-export.
- ❌ Name anything but this project in tracked files (§10).
- ❌ Hard-code secrets, log tokens, or disable certificate checks (§8).
- ❌ Files over 500 lines.
- ❌ Asset path strings — use the generated `Assets`.
- ❌ Commit with a failing gate.
