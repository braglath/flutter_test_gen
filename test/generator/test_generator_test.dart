import 'dart:io';

import 'package:flutter_test_gen/src/generator/test_generator.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempProject;
  late String sourceFile;

  setUp(() async {
    tempProject = await Directory.systemTemp.createTemp('generator_test');

    // pubspec
    File('${tempProject.path}/pubspec.yaml')
        .writeAsStringSync('name: fake_project');

    // lib directory
    Directory('${tempProject.path}/lib').createSync();

    // source file
    sourceFile = '${tempProject.path}/lib/user_service.dart';
  });

  tearDown(() async {
    await tempProject.delete(recursive: true);
  });

  test('prints warning when no methods found', () async {
    File(sourceFile).writeAsStringSync('''
class EmptyService {}
''');

    final generator = TestGenerator();

    await generator.generate(sourceFile);

    final testFile = File(
      '${tempProject.path}/test/user_service_test.dart',
    );

    expect(testFile.existsSync(), false);
  });

  test('generates new test file', () async {
    File(sourceFile).writeAsStringSync('''
class UserService {
  int getUser() {
    return 1;
  }
}
''');

    final generator = TestGenerator();

    await generator.generate(sourceFile);

    final testFile = File(
      '${tempProject.path}/test/user_service_test.dart',
    );

    expect(testFile.existsSync(), true);

    final content = testFile.readAsStringSync();

    expect(content, contains('group'));
    expect(content, contains('test'));
  });

  test('overwrite replaces existing test file', () async {
    File(sourceFile).writeAsStringSync('''
class UserService {
  int getUser() {
    return 1;
  }
}
''');

    final testFile = File(
      '${tempProject.path}/test/user_service_test.dart',
    );

    testFile.createSync(recursive: true);
    testFile.writeAsStringSync('OLD CONTENT');

    final generator = TestGenerator();

    await generator.generate(
      sourceFile,
      overwrite: true,
    );

    final content = testFile.readAsStringSync();

    expect(content.contains('OLD CONTENT'), false);
  });

  test('append does nothing when no new tests', () async {
    File(sourceFile).writeAsStringSync('''
class UserService {
  int getUser() {
    return 1;
  }
}
''');

    final generator = TestGenerator();

    await generator.generate(sourceFile);

    final testFile = File(
      '${tempProject.path}/test/user_service_test.dart',
    );

    final originalContent = testFile.readAsStringSync();

    await generator.generate(sourceFile);

    final updatedContent = testFile.readAsStringSync();

    expect(updatedContent, originalContent);
  });
}
