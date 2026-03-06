import 'dart:io';
import 'package:yaml/yaml.dart';

String findProjectRoot(String filePath) {
  var dir = File(filePath).parent;

  while (true) {
    final pubspec = File("${dir.path}/pubspec.yaml");

    if (pubspec.existsSync()) {
      return dir.path;
    }

    final parent = dir.parent;

    if (parent.path == dir.path) {
      throw Exception("pubspec.yaml not found");
    }

    dir = parent;
  }
}

String getProjectName(String projectRoot) {
  final pubspecFile = File("$projectRoot/pubspec.yaml");

  final yaml = loadYaml(pubspecFile.readAsStringSync());

  return yaml["name"];
}

String generateImportPath(
  String filePath,
  String projectRoot,
  String projectName,
) {
  final libIndex = filePath.indexOf("lib/");

  if (libIndex == -1) {
    throw Exception("File must be inside a lib/ folder");
  }

  final relativePath = filePath.substring(libIndex + 4);

  return "package:$projectName/$relativePath";
}
