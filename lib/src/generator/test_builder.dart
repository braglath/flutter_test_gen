import 'package:flutter_test_gen/src/di/dependency_resolver.dart';
import 'package:flutter_test_gen/src/di/mock_generator.dart';
import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/models/method_parameter.dart';
import 'package:flutter_test_gen/src/resolver/import_resolver.dart';
import 'package:flutter_test_gen/src/templates/test_template.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

/// Builds complete unit test files from extracted method metadata.
///
/// [TestBuilder] coordinates multiple components such as:
/// - [ProjectUtil] for project-specific utilities
/// - [ImportResolver] for resolving required imports
/// - [MockGenerator] for creating mock classes for dependencies
///
/// It groups methods by class, generates test cases, and produces the
/// final test file content including imports, mocks, and test groups.
class TestBuilder {
  /// Provides project-specific utilities such as value generation
  /// and primitive type handling used during test creation.
  final ProjectUtil project;

  /// Resolves and collects required imports for generated tests.
  ///
  /// This ensures that all types referenced in generated tests
  /// are properly imported.
  final ImportResolver resolver;

  final Set<String> _imports = {};

  /// Returns the list of imports collected during test generation.
  ///
  /// These imports are required for the generated test file
  /// to compile correctly.
  List<String> get generatedImports => _imports.toList();

  /// Creates a new [TestBuilder] instance for the given [project].
  ///
  /// The constructor initializes an [ImportResolver] which is used
  /// to detect and collect necessary imports for generated tests.
  TestBuilder(this.project) : resolver = ImportResolver(project);

  /// Generates the complete test file content for the provided [methods].
  ///
  /// Parameters:
  /// - [methods]: List of detected methods extracted from the source file.
  /// - [importPath]: Import path for the source file being tested.
  /// - [relativePath]: Relative file path used for grouping tests.
  /// - [existing]: Existing test file content (used to prevent duplicates).
  /// - [sourceFilePath]: Absolute path of the source file being analyzed.
  ///
  /// Behavior:
  /// - Groups methods by class.
  /// - Skips private or unsupported methods.
  /// - Collects required imports.
  /// - Generates mocks for detected dependencies.
  /// - Avoids generating duplicate tests if they already exist.
  ///
  /// Returns the generated test file content as a [String].
  String generate(
    List<MethodInfo> methods,
    String importPath,
    String relativePath,
    String existing,
    String sourceFilePath,
  ) {
    final grouped = <String, List<MethodInfo>>{};
    final dependencies = <Dependency>{};

    for (final method in methods) {
      if (_shouldSkip(method)) continue;

      resolver.collectImports(method, sourceFilePath, _imports);

      /// Only constructor dependencies should produce mocks
      for (final dep in method.constructorDependencies) {
        if (!dependencies.any((d) => d.type == dep.type)) {
          dependencies.add(dep);
        }
      }

      grouped.putIfAbsent(method.className, () => []);
      grouped[method.className]!.add(method);
    }

    final groups = StringBuffer();

    grouped.forEach((className, methodList) {
      final tests = StringBuffer();

      for (final method in methodList) {
        if (_shouldSkip(method)) continue;

        if (existing.contains("test('${method.methodName}'")) continue;

        tests.write(_generateSingleTest(method));
      }

      if (tests.isEmpty) return;

      /// Constructor dependencies only
      final constructorDeps = className == '__top_level__'
          ? <Dependency>[]
          : methodList.first.constructorDependencies;

      final hasInstanceMethods = methodList.any((m) => !m.isStatic);

      groups.write(TestTemplates.group(
        groupName: className == '__top_level__'
            ? 'Functions | $relativePath'
            : '$className | $relativePath',
        className: className,
        tests: tests.toString(),
        isTopLevel: className == '__top_level__',
        dependencies: constructorDeps,
        constructorDependencies: constructorDeps,
        hasInstanceMethods: hasInstanceMethods,
      ));
    });

    /// Generate mocks only for constructor dependencies
    final mockClasses = MockGenerator.generateMockClasses(
      dependencies.toList(),
    );

    final mockVariables = MockGenerator.generateMockVariables(
      dependencies.toList(),
    );

    return TestTemplates.file(
      importPath: importPath,
      imports: _imports.join('\n'),
      mocks: mockClasses,
      mockVariables: mockVariables,
      groups: groups.toString(),
    );
  }

