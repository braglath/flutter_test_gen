import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/user_model.dart';
import 'package:flutter_test_gen_example/user_service.dart';

void main() {
  group('Functions | lib/user_service.dart', () {
    test(
      'globalFunction',
      () {
        // test-gen:globalFunction

        // Arrange

        // Act
        final result = globalFunction();

        // Assert
        expect(result, isNotNull);
      },
      tags: ['globalFunction', 'unit'],
    );
  });

  group('UserService | lib/user_service.dart', () {
    late UserService service;

    setUp(() {
      service = UserService();
    });

    test(
      'getAge',
      () {
        // test-gen:UserService.getAge

        // Arrange

        // Act
        final result = service.getAge();

        // Assert
        expect(result, isNotNull);
      },
      tags: ['UserService', 'unit'],
    );
    test(
      'getUser',
      () {
        // test-gen:UserService.getUser

        // Arrange
        final model = UserModel();

        // Act
        final result = service.getUser(model);

        // Assert
        expect(result, isNotNull);
      },
      tags: ['UserService', 'unit'],
    );
    test(
      'updateUser',
      () {
        // test-gen:UserService.updateUser

        // Arrange
        final isNewUser = true;
        final name = 'test';
        final age = 1;
        final isActive = true;
        final createdAt = DateTime.now();

        // Act
        final result = service.updateUser(isNewUser,
            name: name, age: age, isActive: isActive, createdAt: createdAt);

        // Assert
        expect(result, isNotNull);
      },
      tags: ['UserService', 'unit'],
    );
    test(
      'updateEmail',
      () {
        // test-gen:UserService.updateEmail

        // Arrange
        final email = 'test';

        // Act
        final result = service.updateEmail(email);

        // Assert
        expect(result, isNotNull);
      },
      tags: ['UserService', 'unit'],
    );

    test(
      'add',
      () {
        // test-gen:UserService.add

        // Arrange
        final a = 1;
        final b = 1;

        // Act
        final result = UserService.add(a, b);

        // Assert
        expect(result, isNotNull);
      },
      tags: ['UserService', 'unit'],
    );
  });
}
