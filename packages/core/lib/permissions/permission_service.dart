import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_service.g.dart';

/// The device permissions the apps ask for.
enum AppPermission {
  /// Location while the app is in use; never in the background.
  location,

  /// Notifications.
  notifications,
}

/// How the person answered a permission prompt.
enum PermissionOutcome {
  granted,
  denied,

  /// The system will not ask again; only Settings can change it.
  permanentlyDenied,
}

/// Asks the operating system for a permission, showing its prompt when it
/// still can.
// ignore: one_member_abstracts
abstract interface class PermissionService {
  Future<PermissionOutcome> request(AppPermission permission);
}

/// [PermissionService] over the `permission_handler` plugin.
class PermissionServiceImpl implements PermissionService {
  PermissionServiceImpl({
    Future<PermissionStatus> Function(Permission permission)? request,
  }) : _request = request ?? ((permission) => permission.request());

  final Future<PermissionStatus> Function(Permission permission) _request;

  @override
  Future<PermissionOutcome> request(AppPermission permission) async {
    final status = await _request(switch (permission) {
      AppPermission.location => Permission.locationWhenInUse,
      AppPermission.notifications => Permission.notification,
    });
    return switch (status) {
      PermissionStatus.granted ||
      PermissionStatus.limited ||
      PermissionStatus.provisional => PermissionOutcome.granted,
      PermissionStatus.permanentlyDenied ||
      PermissionStatus.restricted => PermissionOutcome.permanentlyDenied,
      PermissionStatus.denied => PermissionOutcome.denied,
    };
  }
}

/// Bound in `core/bootstrap`.
@Riverpod(keepAlive: true)
PermissionService permissionService(Ref ref) => throw UnimplementedError(
  'permissionServiceProvider must be overridden in ProviderScope '
  '(core/bootstrap).',
);
