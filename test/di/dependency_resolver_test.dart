import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test_gen/src/di/dependency_resolver.dart';
import 'package:test/test.dart';

void main() {
  ClassDeclaration parseClass(String source) {
    final result = parseString(
      content: source,
    );

    final unit = result.unit;

    return unit.declarations.whereType<ClassDeclaration>().first;
  }

  group('DependencyResolver', () {
    test('resolves constructor parameter dependency', () {
      final clazz = parseClass('''
class UserService {
  UserService(UserRepository repo);
}
''');

      final deps = DependencyResolver.resolve(clazz);

      expect(deps.length, 1);
      expect(deps.first.name, 'repo');
      expect(deps.first.type, 'UserRepository');
    });

    test('resolves field formal parameter dependency', () {
      final clazz = parseClass('''
class UserService {
  final UserRepository repo;

  UserService(this.repo);
}
''');

      final deps = DependencyResolver.resolve(clazz);

      expect(deps.length, 1);
      expect(deps.first.name, 'repo');
      expect(deps.first.type, 'UserRepository');
    });

    test('resolves named constructor parameters', () {
      final clazz = parseClass('''
class UserService {
  UserService({required UserRepository repo});
}
''');

      final deps = DependencyResolver.resolve(clazz);

      expect(deps.length, 1);
      expect(deps.first.name, 'repo');
      expect(deps.first.type, 'UserRepository');
    });

    test('ignores primitive constructor parameters', () {
      final clazz = parseClass('''
class UserService {
  UserService(int count, String name);
}
''');

      final deps = DependencyResolver.resolve(clazz);

      expect(deps, isEmpty);
    });

    test('resolves multiple dependencies', () {
      final clazz = parseClass('''
class UserService {
  UserService(UserRepository repo, ApiClient api);
}
''');

      final deps = DependencyResolver.resolve(clazz);

      expect(deps.length, 2);
      expect(deps[0].type, 'UserRepository');
      expect(deps[1].type, 'ApiClient');
    });

    test('resolves field type when not specified in constructor', () {
      final clazz = parseClass('''
class UserService {
  final UserRepository repository;

  UserService(this.repository);
}
''');

      final deps = DependencyResolver.resolve(clazz);

      expect(deps.length, 1);
      expect(deps.first.type, 'UserRepository');
    });
  });
}
