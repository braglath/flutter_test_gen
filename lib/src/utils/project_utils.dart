import 'dart:io';

import 'package:yaml/yaml.dart';

class ProjectUtil {
  ProjectUtil._internal();
  static final ProjectUtil _instance = ProjectUtil._internal();
  factory ProjectUtil() => _instance;

  late final String _projectRoot;
  late final String _projectName;

  /// Initialize once with any file path inside the project
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
}
