/// Provides utility methods for generating consistent variable names.
///
/// [NamingUtils] helps standardize naming conventions across
/// generated test code, ensuring readability and consistency.
class NamingUtils {
  /// Generates a mock variable name from a given dependency name.
  ///
  /// Behavior:
  /// - Capitalizes the first letter of the input [name]
  /// - Prefixes it with `mock`
  ///
  /// Example:
  /// ```dart
  /// mockVar('userRepository') → 'mockUserRepository'
  /// mockVar('apiService') → 'mockApiService'
  /// ```
  ///
  /// Parameters:
  /// - [name]: The original variable or dependency name
  ///
  /// Returns:
  /// A formatted mock variable name.
  static String mockVar(String name) {
    final cap = name[0].toUpperCase() + name.substring(1);
    return 'mock$cap';
  }
}
