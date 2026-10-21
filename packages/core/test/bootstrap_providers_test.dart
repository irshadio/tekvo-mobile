import 'package:core/network/remote_client_provider.dart';
import 'package:core/vendor/remote_client/remote_client.dart' as rc;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

void main() {
  test('core contracts are built once and kept alive', () async {
    var builds = 0;
    final container = ProviderContainer(
      overrides: <Override>[
        remoteClientProvider.overrideWith((ref) {
          builds++;
          return rc.RemoteClientFactory.create(
            baseUrl: 'https://api.example.test',
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    final first = container.read(remoteClientProvider);
    await Future<void>.delayed(Duration.zero);
    final second = container.read(remoteClientProvider);

    expect(identical(first, second), isTrue);
    expect(builds, 1);
  });
}
