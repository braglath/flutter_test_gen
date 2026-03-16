import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/utils/string_utils.dart';

void main() {
  group('Functions (utils/string_utils.dart)', () {
    test('returns string when capitalize succeeds', () {
      // Arrange
      final value = 'test';

      // Act
      final result = capitalize(value);

      // Assert
      expect(result, 'test');
    });

    test('returns bool when isLong succeeds', () {
      // Arrange
      final text = 'test';

      // Act
      final result = isLong(text);

      // Assert
      expect(result, true);
    });
  });
}
