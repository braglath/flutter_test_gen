import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/localization/app_locale.dart';
import 'package:flutter_test_gen_example/services/local_service.dart';

void main() {
  group('LocalService (services/local_service.dart)', () {
    late LocalService service;

    setUp(() {
      service = LocalService();
    });

    test('returns string when greeting succeeds', () {
      // Arrange
      final local = AppLocal();

      // Act
      final result = service.greeting(local);

      // Assert
      expect(result, 'test');
    });
  });
}
