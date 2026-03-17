import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:flutter_test_gen/flutter_test_gen.dart';
import 'package:flutter_test_gen/src/models/cli_options.dart';
import 'package:flutter_test_gen/src/services/file_resolver.dart';

/// Utility helpers for the command-line interface of `flutter_test_gen`.
///
/// [CliUtils] handles argument parsing, file discovery, and execution of
/// the test generation process. It also provides helper methods for
/// displaying help messages and resolving file paths.
class CliUtils {
  CliUtils._();

  /// Executes the test generation command from CLI arguments.
  ///
  /// This method:
  /// - Validates user input.
  /// - Normalizes the provided file name.
  /// - Searches for matching files inside the `lib/` directory.
  /// - Prompts the user if multiple matches are found.
  /// - Invokes [TestGenerator] to generate the test file.
  ///
  /// Supported flags:
  /// - `--append` : Append missing tests to an existing test file.
  /// - `--overwrite` : Recreate the entire test file.
  ///
  /// If no file is provided or the file cannot be found, an error
  /// message is printed and the process exits.
  static Future<void> runGenerate(List<String> args) async {
    if (args.isEmpty) {
      print(AnsiStyles.red('Please provide a file name.'));
      exit(1);
    }

    final options = CliOptions.fromArgs(args);
    final fileName = CliUtils.normalizeFileName(options.input);

    final filePath = FileResolver.resolve(fileName);

    print(
      AnsiStyles.cyan(
        '\n🚀 Generating tests for ${relativePath(filePath)}\n',
      ),
    );

    final generator = TestGenerator();

    await generator.generate(
      filePath,
      append: options.append,
      overwrite: options.overwrite,
    );
  }

  /// Prints the CLI help message.
  ///
  /// Displays usage instructions, available options, and example commands
  /// for generating tests using `flutter_test_gen`.
  ///
  /// This method is typically triggered when the user runs:
  /// - `flutter_test_gen --help`
  /// - `flutter_test_gen -h`
  static void printHelp() {
    print(
      AnsiStyles.green('''
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
'''),
    );
  }

  static String selectFile(List<String> matches) {
    print(AnsiStyles.yellow('Multiple files found:\n'));

    for (int i = 0; i < matches.length; i++) {
      final relative = relativePath(matches[i]);
      print("${AnsiStyles.cyan("${i + 1}.")} $relative");
    }

    stdout.write('\nSelect file: ');

    final input = stdin.readLineSync();

    final index = int.tryParse(input ?? '');

    if (index == null || index < 1 || index > matches.length) {
      print(AnsiStyles.red('Invalid selection.'));
      exit(1);
    }

    return matches[index - 1];
  }

  /// Converts an absolute file path into a project-relative path.
  ///
  /// If the path starts with the current project root directory,
  /// the root portion is removed so that the returned value is
  /// easier to read in CLI output.
  ///
  /// Example:
  /// `/project/lib/services/user_service.dart`
  /// → `lib/services/user_service.dart`
  static String relativePath(String absolutePath) {
    final root = Directory.current.path;

    if (absolutePath.startsWith(root)) {
      return absolutePath.substring(root.length + 1);
    }

    return absolutePath;
  }

  /// Normalizes a file name provided through CLI arguments.
  ///
  /// If the provided [input] does not include the `.dart` extension,
  /// it will be automatically appended.
  ///
  /// Example:
  /// `user_service` → `user_service.dart`
  static String normalizeFileName(String input) {
    if (input.endsWith('.dart')) {
      return input;
    }

    return '$input.dart';
  }

  /// Searches for Dart files matching [fileName] inside the project.
  ///
  /// The search scans the current project directory recursively and
  /// only returns files located inside the `lib/` folder.
  ///
  /// This allows users to provide partial file names while still
  /// locating the correct source file.
  ///
  /// Example:
  /// Searching for `user_service.dart` might return:
  /// `lib/services/user_service.dart`
  ///
  /// Returns a list of matching file paths.
  static List<String> findFiles(String fileName) {
    final root = Directory.current;
    // final root = Directory("lib");

    final List<String> matches = [];

    for (var entity in root.listSync(recursive: true)) {
      if (entity is File &&
          entity.path.endsWith(fileName) &&
          entity.path.contains(
            '${Platform.pathSeparator}lib${Platform.pathSeparator}',
          )) {
        matches.add(entity.path);
      }
    }

    return matches;
  }
}
