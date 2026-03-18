import 'dart:io';

import 'package:flutter_test_gen/src/utils/cli_utils.dart';
import 'package:path/path.dart' as path;

/// Resolves a file path from a given file name within the project.
///
/// [FileResolver] is responsible for locating files inside the `lib/`
/// directory using CLI utilities. It handles:
/// - File search
/// - Ambiguity resolution (multiple matches)
/// - User selection when needed
class FileResolver {
  /// Resolves an input path to a valid file or directory within the project.
  ///
  /// This method supports both direct paths and file name lookups:
  /// - Accepts absolute or relative paths
  /// - Attempts to resolve missing `.dart` extensions
  /// - Falls back to searching within the project if the path is not found
  ///
  /// Parameters:
  /// - [input]: File or directory path, or partial file name
  ///
  /// Behavior:
  /// - Determines project root using `_findProjectRoot`
  /// - Resolves relative paths against the project root
  /// - Returns immediately if the path points to an existing file or directory
  /// - Appends `.dart` if not present and searches using [CliUtils.findFiles]
  /// - If multiple matches are found, prompts user selection via [CliUtils.selectFile]
  ///
  /// Returns:
  /// The resolved absolute path to a file or directory.
  ///
  /// Throws:
  /// - [Exception] if no matching file or directory is found
  static String resolve(String input) {
    final root = _findProjectRoot();

    final isAbsolute = path.isAbsolute(input);

    final fullPath =
        isAbsolute ? input : '$root${Platform.pathSeparator}$input';

    /// direct match
    final entityType = FileSystemEntity.typeSync(fullPath);

    if (entityType == FileSystemEntityType.file ||
        entityType == FileSystemEntityType.directory) {
      return fullPath;
    }

    /// NEW: check inside lib/
    final libFolderPath = path.join(root, 'lib', input);

    final folderType = FileSystemEntity.typeSync(libFolderPath);

    if (folderType == FileSystemEntityType.directory) {
      return libFolderPath;
    }

    /// fallback to file search
    final dartInput = input.endsWith('.dart') ? input : '$input.dart';

    final matches = CliUtils.findFiles(dartInput);

    if (matches.isEmpty) {
      throw Exception('File/Directory not found: $input');
    }

    if (matches.length == 1) {
      return matches.first;
    }

    return CliUtils.selectFile(matches);
  }

  static String _findProjectRoot() {
    var dir = Directory.current;

    while (true) {
      final pubspec = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');

      if (pubspec.existsSync()) {
        return dir.path;
      }

      final parent = dir.parent;

      if (parent.path == dir.path) {
        break;
      }

      dir = parent;
    }

    return Directory.current.path;
  }
}
