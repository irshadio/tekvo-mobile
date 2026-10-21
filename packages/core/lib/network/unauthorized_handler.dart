import 'package:core/logging/app_logger.dart';
import 'package:core/storage/local_store.dart';
import 'package:core/storage/secure_store.dart';
import 'package:core/vendor/remote_client/remote_client.dart' as rc;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unauthorized_handler.g.dart';

/// Ends the session when a request is rejected as unauthorized: clears the
/// tokens and every store that holds user data.
///
/// Idempotent: concurrent calls share one wipe, and the client calls it once
/// per rejected request. Navigation to sign-in is added with the auth
/// feature.
class AppUnauthorizedHandler implements rc.UnauthorizedHandler {
  AppUnauthorizedHandler({
    required this._secureStore,
    required this._localStore,
    required List<String> userDataStores,
    required this._logger,
  }) : _userDataStores = List<String>.unmodifiable(userDataStores);

  final SecureStore _secureStore;
  final LocalStore _localStore;
  final List<String> _userDataStores;
  final AppLogger _logger;

  Future<void>? _running;

  @override
  Future<void> handleUnauthorized() =>
      _running ??= _endSession().whenComplete(() => _running = null);

  Future<void> _endSession() async {
    _logger.info('Session ended: clearing credentials and user data');
    // Each step runs even if another fails; nothing is thrown back into the
    // client's error path.
    await _attempt('Could not clear credentials', _secureStore.clear);
    for (final store in _userDataStores) {
      await _attempt(
        'Could not clear store "$store"',
        () => _localStore.clear(store),
      );
    }
  }

  Future<void> _attempt(String failure, Future<void> Function() step) async {
    try {
      await step();
    } on Object catch (error, stackTrace) {
      _logger.error(failure, error: error, stackTrace: stackTrace);
    }
  }
}

/// Bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
rc.UnauthorizedHandler unauthorizedHandler(Ref ref) => throw UnimplementedError(
  'unauthorizedHandlerProvider must be overridden in ProviderScope '
  '(core/bootstrap).',
);
