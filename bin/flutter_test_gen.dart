import 'dart:io';

import 'package:flutter_test_gen/flutter_test_gen.dart';

void main(List<String> args) async {
  if (args.isEmpty ||
      args.contains("--help") ||
      args.contains("-h") ||
      args.contains("help")) {
    _printHelp();
    return;
  }

  final input = args.first;
  final fileName = _normalizeFileName(input);

  // flags
  final append = args.contains("--append");
  final overwrite = args.contains("--overwrite");

  final matches = _findFiles(fileName);

  if (matches.isEmpty) {
    print("File not found inside lib/: $fileName");
    exit(1);
  }

  String filePath;

  if (matches.length == 1) {
    filePath = matches.first;
  } else {
    filePath = _selectFile(matches);
  }

  final generator = TestGenerator();

  await generator.generate(
    filePath,
    append: append || !overwrite, // append is default
    overwrite: overwrite,
  );
}

void _printHelp() {
  print("""
Flutter Test Generator

Usage:
  dart run flutter_test_gen <file> [options]

Examples:
  dart run flutter_test_gen user_service
  dart run flutter_test_gen user_service.dart
  dart run flutter_test_gen lib/user_service.dart

Options:
  --append       Append missing tests (default)
  --overwrite    Recreate the test file
  -h, --help     Show this help message

Behaviour:
  • Generates tests for classes and top-level functions.
  • Restores deleted tests inside existing groups.
  • Restores deleted groups.
  • Skips private methods, mixins and extensions.

Examples:

  Generate tests
    dart run flutter_test_gen user_service

  Overwrite existing tests
    dart run flutter_test_gen user_service --overwrite

  Append only missing tests
    dart run flutter_test_gen user_service --append

""");
}

String _selectFile(List<String> matches) {
  print("Multiple files found:\n");

  for (int i = 0; i < matches.length; i++) {
    final relative = _relativePath(matches[i]);
    print("${i + 1}. $relative");
  }

  stdout.write("\nSelect file: ");

  final input = stdin.readLineSync();

  final index = int.tryParse(input ?? "");

  if (index == null || index < 1 || index > matches.length) {
    print("Invalid selection.");
    exit(1);
  }

  return matches[index - 1];
}

String _relativePath(String absolutePath) {
  final root = Directory.current.path;

  if (absolutePath.startsWith(root)) {
    return absolutePath.substring(root.length + 1);
  }

  return absolutePath;
}

String _normalizeFileName(String input) {
  if (input.endsWith(".dart")) {
    return input;
  }

  return "$input.dart";
}

List<String> _findFiles(String fileName) {
  final root = Directory.current;

  List<String> matches = [];

  for (var entity in root.listSync(recursive: true)) {
    if (entity is File &&
        entity.path.endsWith(fileName) &&
        entity.path.contains(
          "${Platform.pathSeparator}lib${Platform.pathSeparator}",
        )) {
      matches.add(entity.path);
    }
  }

  return matches;
}
