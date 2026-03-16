import 'package:flutter_test_gen/src/utils/cli_utils.dart';
import 'package:flutter_test_gen/src/utils/logger_utils.dart';

void main(List<String> args) async {
  if (args.isEmpty ||
      args.contains('--help') ||
      args.contains('-h') ||
      args.first == 'help') {
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
      // backward compatibility
      await CliUtils.runGenerate(args);
  }
}
