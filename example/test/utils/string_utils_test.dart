import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_gen_example/utils/string_utils.dart';

void main() {
  group('Functions | lib/utils/string_utils.dart', () {
    test('capitalize', () {
      // Arrange
      final value = 'test';

      // Act
      final result = capitalize(value);

      // Assert
      expect(result, isA<String>());
    });

    test('isLong', () {
      // Arrange
      final text = 'test';

      // Act
      final result = isLong(text);

      // Assert
      expect(result, isA<bool>());
    });
  });
}
