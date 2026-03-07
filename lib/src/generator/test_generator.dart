import 'dart:io';

import '../models/method_info.dart';
import '../models/method_parameter.dart';
import '../parser/dart_parser.dart';
import '../utils/project_utils.dart';

class TestGenerator {
  final Map<String, String?> _importCache = {};
  List<String> _lastGeneratedImports = [];

  Future<void> generate(
    String filePath, {
    bool append = true,
    bool overwrite = false,
  }) async {
    final parser = DartParser();
    final methods = parser.extractMethods(filePath);

    if (methods.isEmpty) {
      print("No methods found.");
      return;
    }

    final testPath = filePath
        .replaceFirst("lib", "test")
        .replaceAll(".dart", "_test.dart");

    final projectRoot = findProjectRoot(filePath);
    final projectName = getProjectName(projectRoot);
    final importPath = generateImportPath(filePath, projectRoot, projectName);
    final relativePath = _relativePath(filePath);

    final file = File(testPath);
    final existing = file.existsSync() ? await file.readAsString() : "";

    final content = _generateTests(
      methods,
      importPath,
      relativePath,
      existing,
      projectRoot,
      projectName,
      filePath,
    );

    /// Create new file
    if (!file.existsSync()) {
      await file.create(recursive: true);
      await file.writeAsString(content);

      print("✓ Generated: ${_relativePath(testPath)}");
      return;
    }

    /// Empty file
    if (existing.trim().isEmpty) {
      await file.writeAsString(content);

      print("✓ Generated: ${_relativePath(testPath)}");
      return;
    }

    /// Overwrite mode
    if (overwrite) {
      await file.writeAsString(content);

      print("✓ Overwritten: ${_relativePath(testPath)}");
      return;
    }

    /// Append mode
    if (append) {
      var updated = existing;
      bool changed = false;

      for (var method in methods) {
        if (_shouldSkip(method)) continue;

        final testName = "test('${method.methodName}'";

        if (existing.contains(testName)) continue;

        final groupName = method.className == "__top_level__"
            ? "Functions | $relativePath"
            : "${method.className} | $relativePath";

        final testCode = _generateSingleTest(method);

        /// Existing group
        if (updated.contains("group('$groupName'")) {
          final groupStart = updated.indexOf("group('$groupName'");
          final groupEnd = _findGroupEnd(updated, groupStart);

          if (groupEnd == -1) continue;

          final groupBlock = updated.substring(groupStart, groupEnd);
          final insertIndex = groupBlock.lastIndexOf("}");

          if (insertIndex == -1) continue;

          final newGroupBlock =
              "${groupBlock.substring(0, insertIndex)}\n$testCode\n${groupBlock.substring(insertIndex)}";

          updated =
              updated.substring(0, groupStart) +
              newGroupBlock +
              updated.substring(groupEnd);
        } else {
          /// Create new group
          final index = updated.lastIndexOf("}");

          updated =
              "${updated.substring(0, index)}\n"
              "  group('$groupName', () {\n"
              "$testCode\n"
              "  });\n"
              "}";
        }

        changed = true;
      }

      if (!changed) {
        print("✓ No new tests to append.");
        return;
      }

      /// Restore missing imports
      for (final import in _lastGeneratedImports) {
        if (!updated.contains(import)) {
          final matches = RegExp(
            "import\\s+['\\\"].*['\\\"];",
          ).allMatches(updated);

          int insertIndex = 0;

          if (matches.isNotEmpty) {
            insertIndex = matches.last.end;
          }

          updated =
              "${updated.substring(0, insertIndex)}\n$import${updated.substring(insertIndex)}";
        }
      }

      await file.writeAsString(updated);

      print("✓ Appended tests: ${_relativePath(testPath)}");
    }
  }

  int _findGroupEnd(String content, int startIndex) {
    int braceCount = 0;
    bool started = false;

    for (int i = startIndex; i < content.length; i++) {
      if (content[i] == '{') {
        braceCount++;
        started = true;
      }

      if (content[i] == '}') {
        braceCount--;

        if (started && braceCount == 0) {
          return i + 1;
        }
      }
    }

    return -1;
  }

  bool _shouldSkip(MethodInfo method) {
    if (method.methodName.startsWith('_')) return true;
    if (method.className.endsWith("Mixin")) return true;
    if (method.className.contains("Ext")) return true;
    return false;
  }

  String _generateSingleTest(MethodInfo method) {
    final asyncKeyword = method.isAsync ? "async" : "";
    final awaitKeyword = method.isAsync ? "await " : "";

    final arrange = _generateArrange(method.parameters);
    final params = _generateCallParams(method.parameters);

    String call;

    if (method.className == "__top_level__") {
      call = "${method.methodName}($params)";
    } else if (method.isStatic) {
      call = "${method.className}.${method.methodName}($params)";
    } else {
      call = "service.${method.methodName}($params)";
    }

    if (method.returnType == "void") {
      return """
    test('${method.methodName}', () $asyncKeyword {

      // Arrange
$arrange

      // Act
      $call;

      // Assert
      // TODO: verify behaviour

    });
""";
    }

    return """
    test('${method.methodName}', () $asyncKeyword {

      // Arrange
$arrange

      // Act
      final result = $awaitKeyword$call;

      // Assert
      expect(result, isNotNull);

    });
""";
  }

