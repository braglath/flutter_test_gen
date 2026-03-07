class TestTemplates {
  static String group({
    required String groupName,
    required String className,
    required String tests,
    required bool isTopLevel,
  }) {
    if (isTopLevel) {
      return """
  group('$groupName', () {
$tests
  });
""";
    }

    return """
  group('$groupName', () {

    late $className service;

    setUp(() {
      service = $className();
    });

$tests
  });
""";
  }

  static String test({
    required String name,
    required String arrange,
    required String call,
    required bool isAsync,
  }) {
    final asyncKeyword = isAsync ? "async" : "";
    final awaitKeyword = isAsync ? "await " : "";

    return """
    test('$name', () $asyncKeyword {

      // Arrange
$arrange

      // Act
      final result = $awaitKeyword$call;

      // Assert
      expect(result, isNotNull);

    });
""";
  }

  static String file({
    required String importPath,
    required String imports,
    required String groups,
  }) {
    return """
import 'package:flutter_test/flutter_test.dart';
import '$importPath';
$imports

void main() {
$groups
}
""";
  }
}
