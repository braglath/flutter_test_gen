import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/utils/naming_utils.dart';

/// Builds the "Verify" section of a generated test case.
///
/// [VerifyBuilder] is responsible for generating verification
/// statements for mocked dependencies after the method under test
/// has been executed.
///
/// It ensures that expected interactions with dependencies
/// (e.g., method calls) have occurred.
class VerifyBuilder {
  /// Generates the verify step for a test case.
  ///
  /// Parameters:
  /// - [method]: Metadata describing the method under test,
  ///   including property accesses and constructor dependencies.
  ///
  /// Behavior:
  /// - Matches property accesses with constructor-injected dependencies
  /// - Generates `verify` statements for each interaction
  /// - Includes method arguments if present
  /// - Ensures each interaction is called exactly once (`called(1)`)
  ///
  /// Returns:
  /// A formatted string representing the verify section of the test.
  String build(MethodInfo method) {
    final buffer = StringBuffer();

    for (final access in method.propertyAccesses) {
      for (final dep in method.constructorDependencies) {
        if (access.target == dep.name) {
          final mockVar = NamingUtils.mockVar(dep.name);
          final args = access.args.isEmpty ? '' : '(${access.args.join(', ')})';

          buffer.writeln(
            '    verify(() => $mockVar.${access.property}$args).called(1);',
          );
        }
      }
    }

    return buffer.toString().trim();
  }
}
