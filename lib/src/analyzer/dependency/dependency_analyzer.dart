// ignore_for_file: file_names

import 'package:analyzer/dart/ast/ast.dart';

/// Represents a dependency injected into a class through its constructor.
class Dependency {
  final String name;
  final String type;

  Dependency(this.name, this.type);
}

/// Analyzes a class and extracts only the dependencies
/// that should be mocked in tests.
///
/// Responsibilities:
/// - Extract constructor dependencies
/// - Filter primitives
/// - Filter sealed classes
class DependencyAnalyzer {
  /// Main entry point
  static List<Dependency> analyze(
    ClassDeclaration clazz,
    CompilationUnit unit,
  ) {
    final rawDeps = _extract(clazz);
    return _filter(rawDeps, unit);
  }

  /// STEP 1: Extract dependencies from constructor
  static List<Dependency> _extract(ClassDeclaration clazz) {
    final dependencies = <Dependency>[];
    final seen = <String>{};

    for (final entity in clazz.members) {
      if (entity is! ConstructorDeclaration) continue;

      for (final param in entity.parameters.parameters) {
        if (param is SimpleFormalParameter) {
          final name = param.name?.lexeme ?? '';
          final type = param.type?.toSource() ?? '';

          if (_valid(name, type) && seen.add(type)) {
            dependencies.add(Dependency(name, type));
          }
        }

        if (param is FieldFormalParameter) {
          final name = param.name.lexeme;

          String? type = param.type?.toSource();
          type ??= _findFieldType(clazz, name);

          if (type != null && _valid(name, type) && seen.add(type)) {
            dependencies.add(Dependency(name, type));
          }
        }

        if (param is DefaultFormalParameter) {
          final inner = param.parameter;

          if (inner is SimpleFormalParameter) {
            final name = inner.name?.lexeme ?? '';
            final type = inner.type?.toSource() ?? '';

            if (_valid(name, type) && seen.add(type)) {
              dependencies.add(Dependency(name, type));
            }
          }

          if (inner is FieldFormalParameter) {
            final name = inner.name.lexeme;

            String? type = inner.type?.toSource();
            type ??= _findFieldType(clazz, name);

            if (type != null && _valid(name, type) && seen.add(type)) {
              dependencies.add(Dependency(name, type));
            }
          }
        }
      }
    }

    return dependencies;
  }

  /// STEP 2: Filter dependencies
  static List<Dependency> _filter(
    List<Dependency> deps,
    CompilationUnit unit,
  ) {
    final result = <Dependency>[];

    for (final dep in deps) {
      if (_isPrimitive(dep.type)) continue;
      if (_isSealed(dep.type, unit)) continue;

      result.add(dep);
    }

    return result;
  }

  static bool _valid(String name, String type) =>
      name.isNotEmpty && type.isNotEmpty && !_isPrimitive(type);

  static String? _findFieldType(ClassDeclaration clazz, String fieldName) {
    for (final entity in clazz.members) {
      if (entity is! FieldDeclaration) continue;

      final type = entity.fields.type?.toSource();

      for (final variable in entity.fields.variables) {
        if (variable.name.lexeme == fieldName) {
          return type ?? 'dynamic';
        }
      }
    }

    return null;
  }

  static bool _isPrimitive(String type) => const {
        'int',
        'double',
        'bool',
        'String',
        'num',
        'dynamic',
        'DateTime',
      }.contains(type);

  static bool _isSealed(String type, CompilationUnit unit) {
    for (final decl in unit.declarations) {
      if (decl is ClassDeclaration) {
        if (decl.name.lexeme == type) {
          return decl.sealedKeyword != null;
        }
      }
    }

    return false;
  }
}
