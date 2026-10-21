import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'share_service.g.dart';

/// Opens the system share sheet.
// ignore: one_member_abstracts
abstract interface class ShareService {
  Future<void> shareText(String text, {String? subject});
}

/// [ShareService] over the `share_plus` plugin.
class ShareServiceImpl implements ShareService {
  const ShareServiceImpl();

  @override
  Future<void> shareText(String text, {String? subject}) =>
      SharePlus.instance.share(ShareParams(text: text, subject: subject));
}

/// Bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
ShareService shareService(Ref ref) => throw UnimplementedError(
  'shareServiceProvider must be overridden in ProviderScope '
  '(core/bootstrap).',
);
