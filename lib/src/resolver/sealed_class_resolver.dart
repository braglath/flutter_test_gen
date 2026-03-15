import 'package:analyzer/dart/ast/ast.dart';

/// Utility class for resolving subclasses of a sealed or base class
/// within a Dart source file.
///
/// [SealedClassResolver] scans the parsed AST (`CompilationUnit`)
/// to detect classes that extend a given base type. This is useful
/// for tools that need to understand inheritance relationships
/// during static analysis.
///
/// In the context of the test generator, this resolver helps detect
/// subclasses of sealed error or state classes so that tests can be
/// generated for each possible subtype.
///
/// Example:
/// ```dart
/// sealed class UserError {}
///
/// class UserNotFound extends UserError {}
/// class UserBlocked extends UserError {}
/// ```
///
/// Calling:
///
/// ```dart
/// SealedClassResolver.findSubclasses('UserError', unit);
/// ```
///
/// will return:
///
/// ```dart
/// ['UserNotFound', 'UserBlocked']
/// ```
class SealedClassResolver {
  /// Finds all subclasses that extend the given [baseType]
  /// within the provided Dart [CompilationUnit].
  ///
  /// This method iterates through all declarations in the parsed
  /// source file and collects classes whose `extends` clause
  /// references the specified base type.
  ///
  /// Parameters:
  /// - [baseType]: The name of the parent class to search for.
  /// - [unit]: The parsed AST (`CompilationUnit`) of the Dart file.
  ///
  /// Returns:
  /// A list of class names that directly extend the provided [baseType].
  ///
  /// Notes:
  /// - Only **direct subclasses** are detected.
  /// - Classes extending other subclasses (multi-level inheritance)
  ///   are not included.
  /// - This method only inspects classes declared in the same
  ///   compilation unit.
  static List<String> findSubclasses(
    String baseType,
    CompilationUnit unit,
  ) {
    final subclasses = <String>[];

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        final extendsClause = declaration.extendsClause;

        if (extendsClause == null) continue;

        final parent = extendsClause.superclass.name.lexeme;

        if (parent == baseType) {
          subclasses.add(declaration.name.lexeme);
        }
      }
    }

    return subclasses;
  }
}
