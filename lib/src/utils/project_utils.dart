import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:flutter_test_gen/flutter_test_gen.dart';
import 'package:flutter_test_gen/src/generator/type_value_generator.dart';
import 'package:flutter_test_gen/src/models/method_parameter.dart';
import 'package:flutter_test_gen/src/utils/logger_utils.dart';
import 'package:path/path.dart' as p;
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
  String generateImportPath(
    String filePath, {
    String? currentFilePath,
  }) {
    filePath = p.normalize(filePath);

    debugLog('filePath (input): $filePath');

    // ✅ Already correct
    if (filePath.startsWith('package:')) {
      return filePath;
    }

    if (filePath.startsWith('dart:')) {
      return filePath;
    }

    // ✅ Resolve relative ONLY if needed
    if (!p.isAbsolute(filePath)) {
      if (currentFilePath == null) {
        throw ArgumentError(
          'Relative path requires currentFilePath: $filePath',
        );
      }

      final currentDir = p.dirname(currentFilePath);
      filePath = p.normalize(p.join(currentDir, filePath));

      debugLog('filePath (resolved): $filePath');
    }

    // ✅ Convert to project-relative
    if (filePath.startsWith(_projectRoot)) {
      filePath = p.relative(filePath, from: _projectRoot);
    }

    if (filePath.startsWith('$_projectName/')) {
      filePath = filePath.replaceFirst('$_projectName/', '');
    }

    if (!filePath.startsWith('lib/')) {
      throw ArgumentError('File must be inside lib/: $filePath');
    }

    final relative = filePath.substring(4);

    return 'package:$_projectName/$relative';
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
  // bool isEnumType(String type) {
  // final clean = type.replaceAll('?', '');

  // if (isPrimitive(clean)) return false;

  // // enums never have generics
  // if (clean.contains('<')) return false;

  // // repository / service / model classes should not be enums
  // if (clean.endsWith('Repository') ||
  //     clean.endsWith('Service') ||
  //     clean.endsWith('Model')) {
  //   return false;
  // }

  // return false; // fallback
  // }

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
    final generatedString = TypeValueGenerator.generate(
      param.type,
      isEnum: param.isEnum,
    );

    debugLog('generateValue(Arrange): $generatedString');

    return generatedString;
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
  bool isPrimitive(String type) => const [
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

      final value = primitiveValueForMock(inner);

      return 'thenAnswer((_) async => $value)';
    }

    return 'thenReturn(${primitiveValueForMock(returnType)})';
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
  String primitiveValueForAssert(String type) {
    if (type.startsWith('Future<')) {
      final inner = type.replaceFirst('Future<', '').replaceFirst('>', '');
      return primitiveValueForAssert(inner);
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
        return 'isA<$type>()';
    }
  }

  /// Returns a primitive mock value for a given Dart [type].
  ///
  /// This method is mainly used while generating test code to automatically
  /// provide placeholder values for method parameters or return types.
  ///
  /// Supported primitive mappings:
  /// - `int` → `1`
  /// - `double` → `1.0`
  /// - `bool` → `true`
  /// - `String` → `'test'`
  /// - `dynamic` → `'test'`
  ///
  /// If the type is a `Future<T>`, the method extracts the inner type `T`
  /// and recursively resolves a primitive value for it.
  ///
  /// For any unsupported or custom type, it returns a default constructor
  /// call with a placeholder value:
  ///
  /// Example:
  /// ```dart
  /// primitiveValueForMock('User') -> User('test')
  /// ```
  ///
  /// This helps generated tests compile even when complex types are used.
  ///
  /// Example usage:
  /// ```dart
  /// final value = primitiveValueForMock('int'); // returns '1'
  /// ```
   String primitiveValueForMock(String type) {
    if (type.startsWith('Future<')) {
      final inner = type.replaceFirst('Future<', '').replaceFirst('>', '');
      return primitiveValueForMock(inner);
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
      case 'dynamic':
        return "'test'";
      default:
        return '$type()';
    }
  }

  /// Detects whether the `mocktail` dependency is present in a Flutter project.
  ///
  /// This function reads the project's `pubspec.yaml` file and checks
  /// both `dependencies` and `dev_dependencies` sections to verify if
  /// the `mocktail` package is included.
  ///
  /// If `mocktail` is not found, a warning message is printed in the console
  /// suggesting the command required to add it.
  ///
  /// Recommended command:
  /// ```bash
  /// flutter pub add mocktail --dev
  /// ```
  ///
  /// Parameters:
  /// - [projectRoot]: The root directory path of the Flutter project.
  ///
  /// This check is useful for tools that generate unit tests requiring
  /// `mocktail` for mocking dependencies.
  void detectMocktailDependency(String projectRoot) {
    final pubspec = File('$projectRoot/pubspec.yaml');

    if (!pubspec.existsSync()) return;

    final YamlMap yaml = loadYaml(pubspec.readAsStringSync()) as YamlMap;

    final devDeps = yaml['dev_dependencies'] as Map?;
    final deps = yaml['dependencies'] as Map?;

    final hasMocktail = (devDeps?.containsKey('mocktail') ?? false) ||
        (deps?.containsKey('mocktail') ?? false);

    if (!hasMocktail) {
      print(
        AnsiStyles.yellow(
          '⚠ mocktail dependency missing.\n'
          'Run:\n'
          'flutter pub add mocktail --dev\n',
        ),
      );
    }
  }

  /// Determines whether a Dart type should be treated as a simple
  /// instantiable object during test generation.
  ///
  /// A *simple object* is a type that can be safely instantiated using
  /// its default constructor instead of being mocked.
  ///
  /// This typically includes:
  /// - Data models
  /// - DTOs
  /// - Value objects
  /// - Plain classes without external dependencies
  ///
  /// The method excludes common dependency types that should usually
  /// be mocked in tests, such as:
  /// - `Repository`
  /// - `Service`
  /// - `Client`
  /// - `Datasource`
  ///
  /// Primitive types are also excluded because they are handled
  /// separately by [isPrimitive].
  ///
  /// Example:
  /// ```dart
  /// isSimpleObject('User')            // true
  /// isSimpleObject('UserRepository')  // false
  /// isSimpleObject('ApiClient')       // false
  /// isSimpleObject('String')          // false
  /// ```
  ///
  /// This helper is used by the test generator to decide whether to:
  /// - instantiate a parameter directly (`User()`)
  /// - or generate a mock (`MockUserRepository`)
  bool isSimpleObject(String type) =>
      !isPrimitive(type) &&
      !type.endsWith('Repository') &&
      !type.endsWith('Service') &&
      !type.endsWith('Client') &&
      !type.endsWith('Datasource') &&
      !type.endsWith('Error');

  /// Attempts to resolve the return type of a dependency method.
  ///
  /// This method inspects the source file referenced by [sourceImport]
  /// and searches for a method named [methodName] inside the dependency
  /// class [dependencyType].
  ///
  /// If the method returns a `Future<T>`, the inner type `T` is extracted
  /// and returned. This is useful when generating mocks for async
  /// repository or service calls.
  ///
  /// Example:
  /// ```dart
  /// abstract class UserRepository {
  ///   Future<User> fetchUser(String id);
  /// }
  /// ```
  ///
  /// Calling:
  /// ```dart
  /// resolveDependencyReturnType(
  ///   'UserRepository',
  ///   'fetchUser',
  ///   'package:app/repository/user_repository.dart',
  /// )
  /// ```
  ///
  /// Returns:
  /// ```dart
  /// 'User'
  /// ```
  ///
  /// Returns `null` if:
  /// - the source file cannot be located
  /// - the method signature cannot be detected
  /// - the return type is not a `Future<T>`
  String? resolveDependencyReturnType(
    String dependencyType,
    String methodName,
    String sourceImport,
  ) {
    final filePath = sourceImport.replaceFirst('package:', 'lib/');

    final file = File(filePath);

    if (!file.existsSync()) return null;

    final content = file.readAsStringSync();

    final regex = RegExp(r'Future<([\w<>?, ]+)>\s+' + methodName + r'\(');

    final match = regex.firstMatch(content);

    if (match != null) {
      return match.group(1);
    }

    return null;
  }

  /// Builds a constructor invocation string for a given class [type].
  ///
  /// The [fields] map should contain constructor parameter names
  /// and their corresponding types. Each field is automatically
  /// populated with a primitive mock value using
  /// [primitiveValueForMock].
  ///
  /// Example:
  /// ```dart
  /// fields = {
  ///   'name': 'String',
  ///   'age': 'int'
  /// }
  /// ```
  ///
  /// Result:
  /// ```dart
  /// User(name: 'test', age: 1)
  /// ```
  ///
  /// This helper is used during test generation to automatically
  /// construct model objects returned from mocked dependencies.
  String buildObject(String type, Map<String, String> fields) {
    final args = fields.entries
        .map((e) => '${e.key}: ${primitiveValueForMock(e.value)}')
        .join(', ');

    return '$type($args)';
  }

  /// Generates a readable test name for a method.
  ///
  /// If the method returns a primitive type (such as `String`, `int`,
  /// `bool`, etc.), a descriptive test name is generated in the format:
  ///
  /// ```
  /// returns <type> when <method> succeeds
  /// ```
  ///
  /// Example:
  /// ```dart
  /// returns string when fetchUserName succeeds
  /// ```
  ///
  /// For non-primitive return types, the method name itself is used
  /// as the test name.
  ///
  /// This helps produce consistent and readable test descriptions
  /// across generated unit tests.
  String buildTestName(MethodInfo method, String returnType) {
    if (isPrimitive(returnType)) {
      return 'returns ${returnType.toLowerCase()} when ${method.methodName} succeeds';
    }

    return method.methodName;
  }

  /// Normalizes an import path for generated test files.
  ///
  /// If the given [path] already uses a `package:` or `dart:` scheme,
  /// it is returned unchanged. Otherwise, the path is converted into
  /// a valid `package:` import using the current project's package name
  /// via [ProjectUtil.generateImportPath].
  ///
  /// Example:
  /// ```dart
  /// normalizeImport(project, 'lib/services/user_service.dart')
  /// // → package:my_app/services/user_service.dart
  /// ```
  String normalizeImport(
    String path, {
    String? currentFilePath,
  }) {
    if (path.startsWith('package:') || path.startsWith('dart:')) {
      return path;
    }

    return generateImportPath(
      path,
      currentFilePath: currentFilePath,
    );
  }
}
