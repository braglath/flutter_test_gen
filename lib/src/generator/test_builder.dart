import 'package:flutter_test_gen/src/di/dependency_resolver.dart';
import 'package:flutter_test_gen/src/di/mock_generator.dart';
import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/models/method_parameter.dart';
import 'package:flutter_test_gen/src/resolver/import_resolver.dart';
import 'package:flutter_test_gen/src/templates/test_template.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

class TestBuilder {
  final ProjectUtil project;
  final ImportResolver resolver;

  final Set<String> _imports = {};

  List<String> get generatedImports => _imports.toList();

  TestBuilder(this.project) : resolver = ImportResolver(project);

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

      for (final dep in method.dependencies) {
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

      final List<Dependency> dependencies =
          className == '__top_level__' ? [] : methodList.first.dependencies;

      groups.write(
        TestTemplates.group(
          groupName: className == '__top_level__'
              ? 'Functions | $relativePath'
              : '$className | $relativePath',
          className: className,
          tests: tests.toString(),
          isTopLevel: className == '__top_level__',
          dependencies: dependencies,
        ),
      );
    });

    final mockClasses =
        MockGenerator.generateMockClasses(dependencies.toList());

    final mockVariables =
        MockGenerator.generateMockVariables(dependencies.toList());

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

    final call = method.isTopLevel
        ? '${method.methodName}($params)'
        : method.isStatic
            ? '${method.className}.${method.methodName}($params)'
            : 'service.${method.methodName}($params)';

    final expectedValue = ProjectUtil().primitiveValue(method.returnType);

    final verifyCall = method.dependencies.isEmpty
        ? ''
        : method.dependencies.map((dep) {
            final mockVar =
                'mock${dep.type[0].toUpperCase()}${dep.type.substring(1)}';
            return '      verify(() => $mockVar.${method.methodName}()).called(1);';
          }).join('\n');

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

    final params = method.parameters;

    // Generate parameter values
    for (final param in params) {
      buffer.writeln(
        '      final ${param.name} = ${ProjectUtil().generateValue(param)};',
      );
    }

    // Generate mock stubs
    for (final dep in method.dependencies) {
      if (dep.type == method.className) continue;

      final mockVar =
          'mock${dep.type[0].toUpperCase()}${dep.type.substring(1)}';

      final stub = ProjectUtil().mockReturnValue(method.returnType);

      if (method.returnType != 'void') {
        buffer.writeln(
          '      when(() => $mockVar.${method.methodName}()).$stub;',
        );
      }
    }

    return buffer.toString();
  }

  String _generateCallParams(List<MethodParameter> params) => params.map((p) {
        if (p.isNamed) return '${p.name}: ${p.name}';
        return p.name;
      }).join(', ');

  bool _shouldSkip(MethodInfo method) {
    if (method.methodName.startsWith('_')) return true;
    if (method.className.endsWith('Mixin')) return true;
    if (method.className.contains('Ext')) return true;
    return false;
  }
}
