import 'package:flutter_test_gen/flutter_test_gen.dart';
import 'package:flutter_test_gen/src/analyzer/import/import_resolver.dart';
import 'package:flutter_test_gen/src/generator/test/core/act_builder.dart';
import 'package:flutter_test_gen/src/generator/test/core/arrange_builder.dart';
import 'package:flutter_test_gen/src/generator/test/core/assert_builder.dart';
import 'package:flutter_test_gen/src/generator/test/core/verify_builder.dart';
import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/models/test_case.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';
import 'package:flutter_test_gen/src/utils/type_utils.dart';

/// Builds complete test cases for a given method.
///
/// [TestCaseBuilder] orchestrates the generation of structured test cases
/// by combining different test sections:
/// - Arrange (setup and mocks)
/// - Act (method execution)
/// - Assert (result validation)
/// - Verify (interaction checks)
///
/// It supports:
/// - Standard method test generation
/// - Switch-based test case expansion (multiple scenarios)
class TestCaseBuilder {
  /// Resolves imports and constructor metadata for complex types.
  final ImportResolver resolver;

  /// Utility for project-level operations such as naming,
  /// value generation, and object construction.
  final ProjectUtil project;

  /// Creates a [TestCaseBuilder] with the given [project] utilities.
  ///
  /// Internally initializes an [ImportResolver] using the same project.
  TestCaseBuilder(this.project) : resolver = ImportResolver(project);

  /// Generates test cases for the given [method].
  ///
  /// Behavior:
  /// - If the method contains switch cases, generates multiple
  ///   test cases (one per branch).
  /// - Otherwise, generates a single standard test case.
  /// - Builds each section using dedicated builders:
  ///   - [ArrangeBuilder]
  ///   - [ActBuilder]
  ///   - [AssertBuilder]
  ///   - [VerifyBuilder]
  ///
  /// Returns:
  /// A list of [TestCase] objects representing generated tests.
  List<TestCase> build(MethodInfo method) {
    if (method.switchCases.isNotEmpty) {
      return _buildSwitchTestCases(method);
    }

    final arrange = ArrangeBuilder(project).build(method);

    final params = _generateCallParams(method);

    final call = method.className == '__top_level__'
        ? '${method.methodName}($params)'
        : method.isStatic
            ? '${method.className}.${method.methodName}($params)'
            : 'service.${method.methodName}($params)';

    final returnType = TypeUtils.unwrap(method.returnType);

    final verifyCall = VerifyBuilder().build(method);

    return [
      TestCase(
        description: project.buildTestName(method, returnType),
        body: _composeTestBody(
          method: method,
          arrange: arrange,
          call: call,
          returnType: returnType,
          verifyCall: verifyCall,
        ),
      )
    ];
  }

  String _composeTestBody({
    required MethodInfo method,
    required String arrange,
    required String call,
    required String returnType,
    required String verifyCall,
  }) {
    final buffer = StringBuffer();

    /// Arrange
    if (arrange.trim().isNotEmpty) {
      buffer.writeln('    // Arrange');
      buffer.writeln(arrange);
      buffer.writeln();
    }

    /// Act
    buffer.writeln('    // Act');
    final act = ActBuilder().build(
      method: method,
      call: call,
    );
    buffer.write(act);
    buffer.writeln();

    /// Assert
    final assertCall = AssertBuilder(project).build(
      method: method,
      returnType: returnType,
    );
    buffer.write(assertCall);

    /// Verify
    if (verifyCall.trim().isNotEmpty) {
      buffer.writeln();
      buffer.writeln(verifyCall);
    }

    return buffer.toString();
  }

  String _generateCallParams(MethodInfo method) => method.parameters.map((p) {
        if (p.isNamed) return '${p.name}: ${p.name}';
        return p.name;
      }).join(', ');

  List<TestCase> _buildSwitchTestCases(MethodInfo method) {
    final cases = <TestCase>[];

    final switchInfo = method.switchCases.first;

    for (final type in switchInfo.types) {
      final buffer = StringBuffer();

      /// Arrange
      buffer.writeln('    // Arrange');
      buffer.writeln('    final error = $type();');
      buffer.writeln("    final local = ${_buildDependency('AppLocal')};");
      buffer.writeln('    final service = ${method.className}(error);');
      buffer.writeln();

      /// Act
      buffer.writeln('    // Act');
      buffer.writeln('    final result = service.${method.methodName}(local);');
      buffer.writeln();

      /// Assert
      buffer.writeln('    // Assert');

      final expected = switchInfo.expectedValues[type];

      buffer.writeln(
        expected != null
            ? '    expect(result, $expected);'
            : '    expect(result, isNotNull);',
      );

      cases.add(
        TestCase(
          description: '${method.methodName} handles $type',
          body: buffer.toString(),
        ),
      );
    }

    return cases;
  }

  bool _canInstantiateDirectly(String type) =>
      !type.startsWith('Abstract') &&
      !type.startsWith('I') &&
      !type.endsWith('Base');

  String _buildDependency(String type) {
    if (_canInstantiateDirectly(type)) {
      return '$type()';
    }

    final mockVar = 'mock$type';
    return mockVar;
  }
}
