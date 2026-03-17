import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/models/user_role.dart';
import 'package:flutter_test_gen_example/services/permission_service.dart';

void main() {
  group('PermissionService (services/permission_service.dart)', () {
    late PermissionService service;

    setUp(() {
      service = PermissionService();
    });

    test('returns bool when canEdit succeeds', () async {
      // Arrange
      final role = UserRole.values.first;

      // Act
      final result = service.canEdit(role);

      // Assert
      expect(result, true);
    });
  });
}
