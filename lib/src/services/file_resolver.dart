import 'package:flutter_test_gen/src/utils/cli_utils.dart';

class FileResolver {
  static String resolve(String fileName) {
    final matches = CliUtils.findFiles(fileName);

    if (matches.isEmpty) {
      throw Exception('File not found inside lib/: $fileName');
    }

    if (matches.length == 1) {
      return matches.first;
    }

    return CliUtils.selectFile(matches);
  }
}
