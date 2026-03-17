import 'package:flutter_test_gen/flutter_test_gen.dart';
import 'package:flutter_test_gen/src/analyzer/dependency/dependency_analyzer.dart';
import 'package:flutter_test_gen/src/analyzer/import/import_resolver.dart';
import 'package:flutter_test_gen/src/generator/mock/mock_generator.dart';
import 'package:flutter_test_gen/src/generator/test/test_group_builder.dart';
import 'package:flutter_test_gen/src/templates/unit_test_template.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

/// Builds a complete unit test file for a set of methods.
///
/// [TestFileBuilder] is responsible for orchestrating the final
/// test file generation by combining:
/// - Imports (resolved and normalized)
/// - Mock class and variable generation
/// - Grouped test cases per class
/// - File-level test template rendering
///
/// It acts as the top-level builder that produces a ready-to-use
/// Dart test file.
class TestFileBuilder {
  /// Utility for project-level operations such as import normalization,
  /// value generation, and naming conventions.
  final ProjectUtil project;

  /// Resolves imports required for test generation.
  final ImportResolver resolver;

  /// Internal set of collected imports for the test file.
  final Set<String> _imports = {};

  /// Returns the generated imports for the test file.
  ///
  /// Ensures a copy is returned to prevent external mutation.
  Set<String> get generatedImports => _imports.toSet();

  /// Creates a [TestFileBuilder] with the given [project] utilities.
  ///
  /// Internally initializes an [ImportResolver] using the same project.
  TestFileBuilder(this.project) : resolver = ImportResolver(project);

  /// Generates the complete test file content.
  ///
  /// Parameters:
  /// - [methods]: List of analyzed methods to generate tests for.
  /// - [importPath]: The main import path of the source file under test.
  /// - [relativePath]: Relative path used for grouping or imports.
  /// - [existing]: Existing test file content (used to avoid duplicates).
  /// - [sourceFilePath]: Absolute path of the source file being tested.
  ///
  /// Behavior:
  /// - Collects and normalizes imports from method metadata
  /// - Deduplicates imports and dependencies
  /// - Groups methods by class name
  /// - Generates test groups using [TestGroupBuilder]
  /// - Generates mock classes and variables for dependencies
  /// - Sorts imports for consistency
  /// - Renders the final file using [UnitTestTemplates]
  ///
  /// Returns:
  /// A formatted string representing the complete test file.
  String build(
    List<MethodInfo> methods,
    String importPath,
    String relativePath,
    String existing,
    String sourceFilePath,
  ) {
    final grouped = <String, List<MethodInfo>>{};
    final dependencies = <Dependency>{};

    for (final method in methods) {
      resolver.collectImports(method, sourceFilePath, _imports);

      /// Source imports
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

      /// Collect dependencies
      for (final dep in method.constructorDependencies) {
        if (!dependencies.any((d) => d.type == dep.type)) {
          dependencies.add(dep);
        }
      }

      grouped.putIfAbsent(method.className, () => []);
      grouped[method.className]!.add(method);
    }

    final groupBuilder = TestGroupBuilder(project);
    final groups = StringBuffer();

    grouped.forEach((className, methodList) {
      final group = groupBuilder.buildGroup(
        className: className,
        methods: methodList,
        relativePath: relativePath,
        existing: existing,
      );

      if (group.isNotEmpty) {
        groups.write(group);
      }
    });

    final mockClasses = dependencies.isEmpty
        ? ''
        : MockGenerator.generateMockClasses(dependencies.toList());

    final mockVariables = dependencies.isEmpty
        ? ''
        : MockGenerator.generateMockVariables(dependencies.toList());

    final importList = _imports.toList()..sort();

    return UnitTestTemplates.file(
      importPath: importPath,
      imports: importList.join('\n'),
      mocks: mockClasses,
      mockVariables: mockVariables,
      groups: groups.toString(),
    );
  }
}
