import 'dart:io';

import '../models/method_info.dart';
import '../models/method_parameter.dart';
import '../parser/dart_parser.dart';
import '../utils/project_utils.dart';

class TestGenerator {
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

    final content = _generateTests(methods, importPath, relativePath, existing);

    // create file if it doesn't exist
    if (!file.existsSync()) {
      await file.create(recursive: true);
      await file.writeAsString(content);

      print("✓ Generated: ${_relativePath(testPath)}");
      return;
    }

    // if file is empty
    if (existing.trim().isEmpty) {
      await file.writeAsString(content);

      print("✓ Generated: ${_relativePath(testPath)}");
      return;
    }

    // overwrite
    if (overwrite) {
      await file.writeAsString(content);

      print("✓ Overwritten: ${_relativePath(testPath)}");
      return;
    }

    // append mode
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

        if (updated.contains("group('$groupName'")) {
          final groupStart = updated.indexOf("group('$groupName'");
          final groupEnd = _findGroupEnd(updated, groupStart);

          if (groupEnd == -1) {
            continue; // skip malformed group
          }

          final groupBlock = updated.substring(groupStart, groupEnd);

          final insertIndex = groupBlock.lastIndexOf("}");

          if (insertIndex == -1) {
            continue;
          }

          final newGroupBlock =
              "${groupBlock.substring(0, insertIndex)}\n$testCode\n${groupBlock.substring(insertIndex)}";

          updated =
              updated.substring(0, groupStart) +
              newGroupBlock +
              updated.substring(groupEnd);
        } else {
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
    final params = _generateParams(method.parameters);

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

      // Act
      final result = $awaitKeyword$call;

      // Assert
      expect(result, isNotNull);

    });
""";
  }

  String _generateTests(
    List<MethodInfo> methods,
    String importPath,
    String relativePath,
    String existing,
  ) {
    final Map<String, List<MethodInfo>> classMethods = {};

    for (var method in methods) {
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

    return """
import 'package:flutter_test/flutter_test.dart';
import '$importPath';

void main() {
$groups
}
""";
  }

  String _generateParams(List<MethodParameter> params) {
    if (params.isEmpty) return "";

    return params.map((p) => _generateValue(p.type)).join(", ");
  }

  String _generateValue(String type) {
    switch (type) {
      case "int":
        return "1";

      case "String":
        return "'test'";

      case "bool":
        return "true";

      case "double":
        return "1.0";

      case "List":
        return "[]";

      case "Map":
        return "{}";

      default:
        return "null";
    }
  }

  String _relativePath(String absolutePath) {
    final root = Directory.current.path;

    if (absolutePath.startsWith(root)) {
      return absolutePath.substring(root.length + 1);
    }

    return absolutePath;
  }
}
