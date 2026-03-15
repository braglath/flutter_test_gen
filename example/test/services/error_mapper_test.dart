import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/services/error_mapper.dart';
import 'package:flutter_test_gen_example/errors/user_error.dart';
import 'package:flutter_test_gen_example/localization/app_local.dart';

void main() {
  group('ErrorMapper | example/lib/services/error_mapper.dart', () {
    test('map handles UserNotFound', () {
      // Arrange
      final error = const UserNotFound();
      final local = AppLocal();
      final service = ErrorMapper(error);

      // Act
      final result = service.map(local);

      // Assert
      expect(result, isA<String>());
    });

    test('map handles UserBlocked', () {
      // Arrange
      final error = const UserBlocked();
      final local = AppLocal();
      final service = ErrorMapper(error);

      // Act
      final result = service.map(local);

      // Assert
      expect(result, isA<String>());
    });
  });
}
