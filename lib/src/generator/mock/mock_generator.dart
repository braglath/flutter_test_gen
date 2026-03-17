import 'package:flutter_test_gen/src/analyzer/dependency/dependency_analyzer.dart';

/// Generates mock classes and variables for detected dependencies.
///
/// [MockGenerator] is used during test generation to automatically create
/// mock implementations for constructor dependencies. These mocks are
/// typically used with testing frameworks such as `mocktail` or `mockito`.
class MockGenerator {
  /// Generates mock class definitions for the given dependencies.
  ///
  /// Each dependency results in a mock class that extends `Mock`
  /// and implements the original dependency type.
  ///
  /// Example output:
  /// ```dart
  /// class MockUserRepository extends Mock implements UserRepository {}
  /// ```
  ///
  /// Returns the generated mock class code as a string.
  static String generateMockClasses(List<Dependency> deps) {
    final buffer = StringBuffer();
    final seen = <String>{};

    for (final dep in deps) {
      if (_isPrimitive(dep.type)) continue;
      if (_isEnumLike(dep.type)) continue;
      if (!seen.add(dep.type)) continue;

      buffer.writeln(
        'class Mock${dep.type} extends Mock implements ${dep.type} {}',
      );
    }

    return buffer.toString();
  }

  /// Generates variable declarations for mock instances.
  ///
  /// Each dependency produces a `late` variable that will hold the
  /// mock object during test setup.
  ///
  /// Example output:
  /// ```dart
  /// late MockUserRepository mockUserRepository;
  /// ```
  ///
  /// Returns the generated variable declarations as a string.
  static String generateMockVariables(List<Dependency> deps) {
    final buffer = StringBuffer();
    final seen = <String>{};

    for (final dep in deps) {
      if (_isPrimitive(dep.type)) continue;
      if (_isEnumLike(dep.type)) continue;
      if (!seen.add(dep.type)) continue;

      final name = _capitalize(dep.name);

      buffer.writeln(
        'late Mock${dep.type} mock$name;',
      );
    }

    return buffer.toString();
  }

  /// Generates initialization code for mock instances.
  ///
  /// This code is typically placed inside the `setUp()` block of
  /// generated tests to initialize mock objects before each test.
  ///
  /// Example output:
  /// ```dart
  /// mockUserRepository = MockUserRepository();
  /// ```
  ///
  /// Returns the generated initialization code as a string.
  static String generateMockInit(List<Dependency> deps) {
    final buffer = StringBuffer();
    final seen = <String>{};

    for (final dep in deps) {
      if (_isPrimitive(dep.type)) continue;
      if (_isEnumLike(dep.type)) continue;
      if (!seen.add(dep.type)) continue;

      final name = _capitalize(dep.name);

      buffer.writeln(
        'mock$name = Mock${dep.type}();',
      );
    }

    return buffer.toString();
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

bool _isPrimitive(String type) => const {
      'int',
      'double',
      'num',
      'String',
      'bool',
      'dynamic',
      'DateTime',
    }.contains(type);

// String _capitalize(String value) {
//   if (value.isEmpty) return value;
//   return value[0].toUpperCase() + value.substring(1);
// }

bool _isEnumLike(String type) {
  // enums normally don't end with Repository/Service and don't have generics
  if (type.contains('<')) return false;

  // common dependency suffixes
  if (type.endsWith('Repository') ||
      type.endsWith('Service') ||
      type.endsWith('Client') ||
      type.endsWith('DataSource')) {
    return false;
  }

  // enums are usually simple capitalized names
  return true;
}
