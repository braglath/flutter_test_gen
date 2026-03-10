import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:flutter_test_gen/src/generator/test_builder.dart';
import 'package:flutter_test_gen/src/parser/dart_parser.dart';
import 'package:flutter_test_gen/src/utils/path_utils.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';
import 'package:flutter_test_gen/src/writer/test_writer.dart';

/// A singleton service responsible for generating test files.
///
/// This class ensures only one instance of [TestGenerator] exists
/// throughout the application. It is used to analyze source code
/// and generate corresponding unit test templates.
class TestGenerator {
  TestGenerator._internal();

  static final TestGenerator _instance = TestGenerator._internal();

  /// Returns the single shared instance of [TestGenerator].
  ///
  /// This factory constructor guarantees that only one instance
  /// of the generator is created and reused across the application.
  factory TestGenerator() => _instance;

  /// Generates unit tests for the given source input.
  ///
  /// This method analyzes the provided source file, extracts
  /// classes and methods, and creates corresponding test
  /// templates automatically.
  ///
  /// Returns a [Future] that completes when the test generation
  /// process finishes.
  Future<void> generate(
    String filePath, {
    bool append = true,
    bool overwrite = false,
  }) async {
    final parser = DartParser();
    final methods = parser.extractMethods(filePath);

    /// Detect constructor dependencies
    if (methods.any((m) => m.dependencies.isNotEmpty)) {
      print(
        AnsiStyles.cyan(
          '🔧 Detected constructor dependencies → generating mocks\n',
        ),
      );

      /// Check if mocktail exists in pubspec.yaml
      final pubspec = File('pubspec.yaml');

      if (pubspec.existsSync()) {
        final content = pubspec.readAsStringSync();

        if (!content.contains('mocktail')) {
          print(
            AnsiStyles.yellow(
              '⚠ mocktail dependency missing.\n'
              'Run:\n'
              'flutter pub add mocktail --dev\n',
            ),
          );
        }
      }
    }

    if (methods.isEmpty) {
      print(AnsiStyles.yellow('⚠ No methods found.'));
      return;
    }

    final project = ProjectUtil()..initialize(filePath);

    final importPath = project.generateImportPath(filePath);
    final relativePath = PathUtils.relativePath(filePath);
    final testPath = PathUtils.testPath(filePath);

    final file = File(testPath);

    final existing = file.existsSync() ? await file.readAsString() : '';

    final builder = TestBuilder(project);
    builder.generatedImports.add("import 'package:mocktail/mocktail.dart';");

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
          '✓ Generated: ${PathUtils.relativePath(testPath)}',
        ),
      );
      return;
    }

    if (existing.trim().isEmpty) {
      await file.writeAsString(content);

      print(
        AnsiStyles.green(
          '✓ Generated: ${PathUtils.relativePath(testPath)}',
        ),
      );
      return;
    }

    if (overwrite) {
      await file.writeAsString(content);

      print(
        AnsiStyles.magenta(
          '✎ Overwritten: ${PathUtils.relativePath(testPath)}',
        ),
      );
      return;
    }

    if (append) {
      if (result == null || result == existing) {
        print(AnsiStyles.yellow('✓ No new tests to append.'));
        return;
      }

      await file.writeAsString(result);

      print(
        AnsiStyles.blue(
          '➕ Appended tests: ${PathUtils.relativePath(testPath)}',
        ),
      );
    }
  }
}
