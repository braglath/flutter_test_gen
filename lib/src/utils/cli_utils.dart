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

    final filePath = FileResolver.resolve(options.input);
    final entityType = FileSystemEntity.typeSync(filePath);

    if (entityType == FileSystemEntityType.file) {
      print(AnsiStyles.cyan('→ ${relativePath(filePath)}'));
    } else if (entityType == FileSystemEntityType.directory) {
      print(AnsiStyles.cyan('📂 ${relativePath(filePath)}'));
    }

    final generator = TestGenerator();

    if (entityType == FileSystemEntityType.file) {
      await _generateForFile(
        generator: generator,
        filePath: filePath,
        append: options.append,
        overwrite: options.overwrite,
      );
    } else if (entityType == FileSystemEntityType.directory) {
      await _generateForDirectory(
        generator: generator,
        filePath: filePath,
        append: options.append,
        overwrite: options.overwrite,
      );
    } else {
      print(
        AnsiStyles.red(
          '\n❌ Invalid path: $filePath\n',
        ),
      );
      exit(1);
    }
  }

  static Future<void> _generateForFile({
    required String filePath,
    required TestGenerator generator,
    required bool append,
    required bool overwrite,
  }) async =>
      await generator.generate(
        filePath,
        append: append,
        overwrite: overwrite,
      );

  static Future<void> _generateForDirectory({
    required String filePath,
    required TestGenerator generator,
    required bool append,
    required bool overwrite,
  }) async =>
      await generator.generateForDirectory(
        filePath,
        append: append,
        overwrite: overwrite,
      );

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
Flutter Test Gen

Usage:
  flutter_test_gen <path> [options]

Examples:
  flutter_test_gen user_service
  flutter_test_gen lib/src/utils
  flutter_test_gen user_service --overwrite

Options:
  --append        Append missing tests (default)
  --overwrite     Replace entire test file
  --debug         Show verbose logs
  -h, --help      Show this help message

Notes:
  • Supports both files and directories
  • Recursively scans directories
  • Skips generated files (.g.dart, .freezed.dart)

Examples:

  Generate tests
    dart run flutter_test_gen user_service

  Overwrite existing tests
    dart run flutter_test_gen user_service --overwrite

  Append only missing tests
    dart run flutter_test_gen user_service --append
'''),
    );
  }

  /// Prompts the user to select a file when multiple matches are found.
  ///
  /// Displays a numbered list of matching files and reads user input
  /// from the console to determine the selected file.
  ///
  /// Behavior:
  /// - Prints all matching files with indices
  /// - Accepts user input for selection
  /// - Validates the selected index
  /// - Exits the process if the input is invalid
  ///
  /// Parameters:
  /// - [matches]: List of file paths that matched the search query
  ///
  /// Returns:
  /// The selected file path from the list.
  ///
  /// Exits:
  /// - Terminates the process with exit code `1` if the selection is invalid
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
