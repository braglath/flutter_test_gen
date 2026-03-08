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
      final result = service.increment();

      // Assert
      //TODO: implement your assert logic
    });
    test('decrement', () {
      // Arrange

      // Act
      final result = service.decrement();

      // Assert
      //TODO: implement your assert logic
    });
    test('reset', () {
      // Arrange

      // Act
      final result = service.reset();

      // Assert
      //TODO: implement your assert logic
    });

    test('addAge', () {
      // Arrange
      final a = 1;
      final b = 1;

      // Act
      final result = service.addAge(a, b);

      // Assert
      expect(result, isNotNull);
    });

    test('updateGender', () {
      // Arrange
      final userGender = UserGender.values.first;

      // Act
      final result = service.updateGender(userGender);

      // Assert
      //TODO: implement your assert logic
    });
  });
}
