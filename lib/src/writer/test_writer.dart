import 'dart:io';

import 'package:flutter_test_gen/src/generator/test_builder.dart';
import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

/// Responsible for writing or updating generated test files.
///
/// [TestWriter] handles different generation modes such as:
/// - creating a new test file
/// - appending new tests to an existing file
/// - overwriting an existing file
///
/// It also ensures duplicate tests are not generated and restores
/// missing imports when updating test files.
class TestWriter {
  final ProjectUtil project;
  TestWriter(this.project);

  /// Processes test generation and returns the updated test content.
  ///
  /// Parameters:
  /// - [file]: The test file to be written or updated.
  /// - [existing]: The existing content of the test file.
  /// - [content]: The newly generated test content.
  /// - [methods]: List of detected methods used to generate tests.
  /// - [relativePath]: Relative path of the source file used for grouping tests.
  /// - [append]: If true, new tests will be appended to the existing file.
  /// - [overwrite]: If true, the existing test file will be completely replaced.
  /// - [imports]: List of imports required for the generated tests.
  ///
  /// Behavior:
  /// - If the file does not exist, the generated [content] is returned.
  /// - If [overwrite] is true, existing content is replaced.
  /// - If [append] is true, missing tests are appended to existing groups.
  /// - If neither append nor overwrite is enabled, no changes are made.
  ///
  /// Returns the updated test file content or `null` if no update is required.
  String? process({
    required File file,
    required String existing,
    required String content,
    required List<MethodInfo> methods,
    required String relativePath,
    required bool append,
    required bool overwrite,
    required List<String> imports,
  }) {
    if (!file.existsSync()) return content;

    if (existing.trim().isEmpty) return content;

    if (overwrite) return content;

    if (!append) return null;

    var updated = existing;
    bool changed = false;

    for (final method in methods) {
      if (_shouldSkip(method)) continue;

      if (testExists(existing, method.methodName)) continue;

      final cleanPath = relativePath.replaceFirst('lib/', '');

      final groupName = method.isTopLevel
          ? 'Functions ($cleanPath)'
          : '${method.className} ($cleanPath)';

      final builder = TestBuilder(project);
      final testCode = builder.generateSingleTest(
        method,
      );

      /// Existing group
      if (updated.contains("group('$groupName'")) {
        final start = updated.indexOf("group('$groupName'");
        final end = _findGroupEnd(updated, start);

        if (end == -1) continue;

        final block = updated.substring(start, end);

        final insertIndex = block.lastIndexOf('}');

        if (insertIndex == -1) continue;

        final newBlock =
            '${block.substring(0, insertIndex)}\n$testCode\n${block.substring(insertIndex)}';

        updated =
            updated.substring(0, start) + newBlock + updated.substring(end);
      } else {
        if (updated.contains("group('$groupName'")) {
          continue;
        }

        /// create new group
        final index = updated.lastIndexOf('}');

        updated = '${updated.substring(0, index)}\n'
            "  group('$groupName', () {\n"
            '$testCode\n'
            '  });\n'
            '}';
      }

      changed = true;
    }

    if (!changed) return existing;

    updated = _restoreMissingImports(updated, imports);

    return updated;
  }

  bool _shouldSkip(MethodInfo method) {
    if (method.methodName.startsWith('_')) return true;
    if (method.className.endsWith('Mixin')) return true;
    if (method.className.contains('Ext')) return true;
    return false;
  }

