import 'package:flutter_test_gen/flutter_test_gen.dart';
import 'package:flutter_test_gen/src/analyzer/dependency/dependency_analyzer.dart';
import 'package:flutter_test_gen/src/generator/test/test_case_builder.dart';
import 'package:flutter_test_gen/src/templates/unit_test/unit_test_template.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';
import 'package:flutter_test_gen/src/utils/test_utils.dart';

class TestGroupBuilder {
  final ProjectUtil project;
  final TestCaseBuilder caseBuilder;

  TestGroupBuilder(this.project) : caseBuilder = TestCaseBuilder(project);

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
