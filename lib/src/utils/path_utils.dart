import 'dart:io';

class PathUtils {
  static String relativePath(String absolutePath) {
    final root = Directory.current.path;

    if (absolutePath.startsWith(root)) {
      return absolutePath.substring(root.length + 1);
    }

    return absolutePath;
  }

  static String testPath(String filePath) {
    return filePath
        .replaceFirst("lib", "test")
        .replaceAll(".dart", "_test.dart");
  }
}