  /// Checks whether a test already exists for the given [methodName]
  /// within the provided test file [content].
  ///
  /// This method searches for `test()` or `testWidgets()` declarations
  /// whose test description contains the method name. It helps prevent
  /// duplicate test generation when the generator runs in append mode.
  ///
  /// Example matched tests:
  /// ```dart
  /// test('isLong', () { ... });
  /// test('returns bool when isLong succeeds', () { ... });
  /// testWidgets('should validate isLong', (tester) async { ... });
  /// ```
  ///
  /// Parameters:
  /// - [content]: The existing test file content.
  /// - [methodName]: The method name being checked.
  ///
  /// Returns `true` if a matching test is found, otherwise `false`.
  static bool testExists(String content, String methodName) {
    final escaped = RegExp.escape(methodName);

    final pattern = RegExp(
      "(test|testWidgets)\\s*\\(\\s*['\"][^'\"]*\\b$escaped\\b[^'\"]*['\"]",
      multiLine: true,
    );

    return pattern.hasMatch(content);
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

  // String _generateAppendTest(MethodInfo method) {
  //   final arrange = _generateArrange(method);
  //   final params = _generateCallParams(method.parameters);

  //   final call = method.isTopLevel
  //       ? '${method.methodName}($params)'
  //       : method.isStatic
  //           ? '${method.className}.${method.methodName}($params)'
  //           : 'service.${method.methodName}($params)';

  //   final verifyCall = method.propertyAccesses.isEmpty
  //       ? ''
  //       : method.propertyAccesses.map((access) {
  //           final mockVar = _mockVar(access.target);
  //           final args =
  //               access.args.isEmpty ? '' : '(${access.args.join(', ')})';

  //           return '      verify(() => $mockVar.${access.property}$args).called(1);';
  //         }).join('\n');

  //   String returnType = method.returnType.replaceAll('?', '');

  //   if (returnType.startsWith('Future<')) {
  //     returnType = returnType.replaceFirst('Future<', '').replaceFirst('>', '');
  //   }

  //   final expectedValue = project.isPrimitive(returnType)
  //       ? project.primitiveValueForAssert(returnType)
  //       : 'isA<$returnType>()';

  //   final testName = project.buildTestName(method, returnType);

  //   return TestTemplates.test(
  //     name: testName,
  //     arrange: arrange,
  //     call: call,
  //     expectedValue: expectedValue,
  //     verifyCall: verifyCall,
  //     isAsync: method.isAsync,
  //     isVoid: method.isVoid,
  //   );
  // }

  String _restoreMissingImports(
    String content,
    List<String> imports,
  ) {
    var updated = content;

    for (final import in imports) {
      if (updated.contains(import)) continue;

      final matches = RegExp(r"import\s+'[^']+';").allMatches(updated);

      final int insertIndex = matches.isEmpty ? 0 : matches.last.end;

      updated =
          '${updated.substring(0, insertIndex)}\n$import${updated.substring(insertIndex)}';
    }

    return updated;
  }

  // String _generateArrange(MethodInfo method) {
  //   if (method.parameters.isEmpty && method.propertyAccesses.isEmpty) {
  //     return '';
  //   }

  //   final buffer = StringBuffer();

  //   /// -------------------------
  //   /// Parameters
  //   /// -------------------------
  //   for (final param in method.parameters) {
  //     final dep = method.parameterDependencies.firstWhere(
  //       (d) => d.name == param.name,
  //       orElse: () => Dependency('', ''),
  //     );

  //     if (dep.name.isNotEmpty) {
  //       final mockVar = _mockVar(dep.name);
  //       buffer.writeln('      final ${param.name} = $mockVar;');
  //     } else {
  //       buffer.writeln(
  //         '      final ${param.name} = ${project.generateValue(param)};',
  //       );
  //     }
  //   }

  //   /// -------------------------
  //   /// Stub dependency calls (FIXED)
  //   /// -------------------------
  //   final seen = <String>{};

  //   for (final access in method.propertyAccesses) {
  //     final key = '${access.target}.${access.property}';
  //     if (!seen.add(key)) continue;

  //     final mockVar = _mockVar(access.target);

  //     /// ✅ Preserve args
  //     final args = access.args.isEmpty ? '' : '(${access.args.join(', ')})';

  //     /// ✅ Detect return type
  //     String returnType = access.returnType ?? '';

  //     /// 🔥 Fallback using dependency inference
  //     if (returnType.isEmpty || returnType == 'dynamic') {
  //       final dep = method.constructorDependencies.firstWhere(
  //         (d) => d.name.toLowerCase() == access.target.toLowerCase(),
  //         orElse: () => Dependency('', ''),
  //       );

  //       if (dep.type.endsWith('Repository')) {
  //         final inferred = dep.type.replaceAll('Repository', '').trim();

  //         returnType = 'Future<$inferred>';
  //       }
  //     }

  //     if (returnType.startsWith('Future<')) {
  //       final inner =
  //           returnType.replaceFirst('Future<', '').replaceFirst('>', '');

  //       final resolver = DependencyResolver();
  //       final fields = resolver.resolveConstructorFields(inner, imports);

  //       final value = fields.isEmpty
  //           ? project.primitiveValueForMock(inner)
  //           : project.buildObject(inner, fields);

  //       buffer.writeln(
  //         '      when(() => $mockVar.${access.property}$args)'
  //         '.thenAnswer((_) async => $value);',
  //       );
  //     } else {
  //       final value = project.primitiveValueForMock(returnType);

  //       buffer.writeln(
  //         '      when(() => $mockVar.${access.property}$args)'
  //         '.thenReturn($value);',
  //       );
  //     }
  //   }

  //   return buffer.toString();
  // }

  // String _generateCallParams(List<MethodParameter> params) {
  //   if (params.isEmpty) return '';

  //   return params.map((p) {
  //     if (p.isNamed) return '${p.name}: ${p.name}';
  //     return p.name;
  //   }).join(', ');
  // }

  // String _mockVar(String name) {
  //   final cap = name[0].toUpperCase() + name.substring(1);
  //   return 'mock$cap';
  // }
}
