import 'package:flutter_test_gen/flutter_test_gen.dart';
import 'package:flutter_test_gen/src/analyzer/dependency/dependency_analyzer.dart';
import 'package:flutter_test_gen/src/analyzer/import/import_resolver.dart';
import 'package:flutter_test_gen/src/generator/mock/mock_generator.dart';
import 'package:flutter_test_gen/src/generator/test/test_group_builder.dart';
import 'package:flutter_test_gen/src/templates/unit_test/unit_test_template.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

class TestFileBuilder {
  final ProjectUtil project;
  final ImportResolver resolver;

  final Set<String> _imports = {};

  Set<String> get generatedImports => _imports.toSet();

  TestFileBuilder(this.project) : resolver = ImportResolver(project);

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
