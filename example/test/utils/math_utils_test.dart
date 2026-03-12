import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/utils/math_utils.dart';

void main() {
  group('MathUtils | lib/utils/math_utils.dart', () {
    setUp(() {});

    test('add', () {
      // Arrange
      final a = 1;
      final b = 1;

      // Act
      final result = MathUtils.add(a, b);

      // Assert
      expect(result, isA<int>());
    });
    test('isEven', () {
      // Arrange
      final value = 1;

      // Act
      final result = MathUtils.isEven(value);

      // Assert
      expect(result, isA<bool>());
    });
  });
}
