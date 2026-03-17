import 'package:flutter_test_gen/flutter_test_gen.dart';
import 'package:flutter_test_gen/src/analyzer/dependency/dependency_analyzer.dart';
import 'package:flutter_test_gen/src/analyzer/import/import_resolver.dart';
import 'package:flutter_test_gen/src/generator/mock/mock_generator.dart';
import 'package:flutter_test_gen/src/generator/test/test_case_builder.dart';
import 'package:flutter_test_gen/src/templates/unit_test/unit_test_template.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';
import 'package:flutter_test_gen/src/writer/test_writer.dart';

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
  Set<String> get generatedImports => _imports.toSet();

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

      /// Add original source imports
      final seen = <String>{};

      for (final import in method.sourceImports) {
        final normalized = project.normalizeImport(
          import,
          currentFilePath: sourceFilePath,
        );

        if (seen.add(normalized)) {
          _imports.add("import '$normalized';");
        }
      }

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

        if (TestWriter.testExists(existing, method.methodName)) continue;

        final caseBuilder = TestCaseBuilder(project);
        final testCase = caseBuilder.build(method);

        tests.write(
          UnitTestTemplates.test(
            name: testCase.description,
            body: testCase.body,
          ),
        );
      }

      if (tests.isEmpty) return;

      /// Constructor dependencies only
      final hasSwitchCases = methodList.any((m) => m.switchCases.isNotEmpty);

      final constructorDeps = className == '__top_level__' || hasSwitchCases
          ? <Dependency>[]
          : methodList.first.constructorDependencies;

      final hasInstanceMethods =
          !hasSwitchCases && methodList.any((m) => !m.isStatic);

      final cleanPath = relativePath.replaceFirst('lib/', '');

      groups.write(UnitTestTemplates.group(
        groupName: className == '__top_level__'
            ? 'Functions ($cleanPath)'
            : '$className ($cleanPath)',
        className: className,
        tests: tests.toString(),
        isTopLevel: className == '__top_level__',
        dependencies: constructorDeps,
        constructorDependencies: constructorDeps,
        hasInstanceMethods: hasInstanceMethods,
      ));
    });

    /// Generate mocks only for constructor dependencies
    final mockClasses = dependencies.isEmpty
        ? ''
        : MockGenerator.generateMockClasses(dependencies.toList());

    final mockVariables = dependencies.isEmpty
        ? ''
        : MockGenerator.generateMockVariables(dependencies.toList());

    /// Prefer imports that came from the original source file
    final sourceImportFiles = methods
        .expand((m) => m.sourceImports)
        .map((i) => i.split('/').last)
        .toSet();

    _imports.removeWhere((import) {
      final file = import.split('/').last.replaceAll("';", '');
      return sourceImportFiles.contains(file) == false &&
          sourceImportFiles.any((src) => file.startsWith(src.split('.').first));
    });

    final importList = _imports.toList()..sort();

    return UnitTestTemplates.file(
      importPath: importPath,
      imports: importList.join('\n'),
      mocks: mockClasses,
      mockVariables: mockVariables,
      groups: groups.toString(),
    );
  }

  /// Generates a unit test string for a given [MethodInfo].
  ///
  /// This method builds a complete test case by:
  /// - Handling `switch`-based methods separately.
  /// - Preparing the **arrange** section using [_generateArrange].
  /// - Constructing the method call with correct invocation:
  ///   - Top-level functions
  ///   - Static methods
  ///   - Instance methods (via `service`)
  /// - Resolving the return type:
  ///   - Unwrapping `Future<T>` if async
  ///   - Removing nullability (`?`)
  /// - Generating an appropriate expected value:
  ///   - Primitive types → concrete values (via [project.primitiveValueForAssert])
  ///   - Non-primitive types → `isA<T>()` matcher
  /// - Verifying interactions with mocked dependencies:
  ///   - Detects property/method accesses on constructor dependencies
  ///   - Generates `verify(...).called(1)` assertions
  ///
  /// Additionally:
  /// - Logs debug information for method and verification generation
  /// - Builds a readable test name using [project.buildTestName]
  ///
  /// Returns:
  /// A formatted test case string using [UnitTestTemplates.test].
  ///
  /// Notes:
  /// - Supports async and void methods
  /// - Automatically adapts assertions based on return type
  /// - Integrates with mock verification for dependency interactions
  // String generateSingleTest(MethodInfo method) {
  //   if (method.switchCases.isNotEmpty) {
  //     return _generateSwitchTests(method);
  //   }

  //   final arrange = _generateArrange(method);
  //   final params = _generateCallParams(method.parameters);

  //   final call = method.className == '__top_level__'
  //       ? '${method.methodName}($params)'
  //       : method.isStatic
  //           ? '${method.className}.${method.methodName}($params)'
  //           : 'service.${method.methodName}($params)';

  //   String returnType = method.returnType.replaceAll('?', '');

  //   if (returnType.startsWith('Future<')) {
  //     returnType = returnType.replaceFirst('Future<', '').replaceFirst('>', '');
  //   }

  //   String expectedValue;

  //   if (project.isPrimitive(returnType)) {
  //     expectedValue = project.primitiveValueForAssert(returnType);
  //   } else {
  //     expectedValue = 'isA<$returnType>()';
  //   }

  //   final verifyCall = (() {
  //     final buffer = StringBuffer();

  //     for (final access in method.propertyAccesses) {
  //       for (final dep in method.constructorDependencies) {
  //         if (access.target == dep.name) {
  //           final mockVar = _mockVar(dep.name);
  //           final args =
  //               access.args.isEmpty ? '' : '(${access.args.join(', ')})';

  //           buffer.writeln(
  //             '      verify(() => $mockVar.${access.property}$args).called(1);',
  //           );
  //         }
  //       }
  //     }

  //     return buffer.toString().trim();
  //   })();

  //   debugLog('methodInfo: $method');
  //   debugLog('verifyCall: $verifyCall');

  //   final testName = project.buildTestName(method, returnType);

  //   return UnitTestTemplates.test(
  //     name: testName,
  //     arrange: arrange,
  //     call: call,
  //     expectedValue: expectedValue,
  //     verifyCall: verifyCall,
  //     isAsync: method.isAsync,
  //     isVoid: method.isVoid,
  //   );
  // }

