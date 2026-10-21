import 'package:core/vendor/remote_client/remote_client.dart' as rc;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_client_provider.g.dart';

/// The single configured client. Every remote data source depends on it; no
/// feature builds its own. Wired in `core/bootstrap`.
@Riverpod(keepAlive: true)
rc.RemoteClient remoteClient(Ref ref) => throw UnimplementedError(
  'remoteClientProvider must be overridden in ProviderScope (core/bootstrap).',
);
