# Vendored: `remote_client`

| | |
|---|---|
| Upstream | https://github.com/0xIrshad/remote-client |
| pub.dev | https://pub.dev/packages/remote_client |
| Version | **1.0.1** |
| Source archive | `https://pub.dev/api/archives/remote_client-1.0.1.tar.gz` |
| Vendored on | 2026-09-24 |
| Imported as | `package:core/vendor/remote_client/remote_client.dart` |

## Rules

- A **leaf**: nothing here imports app code (`tool/check_boundaries.dart`
  enforces it). Internal imports are relative.
- **Not linted, formatted or LOC-checked** (`lib/vendor/**` is excluded from
  analysis, and the gate never formats it). Format with
  `dart run tool/format.dart`, never `dart format lib`: that rewrites this
  tree, an unrecorded modification.
- The upstream `pubspec.yaml` and `analysis_options.yaml` are dropped. Its
  dependency is declared in the `packages/core/pubspec.yaml` (`dio`).
- `LICENSE` is kept (license obligation). `README.md` / `CHANGELOG.md` are
  upstream's; their examples use the upstream `package:remote_client/...` URI.
- **Any edit here must be recorded below.**

## Local modifications

The tree is not byte-identical to upstream 1.0.1. On upgrade, diff, do not
overwrite, or these are lost.

1. **Self-imports made relative.** `package:remote_client/<p>` became a path
   relative to the importing file, because the package identity is gone.
2. **dio 5.11 `DioExceptionType.transformTimeout` handled.** Upstream's two
   exhaustive switches do not compile against dio 5.11.
   `retry_interceptor.dart` treats it as a timeout (`retryOnTimeout`);
   `error_handler_impl.dart` maps it to `ReceiveTimeout` (a new `Failure`
   subtype would break exhaustive consumer switches on the sealed class).
3. **`AuthInterceptor` replays a refreshed request on a separate `Dio`.**
   Upstream replayed through the same `Dio`; `QueuedInterceptor.onError` has a
   single slot, so a replay that was itself rejected with 401 never completed
   and blocked every later 401. The replay now runs on an interceptor-free
   `Dio` (built on the first 401 from the original's options and adapter),
   and a 401 on it calls `handleUnauthorized()` directly. The replayed
   `RequestOptions` already carry the URL, timeouts, headers and cancel token.
   **Lost on the replay:** the response transformation hook, a custom
   transformer, retry and cache. The replay client keeps the adapter it
   captured on the first 401, so install any pinning adapter before the
   first request.
4. **`error_handler_impl.dart`:**
   - `NoInternet` is reachable: dio's IO adapter reports a `SocketException`
     as `connectionError`, which upstream mapped to `ConnectionError`. Both
     `connectionError` and `unknown` now check for a socket failure.
     Accepted imprecision: a refused or unreachable server also raises
     `SocketException`, so it too reads as `NoInternet`.
   - A 2xx whose envelope says `success: false` is a `BadResponse`, not a
     success. Its `message` is the envelope's own or null (no English
     default), so the app can tell server words from its own copy.
   - Failures from `validateResponse` carry the HTTP status on `response`
     (upstream left it null).
5. **`retry_interceptor.dart`, `retry_policy.dart` and the barrel:**
   - `kRetryDeadlineExtraKey`: an optional wall-clock deadline (epoch ms) in
     `RequestOptions.extra`; no retry starts past it.
   - Equal jitter (`delay/2 + random(delay/2)`), capped before jitter.
     Upstream's full jitter could retry almost immediately.
   - `Retry-After` honoured (delta-seconds and IMF-fixdate, via a local
     `HttpDate`); a value above `maxDelayMs` stops retrying.
   - The barrel also exports `cache_interceptor.dart`,
     `deduplication_interceptor.dart` and dio's `FormData`.
6. **Known-inert config left alone.** `NetworkConfig.maxConnectionsPerHost`
   and `enableHttp2` are never read by the factory. Treat them as inert.
7. **Per-request `ResponseParser`.** Every `HttpClient` / `FileClient` method
   takes an optional `parser`, used instead of the client-wide one for an
   endpoint whose body does not use the API envelope. Additive.
8. **`DeduplicationInterceptor`:** `completer.future.ignore()` after creating
   the pending completer, so a failed request nobody joined no longer raises
   an uncaught zone error. A joined duplicate still receives the error.
9. **Formatting.** Several files were reflowed by `dart format` (line
   wrapping only). Verified behaviour-neutral: formatting both this tree and
   upstream makes those differences disappear.
10. **`connectivity_service_impl_io.dart`: host lookups run in parallel.**
   Upstream awaited each lookup inside the loop, so the hosts were checked
   one after another (worst case: hosts x timeout) despite its comment. The
   lookups now start together and the first success answers; `_lookupHost`
   never throws, so nothing is left unhandled.

Tests for 2, 3, 4, 5, 7, 8 and 10: `test/vendor/remote_client/`.

## Known limits (upstream or accepted; not modified)

- **Concurrent 401s refresh once each.** `QueuedInterceptor` runs `onError`
  serially, so the interceptor's shared-completer never shares; nothing checks
  whether the token already changed. The app's `TokenProvider.refreshToken`
  must be single-flight, and `UnauthorizedHandler.handleUnauthorized` must be
  idempotent (it runs once per rejected replay).
- **Deduplication runs before auth on errors.** dio runs error interceptors
  in list order, so a joined duplicate receives a 401 while the original is
  refreshed and succeeds. The comment in `remote_client_factory.dart` saying
  response and error order are reversed is wrong: both run in list order, so
  deduplication also answers a joined duplicate before any response
  transform. Do not enable deduplication together with
  token refresh without handling this.
- **`DioLogger` logs response and error bodies** when enabled (which can hold
  tokens from login / refresh and personal data). Enable it only in debug
  builds of non-prod flavours.
- **`Retry-After` edge values:** a value too large to parse, or one that
  overflows when converted to milliseconds, falls back to the client's own
  backoff; a negative value, or `maxDelayMs` <= 0, retries at
  once; a date-form value is used without jitter.
- **`HttpDate`** is public in the barrel; a file that also imports `dart:io`
  and uses `HttpDate` must hide one of them.
- The barrel exports dio's `src/` paths (`cancel_token`, `form_data`,
  `options`), which dio may move without notice.

## Upgrading

```bash
curl -sL https://pub.dev/api/archives/remote_client-<NEW>.tar.gz | tar xz -C <tmp>
diff -ru <tmp>/lib lib/vendor/remote_client
```

Re-apply every modification above, then:

```bash
grep -rn "package:remote_client" lib/vendor --include='*.dart'   # empty
grep -rn "package:core/" lib/vendor --include='*.dart'      # empty
dart run tool/gate.dart
```
