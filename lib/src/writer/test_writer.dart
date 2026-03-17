import 'dart:io';

import 'package:flutter_test_gen/flutter_test_gen.dart';

/// Handles writing or updating test file content.
///
/// [TestWriter] determines how generated test content should be applied
/// to an existing file based on the selected mode:
/// - Create new file
/// - Overwrite existing content
/// - Append (or update) existing content
///
/// It ensures unnecessary writes are avoided when content has not changed.
class TestWriter {
  /// Creates a new [TestWriter].
  TestWriter();

  /// Processes the generated test content and decides what should be written.
  ///
  /// Parameters:
  /// - [file]: The target test file
  /// - [existing]: Current content of the file
  /// - [content]: Newly generated test content
  /// - [methods]: List of analyzed methods (currently unused, reserved for future use)
  /// - [relativePath]: Relative path of the source file (currently unused)
  /// - [append]: Whether to append/update existing content
  /// - [overwrite]: Whether to overwrite existing content
  /// - [imports]: List of imports (currently unused)
  ///
  /// Behavior:
  /// - Returns [content] if:
  ///   - File does not exist
  ///   - File is empty
  ///   - Overwrite mode is enabled
  /// - In append mode:
  ///   - Returns existing content if unchanged
  ///   - Otherwise returns updated content
  /// - Returns `null` if no action should be taken
  ///
  /// Returns:
  /// - Updated file content as a string
  /// - `null` if no write is required
  String? process({
    required File file,
    required String existing,
    required String content,
    required List<MethodInfo> methods,
    required String relativePath,
    required bool append,
    required bool overwrite,
    required List<String> imports,
  }) {
    /// New file
    if (!file.existsSync()) return content;

    /// Empty file
    if (existing.trim().isEmpty) return content;

    /// Overwrite mode
    if (overwrite) return content;

    /// Append mode
    if (append) {
      if (_isSameContent(existing, content)) {
        return existing; // no change
      }

      return content; // replace with updated full content
    }

    return null;
  }

  /// Compares two content strings after trimming whitespace.
  ///
  /// Returns `true` if both contents are effectively identical.
  bool _isSameContent(String a, String b) => a.trim() == b.trim();
}
