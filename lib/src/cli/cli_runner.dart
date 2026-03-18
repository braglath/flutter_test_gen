import 'package:flutter_test_gen/src/models/generation_result.dart';
import 'package:flutter_test_gen/src/utils/cli_printer.dart';
import 'package:flutter_test_gen/src/utils/cli_utils.dart';

/// Entry point for handling CLI execution.
///
/// [CliRunner] is responsible for parsing command-line arguments
/// and triggering the appropriate actions for the tool.
///
/// The [run] method:
/// - Validates input arguments
/// - Displays help information when requested
/// - Delegates execution to the appropriate generators or handlers
class CliRunner {
  /// Executes the CLI with the provided [args].
  ///
  /// If help flags (e.g., `--help`, `-h`) are detected,
  /// it prints usage instructions via [CliUtils.printHelp]
  /// and exits early.
  ///
  /// Otherwise, it continues processing the command.
  static Future<void> run(List<String> args) async {
    if (_shouldShowHelp(args)) {
      CliPrinter.printResult(ShowHelp());
      return;
    }

    final command = args.first;

    switch (command) {
      case 'generate':
        await CliUtils.runGenerate(args.skip(1).toList());
        break;

      default:
        await CliUtils.runGenerate(args);
    }
  }

  static bool _shouldShowHelp(List<String> args) =>
      args.isEmpty ||
      args.contains('--help') ||
      args.contains('-h') ||
      args.first == 'help';
}
