import 'package:flutter_test_gen/flutter_test_gen.dart';
import 'package:flutter_test_gen/src/analyzer/dependency/dependency_analyzer.dart';
import 'package:flutter_test_gen/src/analyzer/import/import_resolver.dart';
import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/models/test_case.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

class TestCaseBuilder {
  final ImportResolver resolver;
  final ProjectUtil project;

  TestCaseBuilder(this.project) : resolver = ImportResolver(project);

  List<TestCase> build(MethodInfo method) {
    if (method.switchCases.isNotEmpty) {
      return _buildSwitchTestCases(method);
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

    return [
      TestCase(
        description: project.buildTestName(method, returnType),
        body: _buildTestBody(
          arrange: arrange,
          call: call,
          expectedValue: expectedValue,
          isAsync: method.isAsync,
          isVoid: method.isVoid,
          verifyCall: verifyCall,
        ),
      )
    ];
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

    if (arrange.trim().isNotEmpty) {
      buffer.writeln('    // Arrange');
      buffer.writeln(arrange);
      buffer.writeln();
    }

    buffer.writeln('    // Act');

    if (isAsync) {
      buffer.writeln('    final result = await $call;');
    } else if (!isVoid) {
      buffer.writeln('    final result = $call;');
    } else {
      buffer.writeln('    $call;');
    }

    buffer.writeln();
    buffer.writeln('    // Assert');

    if (!isVoid) {
      buffer.writeln('    expect(result, $expectedValue);');
    } else {
      buffer.writeln('    // verify side effects');
    }

    if (verifyCall.trim().isNotEmpty) {
      buffer.writeln();
      buffer.writeln(verifyCall);
    }

    return buffer.toString();
  }

  String _generateArrange(MethodInfo method) {
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

      final mockVar = _mockVar(dep.name);
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

  String _generateCallParams(MethodInfo method) => method.parameters.map((p) {
        if (p.isNamed) return '${p.name}: ${p.name}';
        return p.name;
      }).join(', ');

  String _mockVar(String name) {
    final cap = name[0].toUpperCase() + name.substring(1);
    return 'mock$cap';
  }

  // String _generateSwitchTests(MethodInfo method) {
  //   final buffer = StringBuffer();

  //   for (final type in method.switchCases.first.types) {
  //     buffer.writeln('    test("${method.methodName} handles $type", () {});');
  //   }

  //   return buffer.toString();
  // }

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
