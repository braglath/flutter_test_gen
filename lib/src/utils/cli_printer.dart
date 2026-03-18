import 'package:flutter_test_gen/src/models/generation_result.dart';
import 'package:flutter_test_gen/src/utils/ansi.dart';

/// Handles printing CLI output based on [GenerationResult].
///
/// [CliPrinter] maps different result states to user-friendly,
/// color-coded console messages using [Ansi] utilities.
///
/// It centralizes all CLI output logic, ensuring:
/// - Consistent formatting
/// - Clear success/error messaging
/// - Easy extensibility for new result types
class CliPrinter {
  /// Prints a formatted message based on the given [result].
  ///
  /// Uses pattern matching on [GenerationResult] to determine
  /// the appropriate output and delegates to internal helpers.
  ///
  /// Behavior:
  /// - Displays success messages (e.g., generated, overwritten)
  /// - Displays warnings (e.g., skipped, no methods found)
  /// - Displays errors (e.g., invalid path, failure)
  /// - Handles informational outputs (e.g., file paths, help)
  /// - Uses ANSI colors for better readability
  ///
  /// Parameters:
  /// - [result]: The result of a generation operation
  ///
  /// Example:
  /// ```dart
  /// CliPrinter.printResult(Generated(path: 'test/user_test.dart'));
  /// ```
  static void printResult(GenerationResult result) {
    switch (result) {
      case Generated(:final path, :final count):
        _generated(path, count);
      case Overwritten(:final path):
        _overwritten(path);
      case Appended(:final path):
        _appended(path);
      case MocksGenerated():
        _mocksGenerated();
      case Skipped(:final path):
        _skipped(path);
      case ErrorResult(:final path, :final message):
        _errorResult(path, message);
      case NoMethodsFound():
        _noMethodsFound();
      case NoNewTest():
        _noNewTest();
      case MultipleFilesFound():
        _multipleFilesFound();
      case InvalidPath(:final path):
        _invalidPath(path);
      case ShowFilePath(:final path):
        _showFilePath(path);
      case CurrentFile(:final file):
        _showCurrentFile(file);
      case ProvideFileName():
        _provideFileName();
      case ShowFolderPath(:final path):
        _showFolderPath(path);
      case ShowRelativePath(:final index, :final path):
        _showRelativePath(index, path);
      case InvalidSelection():
        _invalidSelection();
      case ShowError(:final error):
        _showError(error);
      case AddMockDependency():
        _mockDependencyMissing();
      case ShowHelp():
        _printHelp();
    }
  }

  static void _generated(String? path, int? count) => path == null
      ? print(
          Ansi.green('✓ $count file${count == 1 ? '' : 's'} processed\n'),
        )
      : print(Ansi.green('✓ $path\n'));

  static void _overwritten(String path) => print(Ansi.magenta('✎ $path\n'));

  static void _appended(String path) => print(Ansi.blue('+ $path\n'));

  static void _mocksGenerated() => print(Ansi.cyan('⚙ mocks'));

  static void _skipped(String path) => print(Ansi.yellow('⚠ skipped $path'));

  static void _errorResult(String path, String message) =>
      print(Ansi.red('✖ Failed: $path → $message'));

  static void _noMethodsFound() => print(Ansi.yellow('⚠ No methods found.'));

  static void _noNewTest() => print(Ansi.yellow('✖ No new tests to append.'));

  static void _multipleFilesFound() =>
      print(Ansi.yellow('Multiple files found:\n'));

  static void _invalidPath(String path) =>
      print(Ansi.red('\n✖ Invalid path: $path\n'));

  static void _showFilePath(String path) => print(Ansi.brightCyan('→ $path'));

  static void _showCurrentFile(String file) =>
      print(Ansi.brightCyan('→ $file'));

  static void _provideFileName() =>
      print(Ansi.red('Please provide a file name.'));

  static void _showFolderPath(String path) => print(Ansi.cyan('📂 $path'));

  static void _showRelativePath(int i, String path) =>
      print("${Ansi.cyan("${i + 1}.")} $path");

  static void _invalidSelection() => print(Ansi.red('Invalid selection.'));

  static void _showError(String error) => print(Ansi.red('✖ $error'));

  static void _mockDependencyMissing() => print(
        Ansi.yellow(
          '⚠ mocktail dependency missing.\n'
          'Run:\n'
          'flutter pub add mocktail --dev\n',
        ),
      );

  static void _printHelp() {
    print(
      Ansi.green('''
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
}