  String _generateArrange(List<MethodParameter> params) {
    if (params.isEmpty) return "";

    final buffer = StringBuffer();

    for (var param in params) {
      final value = _generateValue(param.type);

      buffer.writeln("      final ${param.name} = $value;");
    }

    return buffer.toString();
  }

  String _generateCallParams(List<MethodParameter> params) {
    if (params.isEmpty) return "";

    return params
        .map((p) {
          if (p.isNamed) {
            return "${p.name}: ${p.name}";
          }
          return p.name;
        })
        .join(", ");
  }

  String _generateTests(
    List<MethodInfo> methods,
    String importPath,
    String relativePath,
    String existing,
    String projectRoot,
    String projectName,
    String sourceFilePath,
  ) {
    final Map<String, List<MethodInfo>> classMethods = {};
    final imports = <String>{};

    for (var method in methods) {
      final returnImport = _resolveImport(
        method.returnType,
        projectRoot,
        projectName,
        sourceFilePath,
      );

      if (returnImport != null) imports.add(returnImport);

      for (var param in method.parameters) {
        final paramImport = _resolveImport(
          param.type,
          projectRoot,
          projectName,
          sourceFilePath,
        );

        if (paramImport != null) imports.add(paramImport);
      }

      if (_shouldSkip(method)) continue;

      classMethods.putIfAbsent(method.className, () => []);
      classMethods[method.className]!.add(method);
    }

    String groups = "";

    classMethods.forEach((className, classMethodList) {
      String tests = "";

      for (var method in classMethodList) {
        if (existing.contains("test('${method.methodName}'")) continue;

        tests += _generateSingleTest(method);
      }

      if (tests.isEmpty) return;

      if (className == "__top_level__") {
        groups +=
            """

  group('Functions | $relativePath', () {
$tests
  });
""";
      } else {
        groups +=
            """

  group('$className | $relativePath', () {
    late $className service;

    setUp(() {
      service = $className();
    });

$tests
  });
""";
      }
    });

    _lastGeneratedImports = imports.toList();

    return """
import 'package:flutter_test/flutter_test.dart';
import '$importPath';
${imports.join('\n')}

void main() {
$groups
}
""";
  }

  String? _resolveImport(
    String type,
    String projectRoot,
    String projectName,
    String sourceFilePath,
  ) {
    final cleanType = type
        .replaceAll('?', '')
        .replaceAll(RegExp(r'<.*>'), '')
        .trim();

    if (_isPrimitive(cleanType)) return null;

    if (_importCache.containsKey(cleanType)) {
      return _importCache[cleanType];
    }

    final import = _findImportForType(
      cleanType,
      projectRoot,
      projectName,
      sourceFilePath,
    );

    _importCache[cleanType] = import;

    return import;
  }

  String? _findImportForType(
    String type,
    String projectRoot,
    String projectName,
    String sourceFilePath,
  ) {
    final libDir = Directory('$projectRoot/lib');

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File) continue;

      if (!entity.path.endsWith('.dart')) continue;

      if (entity.path == sourceFilePath) continue;

      final content = entity.readAsStringSync();

      final classPattern = RegExp(r'class\s+' + type + r'(\s|{|<)');

      if (classPattern.hasMatch(content)) {
        final relativePath = entity.path.split('lib/').last;
        return "import 'package:$projectName/$relativePath';";
      }
    }

    return null;
  }

  String _generateParams(List<MethodParameter> params) {
    if (params.isEmpty) return "";
    return params.map((p) => _generateValue(p.type)).join(", ");
  }

  String _generateValue(String type) {
    final cleanType = type.replaceAll('?', '').trim();

    switch (cleanType) {
      case "int":
        return "1";

      case "String":
        return "'test'";

      case "bool":
        return "true";

      case "double":
        return "1.0";

      case "DateTime":
        return "DateTime.now()";

      case "List":
        return "[]";

      case "Map":
        return "{}";

      default:
        return "$cleanType()";
    }
  }

  bool _isPrimitive(String type) {
    const primitives = {
      'int',
      'double',
      'String',
      'bool',
      'dynamic',
      'void',
      'num',
      'Object',
      'DateTime',
      'List',
      'Map',
      'Set',
      'Iterable',
      'Future',
    };

    return primitives.contains(type);
  }

  String _relativePath(String absolutePath) {
    final root = Directory.current.path;

    if (absolutePath.startsWith(root)) {
      return absolutePath.substring(root.length + 1);
    }

    return absolutePath;
  }
}
