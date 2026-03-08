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
    required bool isVoid,
  }) {
    final asyncKeyword = isAsync ? "async" : "";
    final awaitKeyword = isAsync ? "await " : "";
    final assertLogic = isVoid
        ? "//TODO: implement your assert logic"
        : "expect(result, isNotNull);";

    // (name: $name, arrange: $arrange, call: $call, isAsync: $isAsync ,isVoid: $isVoid)
    return """
    test('$name', () $asyncKeyword {
      // Arrange
$arrange
      // Act
      final result = $awaitKeyword$call;

      // Assert
      $assertLogic
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
