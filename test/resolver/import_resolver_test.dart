import 'dart:io';

import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/models/method_parameter.dart';
import 'package:flutter_test_gen/src/resolver/import_resolver.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempProject;
  late ProjectUtil projectUtil;
  late ImportResolver resolver;
  late String sourceFilePath;

  setUp(() async {
    tempProject = await Directory.systemTemp.createTemp('import_resolver_test');

    final pubspec = File('${tempProject.path}/pubspec.yaml');
    await pubspec.writeAsString('name: fake_project');

    final libDir = Directory('${tempProject.path}/lib');
    libDir.createSync();

    final modelsDir = Directory('${tempProject.path}/lib/models');
    modelsDir.createSync();

    File('${modelsDir.path}/user.dart').writeAsStringSync('class User {}');
    File('${modelsDir.path}/status.dart')
        .writeAsStringSync('enum Status { active, inactive }');

    final sourceFile = File('${tempProject.path}/lib/service.dart');
    sourceFile.writeAsStringSync('class UserService {}');
    sourceFilePath = sourceFile.path;

    projectUtil = ProjectUtil();
    projectUtil.initialize(sourceFile.path);

    resolver = ImportResolver(projectUtil);
  });

  tearDown(() async {
    await tempProject.delete(recursive: true);
  });

  group('ImportResolver', () {
    test('adds import for return type', () {
      final method = MethodInfo(
        methodName: 'getUser',
        className: 'UserService',
        returnType: 'User',
        parameters: [],
        isAsync: false,
        isStatic: false,
        dependencies: [],
      );

      final imports = <String>{};

      resolver.collectImports(method, sourceFilePath, imports);

      expect(imports.first, contains('package:fake_project/models/user.dart'));
    });

    test('adds import for parameter type', () {
      final method = MethodInfo(
        methodName: 'saveUser',
        className: 'UserService',
        returnType: 'void',
        parameters: [
          const MethodParameter(
            name: 'user',
            type: 'User',
          )
        ],
        isAsync: false,
        isStatic: false,
        dependencies: [],
      );

      final imports = <String>{};

      resolver.collectImports(method, sourceFilePath, imports);

      expect(imports.first, contains('package:fake_project/models/user.dart'));
    });

    test('adds import for enum parameter', () {
      final method = MethodInfo(
        methodName: 'updateStatus',
        className: 'UserService',
        returnType: 'void',
        parameters: [
          const MethodParameter(
            name: 'status',
            type: 'Status',
          )
        ],
        isAsync: false,
        isStatic: false,
        dependencies: [],
      );

      final imports = <String>{};

      resolver.collectImports(method, sourceFilePath, imports);

      expect(
          imports.first, contains('package:fake_project/models/status.dart'));
    });

    test('does not import primitive types', () {
      final method = MethodInfo(
        methodName: 'count',
        className: 'UserService',
        returnType: 'int',
        parameters: [],
        isAsync: false,
        isStatic: false,
        dependencies: [],
      );

      final imports = <String>{};

      resolver.collectImports(method, sourceFilePath, imports);

      expect(imports, isEmpty);
    });

    test('handles nullable types', () {
      final method = MethodInfo(
        methodName: 'getUser',
        className: 'UserService',
        returnType: 'User?',
        parameters: [],
        isAsync: false,
        isStatic: false,
        dependencies: [],
      );

      final imports = <String>{};

      resolver.collectImports(method, sourceFilePath, imports);

      expect(imports.first, contains('package:fake_project/models/user.dart'));
    });
  });
}
