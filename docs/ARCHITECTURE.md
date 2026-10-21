# Architecture

The apps use an MVVM architecture with Riverpod, refined on an earlier
production Flutter app: a shared `core` (state, errors, network, storage,
config, presentation helpers, theme), features split into `data`, `domain`
and `presentation`, one ViewModel pattern built on `ViewState` and
`SubmissionState`, throwing providers bound by overrides at startup, Navigator
1.0, and a quality gate that enforces the rules. `CLAUDE.md` is the rulebook;
this file records how the layout fits two apps and where it differs from
that single-app reference.

## Workspace

```
apps/customer   apps/rider      app/ + features/ + routing/ + config/ + main*.dart
packages/core                   the reference's lib/core/ and lib/vendor/
tool/  test/tool/               the reference's tool/ and its tests, run from the root
```

A Dart pub workspace resolves everything against one `pubspec.lock`; Melos 7
runs scripts across packages. Each app depends only on `core`.

## Differences from the single-app reference

1. **Two apps in one workspace.** The reference is one app with `lib/core/`;
   here `core` is its own package so both apps share one copy. The gate tools
   read the workspace from the root `pubspec.yaml` and apply the same rules
   per package (a package with `lib/app/` is an app).
2. **Shared app-layer code lives in `core`.** Start-up (`startApp`, the
   global error handlers, the root `ProviderScope`), the root widget
   (`AppShell`), `ErrorFallback`, `StartupFailureApp`, `NotFoundView` and the
   route transitions sit in `core`, because identical copies in both apps
   would fail the duplicate check. Each app keeps only what differs: its
   features, routes and name.
3. **Routes per app.** Route constants live in each app's
   `routing/app_routes.dart`; `core/lib/routing/app_routes.dart` keeps only
   `rootNavigatorKey`.
4. **Dark mode.** Every Tekvo screen has a dark version, so colour roles are
   not static constants: Material roles come from the light and dark
   `ColorScheme`s, and the Tekvo roles (status, commerce, rider, map) from the
   `AppColors` theme extension, read with `context.appColors`.
5. **Theme generated from Figma.** `tool/figma/export_tokens.js` exports the
   variables, text styles and effect styles to
   `packages/core/tokens/tekvo_tokens.json`; `tool/generate_tokens.dart`
   writes `AppPalette`, the colour schemes, `AppColors`, `AppSpacing`,
   `AppRadius`, `AppSizes`, `AppMotion`, `AppShadows` and the `AppTypeScale`
   text styles. The class names follow the reference; the values are
   Tekvo's. The gate fails when the generated files drift from the JSON.
6. **Tokens are enforced in app code.** App code may not use colour literals,
   `Colors.*` or hand-built `TextStyle`s; the theme is the only source.
7. **Localization split.** Shared strings (errors, retry, offline banner,
   start-up failure) are `CoreLocalizations` in `core`, read with
   `context.coreL10n`; each app adds its own `AppLocalizations` with its
   first screen. English and Arabic files stay in step through
   `test/l10n/arb_test.dart`.
8. **App title per app.** `EnvConfig` holds no app name; each app passes its
   name to `AppEnvironment.appTitle`, which adds the flavour suffix.
9. **Git identity.** `irshadio <irshad.kp@icloud.com>`.

## Data

There is no Tekvo API yet. Features declare their repository contracts as
the architecture requires and bind stand-in repositories that serve the
design's sample data, so a real API replaces them without touching screens.
