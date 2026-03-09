import 'dart:io';

import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/models/method_parameter.dart';
import 'package:flutter_test_gen/src/templates/test_template.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

class TestWriter {
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

      if (_testExists(updated, method.methodName)) continue;

      final groupName = method.isTopLevel
          ? 'Functions | $relativePath'
          : '${method.className} | $relativePath';

      final testCode = _generateAppendTest(method);

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

  bool _testExists(String content, String methodName) {
    final escaped = RegExp.escape(methodName);

    final pattern = RegExp(
      "(test|testWidgets)\\s*\\(\\s*['\"]$escaped['\"]",
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

  String _generateAppendTest(MethodInfo method) {
    final arrange = _generateArrange(method.parameters);
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

  String _generateArrange(List<MethodParameter> params) {
    if (params.isEmpty) return '';

    final buffer = StringBuffer();

    for (final param in params) {
      buffer.writeln(
        '      final ${param.name} = ${ProjectUtil().generateValue(param)};',
      );
    }

    return buffer.toString();
  }

  String _generateCallParams(List<MethodParameter> params) {
    if (params.isEmpty) return '';

    return params.map((p) {
      if (p.isNamed) return '${p.name}: ${p.name}';
      return p.name;
    }).join(', ');
  }
}
