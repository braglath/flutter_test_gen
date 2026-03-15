import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/services/local_service.dart';
import 'package:flutter_test_gen_example/localization/app_locale.dart';

void main() {
  group('LocalService | example/lib/services/local_service.dart', () {
    late LocalService service;

    setUp(() {
      service = LocalService();
    });

    test('greeting', () {
      // Arrange
      final local = AppLocal();

      // Act
      final result = service.greeting(local);

      // Assert
      expect(result, isA<String>());
    });
  });
}
