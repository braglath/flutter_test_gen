import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/errors/user_error.dart';
import 'package:flutter_test_gen_example/localization/app_locale.dart';
import 'package:flutter_test_gen_example/services/error_mapper.dart';

void main() {
  group('ErrorMapper (services/error_mapper.dart)', () {
    test('map handles UserNotFound', () {
      // Arrange
      const error = UserNotFound();
      final local = AppLocal();
      final service = ErrorMapper(error);

      // Act
      final result = service.map(local);

      // Assert
      expect(result, local.invalidUser);
    });
    test('map handles UserBlocked', () {
      // Arrange
      const error = UserBlocked();
      final local = AppLocal();
      final service = ErrorMapper(error);

      // Act
      final result = service.map(local);

      // Assert
      expect(result, "User blocked");
    });
  });
}
