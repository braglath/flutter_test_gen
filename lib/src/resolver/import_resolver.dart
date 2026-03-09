import 'dart:io';

import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

class ImportResolver {
  final ProjectUtil project;

  final Map<String, String?> _cache = {};

  ImportResolver(this.project);

  void collectImports(
    MethodInfo method,
    String sourceFilePath,
    Set<String> imports,
  ) {
    for (final param in method.parameters) {
      final type = param.type.replaceAll('?', '');

      if (ProjectUtil().isEnumType(type)) {
        final import = _resolveImport(type, sourceFilePath);

        if (import != null) {
          imports.add("import '$import';");
        }
      }
    }

    final returnImport = _resolveImport(method.returnType, sourceFilePath);

    if (returnImport != null) {
      imports.add("import '$returnImport';");
    }

    for (final param in method.parameters) {
      final paramImport = _resolveImport(param.type, sourceFilePath);

      if (paramImport != null) {
        imports.add("import '$paramImport';");
      }
    }
  }

  String? _resolveImport(String type, String sourceFilePath) {
    final cleanType =
        type.replaceAll('?', '').replaceAll(RegExp(r'<.*>'), '').trim();

    if (_isPrimitive(cleanType)) return null;

    if (_cache.containsKey(cleanType)) {
      return _cache[cleanType];
    }

    final import = _findImportForType(cleanType, sourceFilePath);

    _cache[cleanType] = import;

    return import;
  }

  String? _findImportForType(String type, String sourceFilePath) {
    final libDir = Directory('${project.projectRoot}/lib');

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.dart')) continue;
      if (entity.path == sourceFilePath) continue;

      final content = entity.readAsStringSync();

      final pattern = RegExp(
        r'(class|enum|mixin|typedef)\s+' + type + r'(\s|{|<)',
      );

      if (pattern.hasMatch(content)) {
        final relativePath = entity.path.split('lib/').last;

        return 'package:${project.projectName}/$relativePath';
      }
    }

    return null;
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
}
