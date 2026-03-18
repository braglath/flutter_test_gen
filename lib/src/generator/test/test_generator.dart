import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_test_gen/src/generator/test/test_file_builder.dart';
import 'package:flutter_test_gen/src/parser/dart/dart_parser.dart';
import 'package:flutter_test_gen/src/utils/path_utils.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';
import 'package:flutter_test_gen/src/writer/test_writer.dart';
import 'package:path/path.dart' as path;

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
    if (methods.any((m) =>
        m.constructorDependencies.isNotEmpty ||
        m.parameterDependencies.isNotEmpty)) {
      print(
        AnsiStyles.cyan('    ⚙ mocks'),
      );

      /// Check if mocktail exists in pubspec.yaml
      final project = ProjectUtil()..initialize(filePath);
      project.detectMocktailDependency(project.projectRoot);
    }

    if (methods.isEmpty) {
      print(AnsiStyles.yellow('⚠ No methods found.'));
      return;
    }

    final project = ProjectUtil()..initialize(filePath);

    final importPath = project.normalizeImport(filePath);
    final relativePath = PathUtils.relativePath(filePath);
    final testPath = PathUtils.testPath(filePath);

    final file = File(testPath);

    final existing = file.existsSync() ? await file.readAsString() : '';

    final builder = TestFileBuilder(project);

    if (methods.any((m) =>
        m.constructorDependencies.isNotEmpty ||
        m.parameterDependencies.isNotEmpty)) {
      builder.generatedImports
        ..add("import 'package:mocktail/mocktail.dart';")
        ..retainWhere((e) => true); // no-op but allows modification
    }
    final content = builder.build(
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
      imports: builder.generatedImports.toList(),
    );

    if (!file.existsSync()) {
      await file.create(recursive: true);
      final formattedContent = _format(content);
      await file.writeAsString(formattedContent);

      print(
        AnsiStyles.green(
          '    ✓ ${PathUtils.relativePath(testPath)}',
        ),
      );
      return;
    }

    if (existing.trim().isEmpty) {
      final formattedContent = _format(content);
      await file.writeAsString(formattedContent);

      print(
        AnsiStyles.green(
          '    ✓ ${PathUtils.relativePath(testPath)}',
        ),
      );
      return;
    }

    if (overwrite) {
      final formattedContent = _format(content);
      await file.writeAsString(formattedContent);

      print(
        AnsiStyles.magenta(
          '    ✎ ${PathUtils.relativePath(testPath)}',
        ),
      );
      return;
    }

    if (append) {
      if (result == null || result == existing) {
        print(AnsiStyles.yellow('X No new tests to append.'));
        return;
      }

      final formattedContent = _format(result);
      await file.writeAsString(formattedContent);

      print(
        AnsiStyles.blue(
          '    + ${PathUtils.relativePath(testPath)}',
        ),
      );
    }
  }

  String _format(String code) {
    try {
      final formatter = DartFormatter(
        languageVersion: DartFormatter.latestLanguageVersion,
      );
      return formatter.format(code);
    } catch (_) {
      return code;
    }
  }

  /// Generates test files for all Dart files within a directory.
  ///
  /// Recursively scans the given [dirPath] for `.dart` files and
  /// generates tests for each eligible file.
  ///
  /// Parameters:
  /// - [dirPath]: Path to the target directory
  /// - [append]: Whether to append/update existing test files
  /// - [overwrite]: Whether to overwrite existing test files
  ///
  /// Behavior:
  /// - Validates that the directory exists
  /// - Recursively processes all `.dart` files
  /// - Skips ignored files using `_shouldIgnore`
  /// - Calls `generate` for each file
  /// - Logs progress and errors to the console
  /// - Continues processing even if some files fail
  ///
  /// Output:
  /// - Prints each processed file name
  /// - Displays a success summary with total processed files
  ///
  /// Throws:
  /// - [Exception] if the directory does not exist
  Future<void> generateForDirectory(
    String dirPath, {
    required bool append,
    required bool overwrite,
  }) async {
    final dir = Directory(dirPath);

    if (!dir.existsSync()) {
      throw Exception('Directory not found: $dirPath');
    }

    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !_shouldIgnore(file.path));

    int count = 0;

    for (final file in files) {
      try {
        print('  → ${path.basename(file.path)}');

        await generate(
          file.path,
          append: append,
          overwrite: overwrite,
        );

        count++;
      } catch (e) {
        print('❌ Failed: ${file.path} -> $e');
      }
    }
    print(
      AnsiStyles.green('✓ $count file${count == 1 ? '' : 's'} processed'),
    );
  }

  bool _shouldIgnore(String path) =>
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart') ||
      path.contains('/test/') ||
      path.contains('.mocks.dart');
}
