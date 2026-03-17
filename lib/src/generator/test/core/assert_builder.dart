import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

/// Builds the "Assert" section of a generated test case.
///
/// [AssertBuilder] is responsible for generating assertions
/// that validate the outcome of the method under test.
///
/// It supports:
/// - Primitive value comparisons (e.g., `expect(result, 1)`)
/// - Type-based assertions for complex objects (e.g., `isA<Type>()`)
/// - Placeholder comments for void methods where side effects
///   should be verified
class AssertBuilder {
  /// Utility for project-level operations such as identifying
  /// primitive types and generating expected values.
  final ProjectUtil project;

  /// Creates an [AssertBuilder] with the given [project] utilities.
  AssertBuilder(this.project);

  /// Generates the assert step for a test case.
  ///
  /// Parameters:
  /// - [method]: Metadata about the method under test.
  /// - [returnType]: The return type of the method as a string.
  ///
  /// Behavior:
  /// - Adds a placeholder comment for void methods suggesting
  ///   verification of side effects.
  /// - Generates an `expect` statement for non-void methods.
  /// - Uses primitive comparisons when applicable.
  /// - Falls back to type matchers (`isA<T>()`) for complex types.
  ///
  /// Returns:
  /// A formatted string representing the assert section of the test.
  String build({
    required MethodInfo method,
    required String returnType,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('    // Assert');

    if (method.isVoid) {
      buffer.writeln('    // verify side effects');
      return buffer.toString();
    }

    final expectedValue = _expectedValue(returnType);

    buffer.writeln('    expect(result, $expectedValue);');

    return buffer.toString();
  }

  String _expectedValue(String returnType) {
    if (project.isPrimitive(returnType)) {
      /// Example:
      /// int → 1
      /// bool → true
      /// String → 'test'
      return project.primitiveValueForAssert(returnType);
    }

    /// Non-primitive → type matcher
    return 'isA<$returnType>()';
  }
}
