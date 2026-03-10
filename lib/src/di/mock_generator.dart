import 'package:flutter_test_gen/src/di/dependency_resolver.dart';

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

    for (var dep in deps) {
      buffer.writeln(
          'class Mock${dep.type} extends Mock implements ${dep.type} {}');
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

    for (var dep in deps) {
      buffer.writeln('late Mock${dep.type} mock${dep.type};');
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

    for (var dep in deps) {
      buffer.writeln('mock${dep.type} = Mock${dep.type}();');
    }

    return buffer.toString();
  }
}
