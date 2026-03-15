// ignore_for_file: file_names

import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test_gen/src/di/dependency_resolver.dart';

/// Filters constructor or class dependencies to determine which ones
/// should be mocked when generating tests.
///
/// This utility removes dependencies that **do not require mocking**,
/// such as:
/// - Primitive types (`int`, `String`, `bool`, etc.)
/// - `sealed` classes defined within the same compilation unit
///
/// The goal is to return only the dependencies that should be replaced
/// with mock objects when generating unit tests.
class DependencyFilter {
  /// Filters a list of [Dependency] objects and returns only the ones
  /// that require mocking.
  ///
  /// The filtering rules are:
  /// - Primitive types are ignored because they can be directly
  ///   instantiated or assigned in tests.
  /// - `sealed` classes are ignored because they are typically handled
  ///   through specific implementations rather than mocks.
  ///
  /// Parameters:
  /// - [deps]: List of detected dependencies for a class or constructor.
  /// - [unit]: The [CompilationUnit] representing the parsed Dart file,
  ///   used to inspect class declarations.
  ///
  /// Returns a list of dependencies that should be mocked.
  ///
  /// Example:
  /// ```dart
  /// final filtered = DependencyFilter.filter(dependencies, unit);
  /// ```
  static List<Dependency> filter(
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

  static bool _isPrimitive(String type) => const {
        'int',
        'double',
        'num',
        'String',
        'bool',
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
