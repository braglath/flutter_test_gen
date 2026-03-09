import 'dart:io';

import 'package:flutter_test_gen/src/utils/cli_utils.dart';
import 'package:test/test.dart';

void main() {
  group('CliUtils.normalizeFileName', () {
    test('adds .dart extension when missing', () {
      final result = CliUtils.normalizeFileName("user_service");

      expect(result, "user_service.dart");
    });

    test('keeps existing .dart extension', () {
      final result = CliUtils.normalizeFileName("user_service.dart");

      expect(result, "user_service.dart");
    });
  });

  group('CliUtils.relativePath', () {
    test('returns relative path when inside project', () {
      final root = Directory.current.path;
      final path = "$root/lib/user_service.dart";

      final result = CliUtils.relativePath(path);

      expect(result, "lib/user_service.dart");
    });

    test('returns original path when outside project', () {
      const path = "/external/project/file.dart";

      final result = CliUtils.relativePath(path);

      expect(result, path);
    });
  });

  group('CliUtils.findFiles', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp("cli_utils_test");

      final libDir = Directory("${tempDir.path}/lib/services");
      libDir.createSync(recursive: true);

      File("${libDir.path}/user_service.dart").createSync();

      Directory.current = tempDir;
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('finds dart file inside lib folder', () {
      final result = CliUtils.findFiles("user_service.dart");

      expect(result.length, 1);
      expect(result.first.endsWith("user_service.dart"), true);
    });

    test('returns empty when file not found', () {
      final result = CliUtils.findFiles("missing.dart");

      expect(result, isEmpty);
    });
  });

  group('CliUtils.runGenerate', () {
    test('returns early when args empty', () async {
      await CliUtils.runGenerate([]);

      expect(true, true); // ensures no crash
    });
  });
}
