import 'dart:io';

import 'package:flutter_test_gen/src/models/method_parameter.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';
import 'package:test/test.dart';

void main() {
  final projectUtil = ProjectUtil();

  late Directory tempProject;

  setUpAll(() async {
    tempProject = await Directory.systemTemp.createTemp('test_project');

    // create fake pubspec.yaml
    final pubspec = File('${tempProject.path}/pubspec.yaml');
    await pubspec.writeAsString('''
name: fake_project
description: test
''');

    // create lib folder
    final libDir = Directory('${tempProject.path}/lib');
    libDir.createSync();

    // create dummy dart file
    File('${tempProject.path}/lib/test.dart').createSync();

    projectUtil.initialize('${tempProject.path}/lib/test.dart');
  });

  tearDownAll(() async {
    await tempProject.delete(recursive: true);
  });

  group('ProjectUtil', () {
    test('should load project name from pubspec.yaml', () {
      expect(projectUtil.projectName, 'fake_project');
    });

    test('should find project root', () {
      expect(projectUtil.projectRoot, tempProject.path);
    });

    test('generateImportPath should return correct package import', () {
      final file = '${tempProject.path}/lib/services/user_service.dart';

      final result = projectUtil.generateImportPath(file);

      expect(result, 'package:fake_project/services/user_service.dart');
    });

    test('generateImportPath should throw if file not in lib', () {
      final file = '${tempProject.path}/bin/main.dart';

      expect(
        () => projectUtil.generateImportPath(file),
        throwsArgumentError,
      );
    });

    test('isEnumType should detect enums', () {
      expect(projectUtil.isEnumType('UserGender'), true);
      expect(projectUtil.isEnumType('String'), false);
      expect(projectUtil.isEnumType('int'), false);
    });

    test('generateValue should generate primitive values', () {
      final param = MethodParameter(
        name: 'age',
        type: 'int',
        isNamed: false,
      );

      final result = projectUtil.generateValue(param);

      expect(result, '1');
    });

    test('generateValue should generate enum default value', () {
      final param = MethodParameter(
        name: 'gender',
        type: 'UserGender',
        isNamed: false,
      );

      final result = projectUtil.generateValue(param);

      expect(result, 'UserGender.values.first');
    });

    test('mockName should generate mock variable name', () {
      final result = projectUtil.mockName('UserService');

      expect(result, 'mockUserService');
    });

    test('isPrimitive should detect primitive types', () {
      expect(ProjectUtil.isPrimitive('String'), true);
      expect(ProjectUtil.isPrimitive('int'), true);
      expect(ProjectUtil.isPrimitive('UserService'), false);
    });

    test('mockReturnValue for Future type', () {
      final result = projectUtil.mockReturnValue('Future<int>');

      expect(result, 'thenAnswer((_) async => 1)');
    });

    test('mockReturnValue for non Future type', () {
      final result = projectUtil.mockReturnValue('int');

      expect(result, 'thenReturn(1)');
    });

    test('primitiveValue should return primitive defaults', () {
      expect(projectUtil.primitiveValue('int'), '1');
      expect(projectUtil.primitiveValue('double'), '1.0');
      expect(projectUtil.primitiveValue('bool'), 'true');
      expect(projectUtil.primitiveValue('String'), "'test'");
    });

    test('primitiveValue should return null for unknown types', () {
      expect(projectUtil.primitiveValue('UserService'), 'null');
    });
  });
}
