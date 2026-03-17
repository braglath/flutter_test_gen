import 'package:flutter_test_gen/flutter_test_gen.dart';
import 'package:flutter_test_gen/src/analyzer/dependency/dependency_analyzer.dart';
import 'package:flutter_test_gen/src/analyzer/import/import_resolver.dart';
import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/utils/naming_utils.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

/// Builds the "Arrange" section of a generated test case.
///
/// [ArrangeBuilder] is responsible for preparing all required inputs
/// and mock behaviors before executing the method under test.
///
/// It generates:
/// - Parameter initialization values
/// - Mock stubbing for dependencies and property accesses
///
/// This ensures the test has all necessary setup before the "Act" phase.
class ArrangeBuilder {
  /// Utility for project-level operations such as generating values
  /// and constructing objects.
  final ProjectUtil project;

  /// Resolves imports and constructor fields for non-primitive types.
  final ImportResolver resolver;

  /// Creates an [ArrangeBuilder] with the given [project] utilities.
  ///
  /// Internally initializes an [ImportResolver] using the same project.
  ArrangeBuilder(this.project) : resolver = ImportResolver(project);

  /// Generates the arrange step for a test case.
  ///
  /// This includes:
  /// - Initializing method parameters with generated values
  /// - Stubbing mocked dependencies based on detected property access
  ///
  /// Parameters:
  /// - [method]: Metadata describing the method under test,
  ///   including parameters, dependencies, and usage details.
  ///
  /// Behavior:
  /// - Avoids duplicate stubs using a `seen` set
  /// - Infers return types for mocked methods
  /// - Handles both synchronous and asynchronous stubbing
  /// - Generates realistic values for primitives and objects
  ///
  /// Returns:
  /// A formatted string representing the arrange section of the test.
  String build(MethodInfo method) {
    final buffer = StringBuffer();

    /// Parameters
    for (final param in method.parameters) {
      final value = project.generateValue(param);
      buffer.writeln('    final ${param.name} = $value;');
    }

    /// Mock stubbing
    final seen = <String>{};

    for (final access in method.propertyAccesses) {
      final key = '${access.target}.${access.property}';
      if (!seen.add(key)) continue;

      final dep = method.constructorDependencies.firstWhere(
        (d) => d.name == access.target,
        orElse: () => Dependency('', ''),
      );

      if (dep.name.isEmpty) continue;

      final mockVar = NamingUtils.mockVar(dep.name);
      final args = access.args.isEmpty ? '' : '(${access.args.join(', ')})';

      String returnType = access.returnType ?? '';

      final isAsync =
          access.returnType?.startsWith('Future<') == true || method.isAsync;

      if (!isAsync && method.isAsync) {
        returnType = 'Future<$returnType>';
      }

      if (returnType.isEmpty || returnType == 'dynamic') {
        if (dep.type.endsWith('Repository')) {
          returnType = dep.type.replaceAll('Repository', '');
        }
      }

      final inner = returnType.startsWith('Future<')
          ? returnType.replaceFirst('Future<', '').replaceFirst('>', '')
          : returnType;

      if (isAsync) {
        final fields = resolver.resolveConstructorFields(
          inner,
          method.sourceImports.toSet(),
        );

        final value = project.isPrimitive(inner)
            ? project.primitiveValueForMock(inner)
            : fields.isEmpty
                ? '$inner()'
                : project.buildObject(inner, fields);

        buffer.writeln(
          '    when(() => $mockVar.${access.property}$args)'
          '.thenAnswer((_) async => $value);',
        );
      } else {
        final value = project.primitiveValueForMock(inner);

        buffer.writeln(
          '    when(() => $mockVar.${access.property}$args)'
          '.thenReturn($value);',
        );
      }
    }

    return buffer.toString();
  }
}