  String _generateSingleTest(MethodInfo method) {
    final arrange = _generateArrange(method);
    final params = _generateCallParams(method.parameters);

    final call = method.className == '__top_level__'
        ? '${method.methodName}($params)'
        : method.isStatic
            ? '${method.className}.${method.methodName}($params)'
            : 'service.${method.methodName}($params)';

    final returnType = method.returnType.replaceAll('?', '');

    String expectedValue;

    if (method.propertyAccesses.isEmpty) {
      expectedValue = ProjectUtil.isPrimitive(returnType)
          ? project.primitiveValueForAssert(returnType)
          : 'isA<$returnType>()';
    } else {
      expectedValue = 'isA<$returnType>()';
    }

    final verifyCall = (() {
      final seen = <String>{};

      final accesses = method.propertyAccesses.where((access) {
        final key = '${access.target}.${access.property}';

        final isConstructorDependency = method.constructorDependencies.any(
          (d) => access.target.toLowerCase().contains(d.type.toLowerCase()),
        );

        return isConstructorDependency && seen.add(key);
      });

      if (accesses.isEmpty) return '';

      return accesses.map((access) {
        final mockVar = _mockVar(access.target);
        final args = access.args.isEmpty ? '' : '(${access.args.join(', ')})';

        return '      verify(() => $mockVar.${access.property}$args).called(1);';
      }).join('\n');
    })();

    return TestTemplates.test(
      name: method.methodName,
      arrange: arrange,
      call: call,
      expectedValue: expectedValue,
      verifyCall: verifyCall,
      isAsync: method.isAsync,
      isVoid: method.isVoid,
    );
  }

  String _generateArrange(MethodInfo method) {
    final buffer = StringBuffer();

    /// Parameters
    /// Parameters
    for (final param in method.parameters) {
      /// Enum parameters
      if (param.isEnum) {
        buffer.writeln(
          '      final ${param.name} = ${param.type}.values.first;',
        );
      } else {
        if (ProjectUtil.isSimpleObject(param.type)) {
          buffer.writeln(
            '      final ${param.name} = ${param.type}();',
          );
        } else {
          buffer.writeln(
            '      final ${param.name} = ${project.generateValue(param)};',
          );
        }
      }
    }

    /// Stub dependency calls
    final seen = <String>{};

    for (final access in method.propertyAccesses) {
      final key = '${access.target}.${access.property}';
      if (!seen.add(key)) continue;

      /// Only stub constructor dependencies
      final isConstructorDependency = method.constructorDependencies.any(
          (dep) =>
              dep.type.toLowerCase().contains(access.target.toLowerCase()));

      if (!isConstructorDependency) continue;

      final mockVar = _mockVar(access.target);

      final args = access.args.isEmpty ? '' : '(${access.args.join(', ')})';

      if (access.args.isEmpty) {
        buffer.writeln(
          "      when(() => $mockVar.${access.property}).thenReturn('test');",
        );
      } else {
        // stub generation
        final depReturnType = access.returnType ?? method.returnType;
        final value = ProjectUtil.primitiveValueForMock(depReturnType);

        buffer.writeln(
          '      when(() => $mockVar.${access.property}$args)'
          '.thenAnswer((_) async => $value);',
        );
      }
    }

    return buffer.toString();
  }

  String _generateCallParams(List<MethodParameter> params) => params.map((p) {
        if (p.isNamed) return '${p.name}: ${p.name}';
        return p.name;
      }).join(', ');

  String _mockVar(String name) {
    final cap = name[0].toUpperCase() + name.substring(1);
    return 'mock$cap';
  }

  bool _shouldSkip(MethodInfo method) {
    if (method.methodName.startsWith('_')) return true;
    if (method.className.endsWith('Mixin')) return true;
    if (method.className.contains('Ext')) return true;
    return false;
  }
}
