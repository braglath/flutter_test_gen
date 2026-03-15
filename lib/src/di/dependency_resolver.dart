import 'package:analyzer/dart/ast/ast.dart';

/// Represents a dependency injected into a class through its constructor.
///
/// Each dependency contains the parameter [name] used in the constructor
/// and its corresponding Dart [type].
class Dependency {
  /// The name of the dependency parameter.
  final String name;

  /// The Dart type of the dependency.
  final String type;

  /// Creates a new [Dependency] with the given [name] and [type].
  Dependency(this.name, this.type);
}

/// Utility class responsible for resolving constructor dependencies
/// from a Dart class using the analyzer AST.
///
/// This is mainly used for detecting injected dependencies so that
/// corresponding mock objects can be generated for unit tests.
class DependencyResolver {
  /// Extracts constructor dependencies from the given [clazz].
  ///
  /// This method inspects all constructors of the class and collects
  /// parameters that represent injected dependencies.
  ///
  /// Supported constructor patterns:
  /// - `Constructor(Type repository)`
  /// - `Constructor(this.repository)`
  /// - Named parameters
  ///
  /// Primitive types (such as `int`, `String`, etc.) are ignored because
  /// they are typically not mocked in unit tests.
  ///
  /// Returns a list of detected [Dependency] objects.
  static List<Dependency> resolve(ClassDeclaration clazz) {
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
}
