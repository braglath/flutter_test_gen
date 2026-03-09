import 'package:flutter_test_gen/src/di/dependency_resolver.dart';
import 'package:flutter_test_gen/src/templates/test_template.dart';
import 'package:test/test.dart';

void main() {
  group('TestTemplates.group', () {
    test('generates group for top level functions', () {
      final result = TestTemplates.group(
        groupName: 'Functions | user_service.dart',
        className: '',
        tests: "    test('test1', () {});",
        isTopLevel: true,
        dependencies: [],
      );

      expect(result, contains("group('Functions | user_service.dart'"));
      expect(result, contains("test('test1'"));
    });

    test('generates group with class and dependencies', () {
      final dependencies = [
        Dependency('userRepository', 'UserRepository'),
      ];

      final result = TestTemplates.group(
        groupName: 'UserService | user_service.dart',
        className: 'UserService',
        tests: "    test('getUser', () {});",
        isTopLevel: false,
        dependencies: dependencies,
      );

      expect(result, contains("late UserService service"));
      expect(result, contains("MockUserRepository"));
      expect(result, contains("service = UserService(mockUserRepository)"));
    });

    test('generates group with no dependencies', () {
      final result = TestTemplates.group(
        groupName: 'UserService | user_service.dart',
        className: 'UserService',
        tests: "    test('getUser', () {});",
        isTopLevel: false,
        dependencies: [],
      );

      expect(result, contains("service = UserService();"));
    });
  });

  group('TestTemplates.test', () {
    test('generates sync test with return value', () {
      final result = TestTemplates.test(
        name: 'getUser',
        arrange: "",
        call: "service.getUser()",
        expectedValue: "1",
        verifyCall: "",
        isAsync: false,
        isVoid: false,
      );

      expect(result, contains("test('getUser'"));
      expect(result, contains("final result = service.getUser()"));
      expect(result, contains("expect(result, 1)"));
    });

    test('generates async test', () {
      final result = TestTemplates.test(
        name: 'getUser',
        arrange: "",
        call: "service.getUser()",
        expectedValue: "1",
        verifyCall: "",
        isAsync: true,
        isVoid: false,
      );

      expect(result, contains("async"));
      expect(result, contains("await service.getUser()"));
    });

    test('generates void test', () {
      final result = TestTemplates.test(
        name: 'deleteUser',
        arrange: "",
        call: "service.deleteUser()",
        expectedValue: "",
        verifyCall: "",
        isAsync: false,
        isVoid: true,
      );

      expect(result, contains("service.deleteUser()"));
      expect(result, contains("// TODO: verify side effects"));
    });
  });

  group('TestTemplates.file', () {
    test('generates file with mocks', () {
      final result = TestTemplates.file(
        importPath: "package:app/user_service.dart",
        imports: "",
        mocks: "class MockRepo extends Mock {}",
        mockVariables: "late MockRepo mockRepo;",
        groups: "group('test', () {});",
      );

      expect(result, contains("mocktail"));
      expect(result, contains("import 'package:app/user_service.dart'"));
      expect(result, contains("class MockRepo"));
    });

    test('generates file without mocks', () {
      final result = TestTemplates.file(
        importPath: "package:app/user_service.dart",
        imports: "",
        mocks: "",
        mockVariables: "",
        groups: "",
      );

      expect(result.contains("mocktail"), false);
    });
  });
}
