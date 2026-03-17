import 'dart:io';

import 'package:flutter_test_gen/src/models/method_info.dart';

class TestWriter {
  TestWriter();

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

  bool _isSameContent(String a, String b) => a.trim() == b.trim();
}
