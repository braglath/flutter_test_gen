import 'dart:io';

import 'package:flutter_test_gen/src/cli/cli_runner.dart';
import 'package:flutter_test_gen/src/models/generation_result.dart';
import 'package:flutter_test_gen/src/utils/cli_printer.dart';

void main(List<String> args) async {
  final isDebug = args.contains('--debug');

  try {
    await CliRunner.run(args);
  } catch (e, stackTrace) {
    if (isDebug) {
      // Full debug output
      CliPrinter.printResult(ShowError(e.toString()));
      CliPrinter.printResult(ShowError(stackTrace.toString()));
    } else {
      // Clean user-friendly error
      final message = e.toString().replaceFirst('Exception: ', '');
      CliPrinter.printResult(ShowError(message));
    }

    exit(1);
  }
}
