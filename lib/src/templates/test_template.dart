import 'package:flutter_test_gen/src/di/dependency_resolver.dart';

class TestTemplates {
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
