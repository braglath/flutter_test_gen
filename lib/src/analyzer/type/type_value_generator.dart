/// Utility class for generating default/mock values for Dart types.
///
/// This is primarily used in automated test generation to provide
/// placeholder values for method parameters and return types.
///
/// The generator supports:
/// - Primitive types (`int`, `String`, `bool`, `double`)
/// - Common core types (`DateTime`)
/// - Enum types (via [isEnum])
/// - Custom classes (via default constructor invocation)
///
/// Example:
/// ```dart
/// TypeValueGenerator.generate('int'); // returns '1'
/// TypeValueGenerator.generate('String'); // returns "'test'"
/// TypeValueGenerator.generate('User'); // returns 'User()'
/// TypeValueGenerator.generate('Status', isEnum: true); // returns 'Status.values.first'
/// ```
///
/// Notes:
/// - Nullability (`?`) is automatically stripped from the type.
/// - Custom types are assumed to have a default constructor.
/// - This does not validate whether the generated value compiles.
class TypeValueGenerator {
  /// Generates a default/mock value string for a given Dart [type].
  ///
  /// Parameters:
  /// - [type]: The Dart type as a string (e.g., `int`, `String`, `User?`).
  /// - [isEnum]: Whether the type represents an enum.
  ///
  /// Behavior:
  /// - Removes nullability (`?`) from the type.
  /// - If [isEnum] is `true`, returns the first enum value:
  ///   `Type.values.first`
  /// - Returns predefined values for known primitive types:
  ///   - `int` → `1`
  ///   - `String` → `'test'`
  ///   - `bool` → `true`
  ///   - `double` → `1.0`
  ///   - `DateTime` → `DateTime.now()`
  /// - For all other types, assumes a default constructor:
  ///   `Type()`
  ///
  /// Returns:
  /// A string representation of a value suitable for use in generated tests.
  ///
  /// Example:
  /// ```dart
  /// final value = TypeValueGenerator.generate('User');
  /// // value = 'User()'
  /// ```
  ///
  /// Limitations:
  /// - Does not handle complex generics (e.g., `List<String>`, `Map<K, V>`)
  /// - Assumes non-primitive types have a zero-argument constructor
  /// - Does not validate enum correctness when [isEnum] is false
  static String generate(String type, {bool isEnum = false}) {
    final clean = type.replaceAll('?', '');

    if (isEnum) {
      return '$clean.values.first';
    }

    switch (clean) {
      case 'int':
        return '1';
      case 'String':
        return "'test'";
      case 'bool':
        return 'true';
      case 'double':
        return '1.0';
      case 'DateTime':
        return 'DateTime.now()';
      default:
        return '$clean()';
    }
  }
}
