import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/utils/test_utils.dart';

/// Builds the "Act" section of a generated test case.
///
/// [ActBuilder] is responsible for generating the code that
/// executes the method under test. It determines whether the
/// method is asynchronous or returns a value and formats the
/// invocation accordingly.
///
/// The generated output typically includes:
/// - `await` for async methods
/// - assignment to `result` for non-void methods
/// - direct invocation for void methods
class ActBuilder {
  /// Generates the act step for a test case.
  ///
  /// Parameters:
  /// - [method]: Metadata about the method being tested.
  /// - [call]: The method invocation string (e.g., `service.fetchData()`).
  ///
  /// Behavior:
  /// - Uses `await` if the method is asynchronous.
  /// - Assigns the result to a `result` variable if the method
  ///   returns a value.
  /// - Executes the call directly if the method returns `void`.
  ///
  /// Returns:
  /// A formatted string representing the act section of the test.
  String build({
    required MethodInfo method,
    required String call,
  }) {
    final buffer = StringBuffer();

    final isAsync = TestUtils.needsAsync(method);
    final isVoid = method.isVoid;

    if (isAsync) {
      buffer.writeln('    final result = await $call;');
    } else if (!isVoid) {
      buffer.writeln('    final result = $call;');
    } else {
      buffer.writeln('    $call;');
    }

    return buffer.toString();
  }
}
