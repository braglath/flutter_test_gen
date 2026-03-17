import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_test_gen_example/services/counter_service.dart';

void main() {
  group('CounterService (services/counter_service.dart)', () {
    late CounterService service;

    setUp(() {
      service = CounterService();
    });

    test('returns int when increment succeeds', () {
      // Arrange
      final value = 1;

      // Act
      final result = service.increment(value);

      // Assert
      expect(result, 1);
    });
    test('returns int when decrement succeeds', () {
      // Arrange
      final value = 1;

      // Act
      final result = service.decrement(value);

      // Assert
      expect(result, 1);
    });
    test('returns int when reset succeeds', () {
      // Act
      final result = service.reset();

      // Assert
      expect(result, 1);
    });
  });
}
