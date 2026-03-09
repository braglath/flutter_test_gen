import 'package:flutter_test_gen/src/di/dependency_resolver.dart';
import 'package:flutter_test_gen/src/di/mock_generator.dart';
import 'package:test/test.dart';

void main() {
  group('MockGenerator', () {
    final deps = [
      Dependency('repo', 'UserRepository'),
      Dependency('api', 'UserApi'),
    ];

    test('generateMockClasses creates mock classes', () {
      final result = MockGenerator.generateMockClasses(deps);

      expect(result, contains('class MockUserRepository'));
      expect(result, contains('class MockUserApi'));
      expect(result, contains('extends Mock implements UserRepository'));
      expect(result, contains('extends Mock implements UserApi'));
    });

    test('generateMockVariables creates mock variables', () {
      final result = MockGenerator.generateMockVariables(deps);

      expect(result, contains('late MockUserRepository mockUserRepository;'));
      expect(result, contains('late MockUserApi mockUserApi;'));
    });

    test('generateMockInit creates initialization code', () {
      final result = MockGenerator.generateMockInit(deps);

      expect(result, contains('mockUserRepository = MockUserRepository();'));
      expect(result, contains('mockUserApi = MockUserApi();'));
    });

    test('returns empty string for empty dependency list', () {
      final classes = MockGenerator.generateMockClasses([]);
      final variables = MockGenerator.generateMockVariables([]);
      final init = MockGenerator.generateMockInit([]);

      expect(classes.trim(), '');
      expect(variables.trim(), '');
      expect(init.trim(), '');
    });

    test('handles single dependency', () {
      final deps = [Dependency('repo', 'UserRepository')];

      final classes = MockGenerator.generateMockClasses(deps);
      final variables = MockGenerator.generateMockVariables(deps);
      final init = MockGenerator.generateMockInit(deps);

      expect(classes, contains('MockUserRepository'));
      expect(variables, contains('mockUserRepository'));
      expect(init, contains('MockUserRepository()'));
    });
  });
}
