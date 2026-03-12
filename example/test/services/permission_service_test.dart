import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test_gen_example/services/permission_service.dart';
import 'package:flutter_test_gen_example/models/user_role.dart';

class MockUserRole extends Mock implements UserRole {}

void main() {
  late MockUserRole mockRole;

  group('PermissionService | example/lib/services/permission_service.dart', () {
    late PermissionService service;

    setUp(() {
      mockRole = MockUserRole();

      service = PermissionService();
    });

    test('canEdit', () {
      // Arrange
      final role = mockRole;

      // Act
      final result = service.canEdit(role);

      // Assert
      expect(result, isA<bool>());
    });
  });
}
