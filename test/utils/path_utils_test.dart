import 'dart:io';

import 'package:flutter_test_gen/src/utils/path_utils.dart';
import 'package:test/test.dart';

void main() {
  group('PathUtils', () {
    test('relativePath should remove project root from absolute path', () {
      final root = Directory.current.path;

      final absolutePath = '$root/lib/services/user_service.dart';

      final result = PathUtils.relativePath(absolutePath);

      expect(result, 'lib/services/user_service.dart');
    });

    test('relativePath should return same path if outside project root', () {
      const absolutePath = '/some/other/project/file.dart';

      final result = PathUtils.relativePath(absolutePath);

      expect(result, absolutePath);
    });

    test('testPath should convert lib path to test path', () {
      const filePath = 'lib/services/user_service.dart';

      final result = PathUtils.testPath(filePath);

      expect(result, 'test/services/user_service_test.dart');
    });

    test('testPath should append _test.dart correctly', () {
      const filePath = 'lib/user_repository.dart';

      final result = PathUtils.testPath(filePath);

      expect(result, 'test/user_repository_test.dart');
    });
  });
}
