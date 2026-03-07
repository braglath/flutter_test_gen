import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:flutter_test_gen/flutter_test_gen.dart';

void main(List<String> args) async {
  if (args.isEmpty ||
      args.contains("--help") ||
      args.contains("-h") ||
      args.first == "help") {
    _printHelp();
    return;
  }

  final command = args.first;

  switch (command) {
    case "generate":
      await _runGenerate(args.skip(1).toList());
      break;

    default:
      // backward compatibility
      await _runGenerate(args);
  }
}

Future<void> _runGenerate(List<String> args) async {
  if (args.isEmpty) {
    print(AnsiStyles.red("Please provide a file name."));
    return;
  }

  final input = args.first;
  final fileName = _normalizeFileName(input);

  final append = args.contains("--append");
  final overwrite = args.contains("--overwrite");

  final matches = _findFiles(fileName);

  if (matches.isEmpty) {
    print(
      AnsiStyles.red("❌ File not found inside lib/: $fileName"),
    );
    exit(1);
  }

  String filePath;

  if (matches.length == 1) {
    filePath = matches.first;
  } else {
    filePath = _selectFile(matches);
  }

  print(
    AnsiStyles.cyan(
      "\n🚀 Generating tests for ${_relativePath(filePath)}\n",
    ),
  );

  final generator = TestGenerator();

  await generator.generate(
    filePath,
    append: append || !overwrite,
    overwrite: overwrite,
  );
}

void _printHelp() {
  print(
    AnsiStyles.green("""
Flutter Test Generator

Usage:
  dart run flutter_test_gen <file> [options]
  dart run flutter_test_gen generate <file> [options]

Examples:
  dart run flutter_test_gen generate user_service
  dart run flutter_test_gen generate user_service.dart
  dart run flutter_test_gen generate lib/user_service.dart

Options:
  --append       Append missing tests (default)
  --overwrite    Recreate the test file
  -h, --help     Show this help message

Behavior:
  • Generates tests for classes and top-level functions
  • Restores deleted tests inside existing groups
  • Restores deleted groups
  • Skips private methods, mixins and extensions

Examples:

  Generate tests
    dart run flutter_test_gen generate user_service

  Overwrite existing tests
    dart run flutter_test_gen generate user_service --overwrite

  Append only missing tests
    dart run flutter_test_gen generate user_service --append
"""),
  );
}

String _selectFile(List<String> matches) {
  print(AnsiStyles.yellow("Multiple files found:\n"));

  for (int i = 0; i < matches.length; i++) {
    final relative = _relativePath(matches[i]);
    print("${AnsiStyles.cyan("${i + 1}.")} $relative");
  }

  stdout.write("\nSelect file: ");

  final input = stdin.readLineSync();

  final index = int.tryParse(input ?? "");

  if (index == null || index < 1 || index > matches.length) {
    print(AnsiStyles.red("Invalid selection."));
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
  // final root = Directory("lib");

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
