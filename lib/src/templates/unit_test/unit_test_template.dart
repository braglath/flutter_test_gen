import 'package:flutter_test_gen/src/analyzer/dependency/dependency_analyzer.dart';

/// Provides reusable templates for generating Flutter unit test code.
///
/// [UnitTestTemplates] is responsible for producing structured test code such as:
/// - test groups
/// - individual test cases
/// - complete test files
///
/// These templates are used by the test generator to convert analyzed
/// source code metadata into runnable Flutter tests.
class UnitTestTemplates {
  /// Generates a `group()` block for a class or top-level functions.
  ///
  /// This method creates the test group structure and optionally generates:
  /// - mock initializations
  /// - `setUp()` blocks
  /// - service instantiation
  ///
  /// Parameters:
  /// - [groupName]: Name of the test group.
  /// - [className]: Class being tested.
  /// - [tests]: Generated test cases inside the group.
  /// - [isTopLevel]: Indicates whether the tests belong to top-level functions.
  /// - [dependencies]: Dependencies that should be mocked.
  /// - [constructorDependencies]: Dependencies injected through the constructor.
  /// - [hasInstanceMethods]: Whether the tested class contains instance methods.
  ///
  /// Behavior:
  /// - If [isTopLevel] is true, no service instance is created.
  /// - If dependencies exist, mocks are initialized inside `setUp()`.
  /// - If instance methods exist, the service object is constructed.
  static String group({
    required String groupName,
    required String className,
    required String tests,
    required bool isTopLevel,
    required List<Dependency> dependencies,
    required List<Dependency> constructorDependencies,
    required bool hasInstanceMethods,
  }) {
    if (isTopLevel) {
      return """
  group('$groupName', () {
$tests
  });
""";
    }

    /// Initialize mocks
    final mockInitializers = dependencies.map((d) {
      final mockVar = _mockVar(d.name);
      return '      $mockVar = Mock${d.type}();';
    }).join('\n');

    /// Constructor arguments
    final constructorArgs =
        constructorDependencies.map((d) => _mockVar(d.name)).join(', ');

    /// Declare service only if needed
    final serviceDeclaration =
        hasInstanceMethods ? '    late $className service;\n' : '';

    final serviceInit = hasInstanceMethods
        ? (dependencies.isEmpty
            ? '      service = $className();'
            : '      service = $className($constructorArgs);')
        : '';

    /// Determine if setUp() is required
    final needsSetup = mockInitializers.isNotEmpty || serviceInit.isNotEmpty;

    final setupBlock = needsSetup
        ? """
    setUp(() {
${mockInitializers.isEmpty ? '' : '$mockInitializers\n'}
${serviceInit.isEmpty ? '' : '$serviceInit\n'}
    });
"""
        : '';

    return """
  group('$groupName', () {

$serviceDeclaration
$setupBlock
$tests
  });
""";
  }

  /// Generates a single `test()` block.
  ///
  /// This template constructs the full structure of a unit test including:
  /// - Arrange section
  /// - Act section
  /// - Assert section
  ///
  /// Parameters:
  /// - [name]: Name of the test case.
  /// - [arrange]: Setup logic such as stubbing dependencies.
  /// - [call]: The method invocation being tested.
  /// - [expectedValue]: Expected result used in the assertion.
  /// - [verifyCall]: Optional verification logic for mock interactions.
  /// - [isAsync]: Whether the tested method is asynchronous.
  /// - [isVoid]: Whether the method returns `void`.
  ///
  /// Behavior:
  /// - Async methods automatically use `async` and `await`.
  /// - Non-void methods generate `expect(result, value)` assertions.
  /// - Void methods include a placeholder comment for verifying side effects.
  static String test({
    required String name,
    required String body,
  }) =>
      """
  test('$name', () async {
$body
  });
""";

  /// Generates a complete Flutter test file.
  ///
  /// The generated file includes:
  /// - Required Flutter test imports
  /// - Optional `mocktail` import if mocks are used
  /// - Target file import
  /// - Mock class definitions
  /// - Mock variable declarations
  /// - All generated test groups
  ///
  /// Parameters:
  /// - [importPath]: Path of the file being tested.
  /// - [imports]: Additional imports required for dependencies.
  /// - [mocks]: Generated mock classes.
  /// - [mockVariables]: Variables used to store mock instances.
  /// - [groups]: All generated test groups.
  ///
  /// This method assembles the final output that will be written
  /// to the generated test file.
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
$imports
import '$importPath';
$mocktailImport

$mocks

void main() {

$mockVariables

$groups
}
""";
  }

  static String _mockVar(String name) {
    final cap = name[0].toUpperCase() + name.substring(1);
    return 'mock$cap';
  }
}
