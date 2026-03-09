import 'package:flutter_test_gen/src/di/dependency_resolver.dart';
import 'package:flutter_test_gen/src/generator/test_builder.dart';
import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/models/method_parameter.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';
import 'package:test/test.dart';

void main() {
  late ProjectUtil project;
  late TestBuilder builder;

  setUp(() {
    project = ProjectUtil();
    builder = TestBuilder(project);
  });

  MethodInfo createMethod({
    required String className,
    required String name,
    String returnType = 'int',
    bool isStatic = false,
    bool isAsync = false,
    bool isVoid = false,
    bool isTopLevel = false,
    List<MethodParameter> params = const [],
    List<Dependency> dependencies = const [],
  }) =>
      MethodInfo(
        className: className,
        methodName: name,
        returnType: returnType,
        parameters: params,
        dependencies: dependencies,
        isStatic: isStatic,
        isAsync: isAsync,
      );

  test('generates test for simple class method', () {
    final methods = [
      createMethod(className: 'UserService', name: 'getUser'),
    ];

    final result = builder.generate(
      methods,
      'package:test/user_service.dart',
      'lib/user_service.dart',
      '',
      'lib/user_service.dart',
    );

    expect(result, contains("group('UserService | lib/user_service.dart'"));
    expect(result, contains("test('getUser'"));
  });

  test('skips private methods', () {
    final methods = [
      createMethod(className: 'UserService', name: '_hiddenMethod'),
    ];

    final result = builder.generate(
      methods,
      'package:test/user_service.dart',
      'lib/user_service.dart',
      '',
      'lib/user_service.dart',
    );

    expect(result.contains('_hiddenMethod'), false);
  });

  test('skips mixin classes', () {
    final methods = [
      createMethod(className: 'LoggerMixin', name: 'log'),
    ];

    final result = builder.generate(
      methods,
      'package:test/logger.dart',
      'lib/logger.dart',
      '',
      'lib/logger.dart',
    );

    expect(result.contains("test('log'"), false);
  });

  test('generates parameter arrange variables', () {
    final methods = [
      createMethod(
        className: 'UserService',
        name: 'saveUser',
        params: [
          const MethodParameter(name: 'name', type: 'String'),
        ],
      )
    ];

    final result = builder.generate(
      methods,
      'package:test/user_service.dart',
      'lib/user_service.dart',
      '',
      'lib/user_service.dart',
    );

    expect(result, contains('final name'));
  });

  test('generates top level function group', () {
    final methods = [
      createMethod(
        className: '__top_level__',
        name: 'calculate',
        isTopLevel: true,
      )
    ];

    final result = builder.generate(
      methods,
      'package:test/functions.dart',
      'lib/functions.dart',
      '',
      'lib/functions.dart',
    );

    expect(result, contains('Functions | lib/functions.dart'));
  });

  test('generates mock dependencies', () {
    final methods = [
      createMethod(
        className: 'UserService',
        name: 'getUser',
        dependencies: [
          Dependency('repo', 'UserRepository'),
        ],
      )
    ];

    final result = builder.generate(
      methods,
      'package:test/user_service.dart',
      'lib/user_service.dart',
      '',
      'lib/user_service.dart',
    );

    expect(result, contains('MockUserRepository'));
    expect(result, contains('mockUserRepository'));
  });

  test('skips existing tests', () {
    final methods = [
      createMethod(className: 'UserService', name: 'getUser'),
    ];

    final existing = "test('getUser', () {});";

    final result = builder.generate(
      methods,
      'package:test/user_service.dart',
      'lib/user_service.dart',
      existing,
      'lib/user_service.dart',
    );

    expect(result.contains("test('getUser'"), false);
  });
}
