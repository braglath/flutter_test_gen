import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/user_service.dart';

void main() {
  group('Functions | lib/user_service.dart', () {
    test('globalFunction', () {
      // Arrange

      // Act
      final result = globalFunction();

      // Assert
      expect(result, isNotNull);
    });
  });

  group('UserService | lib/user_service.dart', () {
    late UserService service;

    setUp(() {
      service = UserService();
    });

    test('getAge', () {
      // Arrange

      // Act
      final result = service.getAge();

      // THIS IS NEW HERE
      // Assert
      expect(result, isNotNull);
    });
  });
  test('add', () {
    // Arrange

    // Act
    final result = UserService.add(1, 1);

    // Assert
    expect(result, isNotNull);
  });
}
