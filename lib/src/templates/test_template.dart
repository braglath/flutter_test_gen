import 'package:flutter_test_gen/src/di/dependency_resolver.dart';

/// Provides reusable template generators for building test code.
///
/// [TestTemplates] contains static helper methods used to generate
/// different sections of a test file, including:
/// - test groups
/// - individual test cases
/// - the complete test file structure
///
/// These templates are used by the test generator to produce
/// consistent and readable unit tests.
class TestTemplates {
  /// Generates a `group()` block containing tests for a class or
  /// top-level functions.
  ///
  /// Parameters:
  /// - [groupName]: The name of the test group.
  /// - [className]: The class being tested.
  /// - [tests]: The generated test cases belonging to the group.
  /// - [isTopLevel]: Indicates whether the tests are for top-level functions.
  /// - [dependencies]: List of constructor dependencies used to create mocks.
  ///
  /// For class-based tests, this template:
  /// - Creates a `service` instance of the class under test.
  /// - Initializes mock dependencies in `setUp()`.
  /// - Injects mocks into the constructor.
  ///
  /// For top-level functions, no service instance or mocks are generated.
  static String group({
    required String groupName,
    required String className,
    required String tests,
    required bool isTopLevel,
    required List<Dependency> dependencies,
  }) {
    if (isTopLevel) {
      return """
  group('$groupName', () {
$tests
  });
""";
    }

    final mockInitializers = dependencies.map((d) {
      final mockVar = 'mock${d.type[0].toUpperCase()}${d.type.substring(1)}';
      return '      $mockVar = Mock${d.type}();';
    }).join('\n');

    final constructorArgs = dependencies
        .map((d) => 'mock${d.type[0].toUpperCase()}${d.type.substring(1)}')
        .join(', ');

    final serviceInit = dependencies.isEmpty
        ? '      service = $className();'
        : '      service = $className($constructorArgs);';

    return """
  group('$groupName', () {

    late $className service;

    setUp(() {
$mockInitializers
$serviceInit
    });

$tests
  });
""";
  }

  /// Generates a single `test()` block.
  ///
  /// Parameters:
  /// - [name]: The name of the test.
  /// - [arrange]: Generated setup code for method parameters.
  /// - [call]: The method invocation expression.
  /// - [expectedValue]: The expected value used in assertions.
  /// - [verifyCall]: Optional verification code for mocked dependencies.
  /// - [isAsync]: Indicates whether the method being tested is asynchronous.
  /// - [isVoid]: Indicates whether the method returns `void`.
  ///
  /// The generated test follows the **Arrange–Act–Assert** pattern:
  /// - Arrange: prepares inputs
  /// - Act: executes the method
  /// - Assert: verifies results or side effects
  static String test({
    required String name,
    required String arrange,
    required String call,
    required String expectedValue,
    required String verifyCall,
    required bool isAsync,
    required bool isVoid,
  }) {
    final asyncKeyword = isAsync ? 'async' : '';
    final awaitKeyword = isAsync ? 'await ' : '';

    final actLine = isVoid
        ? '      $awaitKeyword$call;'
        : '      final result = $awaitKeyword$call;';

    final assertLogic = isVoid
        ? '      // TODO: verify side effects'
        : '      expect(result, $expectedValue);';

    return """
    test('$name', () $asyncKeyword {
      // Arrange
$arrange
      // Act
$actLine

      // Assert
$assertLogic
$verifyCall
    });
""";
  }

  /// Generates the complete test file content.
  ///
  /// Parameters:
  /// - [importPath]: Import path of the source file being tested.
  /// - [imports]: Additional imports required by generated tests.
  /// - [mocks]: Generated mock class definitions.
  /// - [mockVariables]: Mock variable declarations.
  /// - [groups]: All generated test groups.
  ///
  /// This method assembles the final test file including:
  /// - required `flutter_test` import
  /// - optional `mocktail` import (if mocks exist)
  /// - source file import
  /// - generated mocks
  /// - test groups inside the `main()` function.
  static String file({
    required String importPath,
    required String imports,
    required String mocks,
    required String mockVariables,
    required String groups,
  }) {
    final mocktailImport = mocks.trim().isEmpty
        ? ''
        : "import 'package:mocktail/mocktail.dart';\n";

    return """
import 'package:flutter_test/flutter_test.dart';
${mocktailImport}import '$importPath';
$imports

$mocks

void main() {

$mockVariables

$groups
}
""";
  }
}
