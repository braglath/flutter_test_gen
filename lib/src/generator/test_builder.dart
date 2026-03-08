import '../models/method_info.dart';
import '../models/method_parameter.dart';
import '../resolver/import_resolver.dart';
import '../templates/test_template.dart';
import '../utils/project_utils.dart';

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

    for (final method in methods) {
      if (_shouldSkip(method)) continue;

      resolver.collectImports(method, sourceFilePath, _imports);

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

      groups.write(
        TestTemplates.group(
          groupName: className == "__top_level__"
              ? "Functions | $relativePath"
              : "$className | $relativePath",
          className: className,
          tests: tests.toString(),
          isTopLevel: className == "__top_level__",
        ),
      );
    });

    return TestTemplates.file(
      importPath: importPath,
      imports: _imports.join('\n'),
      groups: groups.toString(),
    );
  }

  String _generateSingleTest(MethodInfo method) {
    final arrange = _generateArrange(method.parameters);
    final params = _generateCallParams(method.parameters);

    final call = method.isTopLevel
        ? "${method.methodName}($params)"
        : method.isStatic
            ? "${method.className}.${method.methodName}($params)"
            : "service.${method.methodName}($params)";

    return TestTemplates.test(
      name: method.methodName,
      arrange: arrange,
      call: call,
      isAsync: method.isAsync,
      isVoid: method.isVoid,
    );
  }

  String _generateArrange(List<MethodParameter> params) {
    if (params.isEmpty) return "";

    final buffer = StringBuffer();

    for (final param in params) {
      buffer.writeln(
        "      final ${param.name} = ${ProjectUtil().generateValue(param)};",
      );
    }

    return buffer.toString();
  }

  String _generateCallParams(List<MethodParameter> params) {
    return params.map((p) {
      if (p.isNamed) return "${p.name}: ${p.name}";
      return p.name;
    }).join(", ");
  }

  bool _shouldSkip(MethodInfo method) {
    if (method.methodName.startsWith('_')) return true;
    if (method.className.endsWith("Mixin")) return true;
    if (method.className.contains("Ext")) return true;
    return false;
  }
}
