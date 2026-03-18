import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:flutter_test_gen/src/cli/cli_runner.dart';

void main(List<String> args) async {
  final isDebug = args.contains('--debug');

  try {
    await CliRunner.run(args);
  } catch (e, stackTrace) {
    if (isDebug) {
      // Full debug output
      print(AnsiStyles.red('❌ $e'));
      print(stackTrace);
    } else {
      // Clean user-friendly error
      final message = e.toString().replaceFirst('Exception: ', '');
      print(AnsiStyles.red('X $message'));
    }

    exit(1);
  }
}
