import 'package:analyzer/dart/ast/ast.dart';

class Dependency {
  final String name;
  final String type;

  Dependency(this.name, this.type);
}

class DependencyResolver {
  static List<Dependency> resolve(ClassDeclaration clazz) {
    final dependencies = <Dependency>[];

    for (final member in clazz.members) {
      if (member is ConstructorDeclaration) {
        for (final param in member.parameters.parameters) {
          // Case: Constructor(Type repository)
          if (param is SimpleFormalParameter) {
            final name = param.name?.lexeme ?? '';
            final type = param.type?.toSource() ?? '';

            if (name.isNotEmpty && type.isNotEmpty && !_isPrimitive(type)) {
              dependencies.add(Dependency(name, type));
            }
          }

          // Case: Constructor(this.repository)
          if (param is FieldFormalParameter) {
            final name = param.name.lexeme;

            String? type = param.type?.toSource();

            // If type not declared in constructor, find it from class fields
            type ??= _findFieldType(clazz, name);

            if (name.isNotEmpty && type != null && !_isPrimitive(type)) {
              dependencies.add(Dependency(name, type));
            }
          }

          // Case: named parameters
          if (param is DefaultFormalParameter) {
            final inner = param.parameter;

            if (inner is SimpleFormalParameter) {
              final name = inner.name?.lexeme ?? '';
              final type = inner.type?.toSource() ?? '';

              if (name.isNotEmpty && type.isNotEmpty && !_isPrimitive(type)) {
                dependencies.add(Dependency(name, type));
              }
            }

            if (inner is FieldFormalParameter) {
              final name = inner.name.lexeme;

              String? type = inner.type?.toSource();
              type ??= _findFieldType(clazz, name);

              if (name.isNotEmpty && type != null && !_isPrimitive(type)) {
                dependencies.add(Dependency(name, type));
              }
            }
          }
        }
      }
    }

    return dependencies;
  }

  static String? _findFieldType(ClassDeclaration clazz, String fieldName) {
    for (final member in clazz.members) {
      if (member is FieldDeclaration) {
        final type = member.fields.type?.toSource();

        for (final variable in member.fields.variables) {
          if (variable.name.lexeme == fieldName) {
            return type;
          }
        }
      }
    }

    return null;
  }

  static bool _isPrimitive(String type) {
    return const {
      'int',
      'double',
      'bool',
      'String',
      'num',
      'dynamic',
      'DateTime',
    }.contains(type);
  }
}
