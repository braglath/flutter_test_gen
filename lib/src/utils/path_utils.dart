import 'dart:io';

/// Utility helpers for working with project file paths.
///
/// [PathUtils] provides helper methods used during test generation
/// to convert absolute paths into project-relative paths and to
/// determine the correct test file location for a given source file.
class PathUtils {
  /// Converts an absolute file path into a project-relative path.
  ///
  /// If the provided [absolutePath] starts with the current project
  /// root directory, the root portion is removed so that the returned
  /// value is relative to the project.
  ///
  /// Example:
  /// `/my_project/lib/services/user_service.dart`
  /// → `lib/services/user_service.dart`
  static String relativePath(String absolutePath) {
    final root = Directory.current.path;

    if (absolutePath.startsWith(root)) {
      return absolutePath.substring(root.length + 1);
    }

    return absolutePath;
  }

  /// Converts a source file path into its corresponding test file path.
  ///
  /// This method:
  /// - Replaces the `lib/` directory with `test/`
  /// - Renames the file with a `_test.dart` suffix
  ///
  /// Example:
  /// `lib/services/user_service.dart`
  /// → `test/services/user_service_test.dart`
  static String testPath(String filePath) =>
      filePath.replaceFirst('lib', 'test').replaceAll('.dart', '_test.dart');
}
