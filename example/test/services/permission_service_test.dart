import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/services/permission_service.dart';
import 'package:flutter_test_gen_example/models/user_role.dart';

void main() {
  group('PermissionService | example/lib/services/permission_service.dart', () {
    late PermissionService service;

    setUp(() {
      service = PermissionService();
    });

    test('canEdit', () {
      // Arrange
      final role = UserRole();

      // Act
      final result = service.canEdit(role);

      // Assert
      expect(result, isTrue);
    });
  });
}
