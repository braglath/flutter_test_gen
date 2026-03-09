import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/app_enum.dart';
import 'package:flutter_test_gen_example/counter_view_model.dart';

void main() {
  group('CounterViewModel | lib/counter_view_model.dart', () {
    late CounterViewModel service;

    setUp(() {
      service = CounterViewModel();
    });

    test('increment', () {
      // Arrange

      // Act
      service.increment();

      // Assert
      // TODO: verify side effects
    });
    test('decrement', () {
      // Arrange

      // Act
      service.decrement();

      // Assert
      // TODO: verify side effects
    });
    test('reset', () {
      // Arrange

      // Act
      service.reset();

      // Assert
      // TODO: verify side effects
    });
    test('updateGender', () {
      // Arrange
      final userGender = UserGender.values.first;

      // Act
      service.updateGender(userGender);

      // Assert
      // TODO: verify side effects
    });

    test('addAge', () {
      // Arrange
      final a = 1;
      final b = 1;

      // Act
      final result = service.addAge(a, b);

      // Assert
      expect(result, 1);
    });
  });
}
