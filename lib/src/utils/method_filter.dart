import 'package:flutter_test_gen/flutter_test_gen.dart';

/// Provides utility methods for filtering unsupported or irrelevant methods.
///
/// [MethodFilter] is used during test generation to determine whether
/// a method should be excluded from processing.
class MethodFilter {
  /// Determines whether a given [method] should be skipped.
  ///
  /// Skips methods that are:
  /// - Private (method name starts with `_`)
  /// - Defined inside mixin classes
  /// - Part of extension classes
  ///
  /// Parameters:
  /// - [method]: Metadata describing the method under analysis
  ///
  /// Returns:
  /// `true` if the method should be skipped, otherwise `false`
  static bool shouldSkip(MethodInfo method) {
    if (method.methodName.startsWith('_')) return true;
    if (method.className.endsWith('Mixin')) return true;
    if (method.className.contains('Ext')) return true;
    return false;
  }
}
