import 'package:flutter_test_gen/flutter_test_gen.dart';
import 'package:flutter_test_gen/src/analyzer/dependency/dependency_analyzer.dart';
import 'package:flutter_test_gen/src/generator/test/test_case_builder.dart';
import 'package:flutter_test_gen/src/templates/unit_test_template.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';
import 'package:flutter_test_gen/src/utils/test_utils.dart';

// Builds grouped test blocks for a class or top-level functions.
///
/// [TestGroupBuilder] organizes multiple test cases into a single
/// `group()` block, typically representing a class or a set of
/// top-level functions within a file.
///
/// It is responsible for:
/// - Filtering unsupported or internal methods
/// - Generating test cases using [TestCaseBuilder]
/// - Wrapping tests into a structured group template
class TestGroupBuilder {
  /// Utility for project-level operations such as naming
  /// and value generation.
  final ProjectUtil project;

  /// Builder responsible for generating individual test cases.
  final TestCaseBuilder caseBuilder;

  /// Creates a [TestGroupBuilder] with the given [project] utilities.
  ///
  /// Internally initializes a [TestCaseBuilder].
  TestGroupBuilder(this.project) : caseBuilder = TestCaseBuilder(project);

  /// Generates a grouped test block for a class or function set.
  ///
  /// Parameters:
  /// - [className]: Name of the class or `__top_level__` for functions.
  /// - [methods]: List of methods belonging to the class or file.
  /// - [relativePath]: Relative file path used for display in group name.
  /// - [existing]: Existing test content (used to avoid duplication).
  ///
  /// Behavior:
  /// - Skips private, mixin, and extension methods
  /// - Generates test cases using [TestCaseBuilder]
  /// - Wraps tests into a `group()` using [UnitTestTemplates]
  /// - Handles special cases:
  ///   - Top-level functions
  ///   - Switch-based methods (no constructor dependencies)
  ///   - Static vs instance methods
  ///
  /// Returns:
  /// A formatted string representing the grouped test block,
  /// or an empty string if no valid tests are generated.
  String buildGroup({
    required String className,
    required List<MethodInfo> methods,
    required String relativePath,
    required String existing,
  }) {
    final tests = StringBuffer();

    for (final method in methods) {
      if (_shouldSkip(method)) continue;

      final testCases = caseBuilder.build(method);

      for (final testCase in testCases) {
        tests.write(
          UnitTestTemplates.test(
            name: testCase.description,
            body: testCase.body,
            isAsync: TestUtils.needsAsync(method),
          ),
        );
      }
    }

    if (tests.isEmpty) return '';

    final hasSwitchCases = methods.any((m) => m.switchCases.isNotEmpty);

    final constructorDeps = className == '__top_level__' || hasSwitchCases
        ? <Dependency>[]
        : methods.first.constructorDependencies;

    final hasInstanceMethods =
        !hasSwitchCases && methods.any((m) => !m.isStatic);

    final cleanPath = relativePath.replaceFirst('lib/', '');

    return UnitTestTemplates.group(
      groupName: className == '__top_level__'
          ? 'Functions ($cleanPath)'
          : '$className ($cleanPath)',
      className: className,
      tests: tests.toString(),
      isTopLevel: className == '__top_level__',
      dependencies: constructorDeps,
      constructorDependencies: constructorDeps,
      hasInstanceMethods: hasInstanceMethods,
    );
  }

  bool _shouldSkip(MethodInfo method) {
    if (method.methodName.startsWith('_')) return true;
    if (method.className.endsWith('Mixin')) return true;
    if (method.className.contains('Ext')) return true;
    return false;
  }
}
