import 'package:flutter_test_gen/src/utils/cli_utils.dart';

/// Resolves a file path from a given file name within the project.
///
/// [FileResolver] is responsible for locating files inside the `lib/`
/// directory using CLI utilities. It handles:
/// - File search
/// - Ambiguity resolution (multiple matches)
/// - User selection when needed
class FileResolver {
  /// Resolves the full file path for the given [fileName].
  ///
  /// Behavior:
  /// - Searches for matching files using [CliUtils.findFiles]
  /// - Throws an exception if no matches are found
  /// - Returns the single match if only one file is found
  /// - Prompts the user to select a file if multiple matches exist
  ///
  /// Parameters:
  /// - [fileName]: The name or partial name of the file to locate
  ///
  /// Returns:
  /// The resolved file path as a string.
  ///
  /// Throws:
  /// - [Exception] if no matching files are found
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
