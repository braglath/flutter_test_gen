import 'dart:io';

import 'package:flutter_test_gen/src/parser/dart_parser.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late DartParser parser;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('dart_parser_test');
    parser = DartParser();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('extracts class methods', () {
    final file = File('${tempDir.path}/service.dart');

    file.writeAsStringSync('''
class UserService {
  int getUser() {
    return 1;
  }
}
''');

    final methods = parser.extractMethods(file.path);

    expect(methods.length, 1);
    expect(methods.first.className, 'UserService');
    expect(methods.first.methodName, 'getUser');
    expect(methods.first.returnType, 'int');
  });

  test('extracts async method', () {
    final file = File('${tempDir.path}/service.dart');

    file.writeAsStringSync('''
class UserService {
  Future<int> getUser() async {
    return 1;
  }
}
''');

    final methods = parser.extractMethods(file.path);

    expect(methods.first.isAsync, true);
  });

  test('extracts static method', () {
    final file = File('${tempDir.path}/service.dart');

    file.writeAsStringSync('''
class UserService {
  static int count() {
    return 1;
  }
}
''');

    final methods = parser.extractMethods(file.path);

    expect(methods.first.isStatic, true);
  });

  test('extracts method parameters', () {
    final file = File('${tempDir.path}/service.dart');

    file.writeAsStringSync('''
class UserService {
  void saveUser(String name, int age) {}
}
''');

    final methods = parser.extractMethods(file.path);

    expect(methods.first.parameters.length, 2);
    expect(methods.first.parameters[0].name, 'name');
    expect(methods.first.parameters[0].type, 'String');
  });

  test('extracts top level function', () {
    final file = File('${tempDir.path}/functions.dart');

    file.writeAsStringSync('''
int add(int a, int b) {
  return a + b;
}
''');

    final methods = parser.extractMethods(file.path);

    expect(methods.first.className, '__top_level__');
    expect(methods.first.methodName, 'add');
  });

  test('ignores getters and setters', () {
    final file = File('${tempDir.path}/service.dart');

    file.writeAsStringSync('''
class UserService {
  int get count => 1;
  set count(int value) {}
}
''');

    final methods = parser.extractMethods(file.path);

    expect(methods, isEmpty);
  });

  test('extracts mixin methods', () {
    final file = File('${tempDir.path}/mixin.dart');

    file.writeAsStringSync('''
mixin Logger {
  void log(String message) {}
}
''');

    final methods = parser.extractMethods(file.path);

    expect(methods.first.className, 'Logger');
    expect(methods.first.methodName, 'log');
  });

  test('extracts extension methods', () {
    final file = File('${tempDir.path}/extension.dart');

    file.writeAsStringSync('''
extension StringExt on String {
  int lengthPlus() {
    return length + 1;
  }
}
''');

    final methods = parser.extractMethods(file.path);

    expect(methods.first.className, 'StringExt');
    expect(methods.first.methodName, 'lengthPlus');
  });
}