//   String _generateSwitchTests(MethodInfo method) {
//     final buffer = StringBuffer();

//     final switchInfo = method.switchCases.first;

//     for (final type in switchInfo.types) {
//       buffer.writeln('''
//     test('${method.methodName} handles $type', () {
//       // Arrange
//       final error = const $type();
//       final local = AppLocal();
//       final service = ${method.className}(error);

//       // Act
//       final result = service.${method.methodName}(local);

//       // Assert
//       expect(result, isA<String>());
//     });
// ''');
//     }

//     return buffer.toString();
//   }

//   String _generateArrange(MethodInfo method) {
//     final buffer = StringBuffer();

//     /// Parameters
//     /// Parameters
//     for (final param in method.parameters) {
//       /// Enum parameters
//       final value = project.generateValue(param);

//       buffer.writeln(
//         '      final ${param.name} = $value;',
//       );
//     }

//     /// Stub dependency calls
//     final seen = <String>{};

//     for (final access in method.propertyAccesses) {
//       final key = '${access.target}.${access.property}';
//       if (!seen.add(key)) continue;

//       /// Only stub constructor dependencies
//       final isConstructorDependency = method.constructorDependencies.any(
//           (dep) =>
//               dep.type.toLowerCase().contains(access.target.toLowerCase()));

//       if (!isConstructorDependency) continue;

//       final mockVar = _mockVar(access.target);

//       final args = access.args.isEmpty ? '' : '(${access.args.join(', ')})';

//       if (access.args.isEmpty) {
//         buffer.writeln(
//           "      when(() => $mockVar.${access.property}).thenReturn('test');",
//         );
//       } else {
//         // stub generation
//         String depReturnType = access.returnType ?? '';

//         /// If analyzer couldn't detect the return type,
//         /// fallback to dependency model inference
//         if (depReturnType.isEmpty) {
//           final dep = method.constructorDependencies.isNotEmpty
//               ? method.constructorDependencies.first
//               : Dependency('dynamic', 'dynamic');

//           depReturnType = dep.type.endsWith('Repository')
//               ? dep.type.replaceAll('Repository', '')
//               : dep.type;
//         }

//         final fields = resolver.resolveConstructorFields(
//           depReturnType,
//           method.sourceImports.toSet(),
//         );

//         final value = fields.isEmpty
//             ? '$depReturnType()'
//             : project.buildObject(depReturnType, fields);

//         buffer.writeln(
//           '      when(() => $mockVar.${access.property}$args)'
//           '.thenAnswer((_) async => $value);',
//         );
//       }
//     }

//     return buffer.toString();
//   }

//   String _generateCallParams(List<ParameterInfo> params) => params.map((p) {
//         if (p.isNamed) return '${p.name}: ${p.name}';
//         return p.name;
//       }).join(', ');

  // String _mockVar(String name) {
  //   final cap = name[0].toUpperCase() + name.substring(1);
  //   return 'mock$cap';
  // }

  bool _shouldSkip(MethodInfo method) {
    if (method.methodName.startsWith('_')) return true;
    if (method.className.endsWith('Mixin')) return true;
    if (method.className.contains('Ext')) return true;
    return false;
  }
}
