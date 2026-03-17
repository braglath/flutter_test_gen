/// Provides utility methods for working with Dart types.
///
/// [TypeUtils] is used during test generation to normalize and
/// inspect type strings, especially for handling async types.
class TypeUtils {
  /// Unwraps a Dart type by removing nullability and `Future` wrappers.
  ///
  /// Behavior:
  /// - Removes nullable marker (`?`)
  /// - Extracts inner type from `Future<T>`
  ///
  /// Examples:
  /// ```dart
  /// unwrap('int?') → 'int'
  /// unwrap('Future<String>') → 'String'
  /// unwrap('Future<int?>') → 'int'
  /// ```
  ///
  /// Parameters:
  /// - [type]: The original type string
  ///
  /// Returns:
  /// The unwrapped, non-nullable type.
  static String unwrap(String type) {
    var clean = type.replaceAll('?', '');

    if (clean.startsWith('Future<')) {
      clean = clean.replaceFirst('Future<', '').replaceFirst('>', '');
    }

    return clean;
  }

  /// Checks whether a type represents a `Future`.
  ///
  /// Behavior:
  /// - Returns `true` if the type starts with `Future<`
  ///
  /// Example:
  /// ```dart
  /// isFuture('Future<int>') → true
  /// isFuture('int') → false
  /// ```
  ///
  /// Parameters:
  /// - [type]: The type string to evaluate
  ///
  /// Returns:
  /// `true` if the type is a `Future`, otherwise `false`
  static bool isFuture(String type) => type.startsWith('Future<');
}
