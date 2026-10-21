import 'package:core/permissions/permission_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  test('asks for location while in use and for notifications', () async {
    final asked = <Permission>[];
    final service = PermissionServiceImpl(
      request: (permission) async {
        asked.add(permission);
        return PermissionStatus.granted;
      },
    );

    await service.request(AppPermission.location);
    await service.request(AppPermission.notifications);

    expect(asked, <Permission>[
      Permission.locationWhenInUse,
      Permission.notification,
    ]);
  });

  test('maps every system answer to an outcome', () async {
    const expected = <PermissionStatus, PermissionOutcome>{
      PermissionStatus.granted: PermissionOutcome.granted,
      PermissionStatus.limited: PermissionOutcome.granted,
      PermissionStatus.provisional: PermissionOutcome.granted,
      PermissionStatus.denied: PermissionOutcome.denied,
      PermissionStatus.permanentlyDenied: PermissionOutcome.permanentlyDenied,
      PermissionStatus.restricted: PermissionOutcome.permanentlyDenied,
    };
    for (final MapEntry(key: status, value: outcome) in expected.entries) {
      final service = PermissionServiceImpl(request: (_) async => status);
      expect(await service.request(AppPermission.location), outcome);
    }
  });
}
