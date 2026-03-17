import 'package:flutter_test_gen/flutter_test_gen.dart';

/// Provides utility helpers for test generation logic.
///
/// [TestUtils] contains reusable helper methods that assist in
/// determining how tests should be generated.
class TestUtils {
  /// Determines whether a test should be marked as `async`.
  ///
  /// Behavior:
  /// - Returns `true` if the given [method] is asynchronous
  /// - Used to decide whether to:
  ///   - Add `async` to the test function
  ///   - Use `await` in the act phase
  ///
  /// Parameters:
  /// - [method]: Metadata describing the method under test
  ///
  /// Returns:
  /// `true` if the method is async, otherwise `false`
  static bool needsAsync(MethodInfo method) => method.isAsync;
}
