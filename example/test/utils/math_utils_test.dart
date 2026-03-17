import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_test_gen_example/utils/math_utils.dart';

void main() {
  group('MathUtils (utils/math_utils.dart)', () {
    test('returns bool when isEven succeeds', () async {
      // Arrange
      final value = 1;

      // Act
      final result = MathUtils.isEven(value);

      // Assert
      expect(result, true);
    });

    test('returns int when add succeeds', () async {
      // Arrange
      final a = 1;
      final b = 1;

      // Act
      final result = MathUtils.add(a, b);

      // Assert
      expect(result, 1);
    });
  });
}
