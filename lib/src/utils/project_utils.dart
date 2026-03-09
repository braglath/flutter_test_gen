import 'dart:io';

import 'package:flutter_test_gen/src/models/method_parameter.dart';
import 'package:yaml/yaml.dart';

class ProjectUtil {
  late final String _projectRoot;
  late final String _projectName;

  void initialize(String filePath) {
    _projectRoot = _findProjectRoot(filePath);
    _projectName = _loadProjectName();
  }

  String get projectRoot => _projectRoot;
  String get projectName => _projectName;

  // Generates package import path for a dart file
  String generateImportPath(String filePath) {
    final libIndex = filePath.indexOf('lib/');

    if (libIndex == -1) {
      throw ArgumentError('File must be inside the lib/ folder');
    }

    final relativePath = filePath.substring(libIndex + 4);

    return 'package:$_projectName/$relativePath';
  }

  // Finds project root by walking up the directory tree
  String _findProjectRoot(String filePath) {
    var dir = File(filePath).parent;

    while (true) {
      final pubspec = File('${dir.path}/pubspec.yaml');

      if (pubspec.existsSync()) {
        return dir.path;
      }

      final parent = dir.parent;

      if (parent.path == dir.path) {
        throw FileSystemException('pubspec.yaml not found');
      }

      dir = parent;
    }
  }

  /// Loads project name from pubspec.yaml
  String _loadProjectName() {
    final pubspecFile = File('$_projectRoot/pubspec.yaml');

    if (!pubspecFile.existsSync()) {
      throw FileSystemException('pubspec.yaml not found in project root');
    }

    final yaml = loadYaml(pubspecFile.readAsStringSync());

    final name = yaml['name'];

    if (name == null) {
      throw FormatException('Project name not found in pubspec.yaml');
    }

    return name.toString();
  }

  bool isEnumType(String type) {
    return ![
      'String',
      'int',
      'double',
      'bool',
      'DateTime',
      'dynamic',
    ].contains(type.replaceAll('?', ''));
  }

  String generateValue(MethodParameter param) {
    final type = param.type.replaceAll('?', '');

    if (ProjectUtil().isEnumType(type)) {
      return '$type.${defaultEnumValue(type)}';
    }

    switch (type) {
      case "int":
        return "1";
      case "String":
        return "'test'";
      case "bool":
        return "true";
      case "double":
        return "1.0";
      case "DateTime":
        return "DateTime.now()";
      default:
        return "$type()";
    }
  }

  String defaultEnumValue(String enumName) {
    return 'values.first';
  }

  String mockName(String type) {
    return "mock$type";
  }

  static bool isPrimitive(String type) {
    return const [
      'String',
      'int',
      'double',
      'bool',
      'num',
      'DateTime',
      'dynamic',
    ].contains(type);
  }

  String mockReturnValue(String returnType) {
    if (returnType.startsWith("Future<")) {
      final inner =
          returnType.replaceFirst("Future<", "").replaceFirst(">", "");

      final value = primitiveValue(inner);

      return "thenAnswer((_) async => $value)";
    }

    return "thenReturn(${primitiveValue(returnType)})";
  }

  String primitiveValue(String type) {
    if (type.startsWith("Future<")) {
      final inner = type.replaceFirst("Future<", "").replaceFirst(">", "");
      return primitiveValue(inner);
    }

    switch (type) {
      case 'int':
        return '1';
      case 'double':
        return '1.0';
      case 'bool':
        return 'true';
      case 'String':
        return "'test'";
      default:
        return 'null';
    }
  }
}
