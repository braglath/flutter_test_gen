import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/models/test_case.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

class TestCaseBuilder {
  final ProjectUtil project;

  TestCaseBuilder(this.project);

  TestCase build(MethodInfo method) {
    if (method.switchCases.isNotEmpty) {
      return TestCase(
        description: method.methodName,
        body: _generateSwitchTests(method),
      );
    }

    final arrange = _generateArrange(method);
    final params = _generateCallParams(method);

    final call = method.className == '__top_level__'
        ? '${method.methodName}($params)'
        : method.isStatic
            ? '${method.className}.${method.methodName}($params)'
            : 'service.${method.methodName}($params)';

    String returnType = method.returnType.replaceAll('?', '');

    if (returnType.startsWith('Future<')) {
      returnType = returnType.replaceFirst('Future<', '').replaceFirst('>', '');
    }

    final expectedValue = project.isPrimitive(returnType)
        ? project.primitiveValueForAssert(returnType)
        : 'isA<$returnType>()';

    final verifyCall = _buildVerify(method);

    return TestCase(
      description: project.buildTestName(method, returnType),
      body: _buildTestBody(
          arrange: arrange,
          call: call,
          expectedValue: expectedValue,
          isAsync: method.isAsync,
          isVoid: method.isVoid,
          verifyCall: verifyCall),
    );
  }

  String _buildTestBody({
    required String arrange,
    required String call,
    required String expectedValue,
    required bool isAsync,
    required bool isVoid,
    required String verifyCall,
  }) {
    final buffer = StringBuffer();

    /// Arrange
    if (arrange.trim().isNotEmpty) {
      buffer.writeln('    // Arrange');
      buffer.writeln(arrange);
      buffer.writeln();
    }

    buffer.writeln();

    /// Act
    buffer.writeln('    // Act');

    if (isAsync) {
      buffer.writeln('    final result = await $call;');
    } else if (!isVoid) {
      buffer.writeln('    final result = $call;');
    } else {
      buffer.writeln('    $call;');
    }

    buffer.writeln();

    /// Assert
    buffer.writeln('    // Assert');

    if (!isVoid) {
      buffer.writeln('    expect(result, $expectedValue);');
    } else {
      buffer.writeln('    // verify side effects');
    }

    /// Verify (if exists)
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

  /// TEMP: move as-is (we'll refactor later)
  String _generateArrange(MethodInfo method) {
    final buffer = StringBuffer();

    for (final param in method.parameters) {
      final value = project.generateValue(param);
      buffer.writeln('final ${param.name} = $value;');
    }

    return buffer.toString();
  }

  /// TEMP: keep as-is
  String _generateSwitchTests(MethodInfo method) {
    final buffer = StringBuffer();

    for (final type in method.switchCases.first.types) {
      buffer.writeln('test("${method.methodName} handles $type", () {});');
    }

    return buffer.toString();
  }

  String _buildVerify(MethodInfo method) {
    final buffer = StringBuffer();

    for (final access in method.propertyAccesses) {
      for (final dep in method.constructorDependencies) {
        if (access.target == dep.name) {
          final mockVar = _mockVar(dep.name);
          final args = access.args.isEmpty ? '' : '(${access.args.join(', ')})';

          buffer.writeln(
            '    verify(() => $mockVar.${access.property}$args).called(1);',
          );
        }
      }
    }

    return buffer.toString().trim();
  }

  String _mockVar(String name) {
    final cap = name[0].toUpperCase() + name.substring(1);
    return 'mock$cap';
  }
}
