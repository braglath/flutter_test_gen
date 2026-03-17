import 'package:flutter_test_gen/src/utils/cli_utils.dart';
import 'package:flutter_test_gen/src/utils/logger.dart';

class CliRunner {
  static Future<void> run(List<String> args) async {
    if (_shouldShowHelp(args)) {
      CliUtils.printHelp();
      return;
    }

    debugMode = args.contains('--debug');

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
