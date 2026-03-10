import 'dart:io';

import 'package:flutter_test_gen/src/models/method_parameter.dart';
import 'package:yaml/yaml.dart';

/// Provides project-level utilities used during test generation.
///
/// [ProjectUtil] is responsible for:
/// - Discovering the project root directory
/// - Loading the project name from `pubspec.yaml`
/// - Generating package import paths
/// - Producing default values for parameters and return types
/// - Identifying primitive and enum types
///
/// These helpers allow the generator to create valid test code
/// regardless of where the source file is located within the project.
class ProjectUtil {
  late final String _projectRoot;
  late final String _projectName;

  /// Initializes the project utilities using a source file path.
  ///
  /// This method:
  /// - Locates the project root by searching for `pubspec.yaml`
  /// - Loads the project name from the discovered `pubspec.yaml`
  ///
  /// Must be called before accessing [projectRoot], [projectName],
  /// or methods that depend on them.
  void initialize(String filePath) {
    _projectRoot = _findProjectRoot(filePath);
    _projectName = _loadProjectName();
  }

  /// Returns the absolute path of the project root directory.
  ///
  /// The root is determined by locating the nearest directory
  /// containing a `pubspec.yaml` file.
  String get projectRoot => _projectRoot;

  /// Returns the Dart package name of the project.
  ///
  /// The value is read from the `name` field in `pubspec.yaml`.
  String get projectName => _projectName;

  /// Generates a `package:` import path for a Dart file.
  ///
  /// The provided [filePath] must be located inside the `lib/` folder.
  ///
  /// Example:
  /// `lib/services/user_service.dart`
  ///
  /// → `package:my_app/services/user_service.dart`
  ///
  /// Throws an [ArgumentError] if the file is not inside `lib/`.
  String generateImportPath(String filePath) {
    final libIndex = filePath.indexOf('lib/');

    if (libIndex == -1) {
      throw ArgumentError('File must be inside the lib/ folder');
    }

    final relativePath = filePath.substring(libIndex + 4);

    return 'package:$_projectName/$relativePath';
  }

  // Finds project root by walking up the directory tree
  String _findProjectRoot(String filePath) {
    var dir = File(filePath).parent;

    while (true) {
      final pubspec = File('${dir.path}/pubspec.yaml');

      if (pubspec.existsSync()) {
        return dir.path;
      }

      final parent = dir.parent;

      if (parent.path == dir.path) {
        throw const FileSystemException('pubspec.yaml not found');
      }

      dir = parent;
    }
  }

  /// Loads project name from pubspec.yaml
  String _loadProjectName() {
    final pubspecFile = File('$_projectRoot/pubspec.yaml');

    if (!pubspecFile.existsSync()) {
      throw const FileSystemException('pubspec.yaml not found in project root');
    }

    final yaml = loadYaml(pubspecFile.readAsStringSync()) as Map;

    final String packageName = yaml['name']?.toString() ?? '';

    if (packageName.trim().isEmpty) {
      throw const FormatException('Project name not found in pubspec.yaml');
    }

    return packageName.toString();
  }

  /// Determines whether a given Dart type should be treated as an enum.
  ///
  /// Primitive types such as `String`, `int`, and `bool` are excluded.
  /// Nullable markers (`?`) are ignored during the check.
  ///
  /// This is used when generating parameter values for tests.
  bool isEnumType(String type) => ![
        'String',
        'int',
        'double',
        'bool',
        'DateTime',
        'dynamic',
      ].contains(type.replaceAll('?', ''));

  /// Generates a default value for a method parameter.
  ///
  /// The generated value depends on the parameter type:
  ///
  /// Examples:
  /// - `int` → `1`
  /// - `String` → `'test'`
  /// - `bool` → `true`
  /// - `DateTime` → `DateTime.now()`
  ///
  /// For enum types, the first enum value is used.
  ///
  /// This helps create valid input values in generated tests.
  String generateValue(MethodParameter param) {
    final type = param.type.replaceAll('?', '');

    if (ProjectUtil().isEnumType(type)) {
      return '$type.${defaultEnumValue(type)}';
    }

    switch (type) {
      case 'int':
        return '1';
      case 'String':
        return "'test'";
      case 'bool':
        return 'true';
      case 'double':
        return '1.0';
      case 'DateTime':
        return 'DateTime.now()';
      default:
        return '$type()';
    }
  }

  /// Returns the default enum value expression used in tests.
  ///
  /// By default, this returns `values.first`.
  ///
  /// Example:
  /// `UserRole.values.first`
  String defaultEnumValue(String enumName) => 'values.first';

  /// Generates a standard mock variable name for a type.
  ///
  /// Example:
  /// `UserRepository` → `mockUserRepository`
  String mockName(String type) => 'mock$type';

  /// Determines whether a type is considered primitive.
  ///
  /// Primitive types typically do not require mocking and
  /// can be assigned simple literal values.
  static bool isPrimitive(String type) => const [
        'String',
        'int',
        'double',
        'bool',
        'num',
        'DateTime',
        'dynamic',
      ].contains(type);

  /// Generates a mock return configuration for a mocked method.
  ///
  /// If the return type is a `Future<T>`, an asynchronous answer
  /// is generated. Otherwise, a direct return value is used.
  ///
  /// Examples:
  /// - `Future<int>` → `thenAnswer((_) async => 1)`
  /// - `String` → `thenReturn('test')`
  String mockReturnValue(String returnType) {
    if (returnType.startsWith('Future<')) {
      final inner =
          returnType.replaceFirst('Future<', '').replaceFirst('>', '');

      final value = primitiveValue(inner);

      return 'thenAnswer((_) async => $value)';
    }

    return 'thenReturn(${primitiveValue(returnType)})';
  }

  /// Returns a primitive value suitable for assertions in generated tests.
  ///
  /// Example mappings:
  /// - `int` → `1`
  /// - `double` → `1.0`
  /// - `bool` → `true`
  /// - `String` → `'test'`
  ///
  /// For unsupported types, `null` is returned.
  String primitiveValue(String type) {
    if (type.startsWith('Future<')) {
      final inner = type.replaceFirst('Future<', '').replaceFirst('>', '');
      return primitiveValue(inner);
    }

    switch (type) {
      case 'int':
        return '1';
      case 'double':
        return '1.0';
      case 'bool':
        return 'true';
      case 'String':
        return "'test'";
      default:
        return 'null';
    }
  }
}
