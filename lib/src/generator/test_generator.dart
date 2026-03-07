import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';

import '../parser/dart_parser.dart';
import '../utils/path_utils.dart';
import '../utils/project_utils.dart';
import '../writer/test_writer.dart';
import 'test_builder.dart';

class TestGenerator {
  TestGenerator._internal();

  static final TestGenerator _instance = TestGenerator._internal();

  factory TestGenerator() => _instance;

  Future<void> generate(
    String filePath, {
    bool append = true,
    bool overwrite = false,
  }) async {
    final parser = DartParser();
    final methods = parser.extractMethods(filePath);

    if (methods.isEmpty) {
      print(AnsiStyles.yellow("⚠ No methods found."));
      return;
    }

    final project = ProjectUtil()..initialize(filePath);

    final importPath = project.generateImportPath(filePath);
    final relativePath = PathUtils.relativePath(filePath);
    final testPath = PathUtils.testPath(filePath);

    final file = File(testPath);

    final existing = file.existsSync() ? await file.readAsString() : "";

    final builder = TestBuilder(project);

    final content = builder.generate(
      methods,
      importPath,
      relativePath,
      existing,
      filePath,
    );

    final engine = TestWriter();

    final result = engine.process(
      file: file,
      existing: existing,
      content: content,
      methods: methods,
      relativePath: relativePath,
      append: append,
      overwrite: overwrite,
      imports: builder.generatedImports,
    );

    if (!file.existsSync()) {
      await file.create(recursive: true);
      await file.writeAsString(content);

      print(
        AnsiStyles.green(
          "✓ Generated: ${PathUtils.relativePath(testPath)}",
        ),
      );
      return;
    }

    if (existing.trim().isEmpty) {
      await file.writeAsString(content);

      print(
        AnsiStyles.green(
          "✓ Generated: ${PathUtils.relativePath(testPath)}",
        ),
      );
      return;
    }

    if (overwrite) {
      await file.writeAsString(content);

      print(
        AnsiStyles.magenta(
          "✎ Overwritten: ${PathUtils.relativePath(testPath)}",
        ),
      );
      return;
    }

    if (append) {
      if (result == null || result == existing) {
        print(AnsiStyles.yellow("✓ No new tests to append."));
        return;
      }

      await file.writeAsString(result);

      print(
        AnsiStyles.blue(
          "➕ Appended tests: ${PathUtils.relativePath(testPath)}",
        ),
      );
    }
  }
}
