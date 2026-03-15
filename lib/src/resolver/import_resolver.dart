import 'dart:io';

import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

/// Resolves and collects required imports for generated test files.
///
/// [ImportResolver] analyzes method metadata and determines which
/// imports are necessary for the generated tests to compile correctly.
/// It ensures that all referenced types such as return types,
/// parameter types, and dependency types are properly imported.
class ImportResolver {
  /// Provides project-specific utilities used for resolving imports
  /// and identifying types within the project.
  final ProjectUtil project;

  final Map<String, String?> _cache = {};

  /// Creates a new [ImportResolver] for the given [project].
  ///
  /// The [project] utility helps determine the correct import paths
  /// for different types referenced during test generation.
  ImportResolver(this.project);

  /// Collects required imports for the provided [method].
  ///
  /// This method analyzes the method's metadata and adds necessary
  /// import statements to the [imports] set.
  ///
  /// Parameters:
  /// - [method]: The method metadata used to determine referenced types.
  /// - [sourceFilePath]: The path of the source file currently being processed.
  /// - [imports]: A set that accumulates required import statements.
  ///
  /// Duplicate imports are automatically avoided because [imports]
  /// is maintained as a `Set`.
  void collectImports(
    MethodInfo method,
    String sourceFilePath,
    Set<String> imports,
  ) {
    for (final param in method.parameters) {
      final type = param.type.replaceAll('?', '');

      // if (ProjectUtil().isEnumType(type)) {
      if (param.isEnum) {
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

  /// Attempts to resolve and add the correct import for a given Dart [type].
  ///
  /// This method scans Dart files within the same directory (and its
  /// subdirectories) as the source file to locate a class definition
  /// matching the provided [type]. Once the class is found, the method
  /// generates the corresponding `package:` import path and adds it
  /// to the provided [imports] set.
  ///
  /// This is mainly used when the generator detects types that are
  /// referenced in the generated test (such as sealed class subclasses)
  /// but are not already part of the collected imports.
  ///
  /// Example:
  /// ```dart
  /// final error = const UserNotFound();
  /// ```
  ///
  /// If the generator detects `UserNotFound`, this method will search
  /// for a file containing:
  ///
  /// ```dart
  /// class UserNotFound
  /// ```
  ///
  /// Once located, it will add an import similar to:
  ///
  /// ```dart
  /// import 'package:my_app/errors/user_error.dart';
  /// ```
  ///
  /// Parameters:
  /// - [type]: The class name that needs to be imported.
  /// - [sourceFilePath]: The path of the source file currently being analyzed.
  /// - [imports]: The collection of imports where the resolved import will be added.
  ///
  /// Note:
  /// - The method performs a simple string search for `class <type>`
  ///   within Dart files.
  /// - This approach works well for most cases but may not detect
  ///   classes declared using alternative patterns (e.g. typedefs,
  ///   mixins, or generated code).
  void collectImportsForType(
    String type,
    String sourceFilePath,
    Set<String> imports,
  ) {
    final file = File(sourceFilePath);
    final dir = file.parent;

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = entity.readAsStringSync();

        if (content.contains('class $type')) {
          final import = project.generateImportPath(entity.path);
          imports.add("import '$import';");
          break;
        }
      }
    }
  }
}
