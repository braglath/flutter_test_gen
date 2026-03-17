import 'package:flutter_test_gen/src/analyzer/dependency/dependency_analyzer.dart';
import 'package:flutter_test_gen/src/analyzer/type/property_access_resolver.dart';
import 'package:flutter_test_gen/src/models/parameter_info.dart';
import 'package:flutter_test_gen/src/models/switch_case_info.dart';

/// Represents metadata about a method discovered during source code analysis.
///
/// [MethodInfo] is used by the test generator to understand how a method
/// should be tested. It contains information such as the class the method
/// belongs to, its return type, parameters, and injected dependencies.
class MethodInfo {
  /// The name of the class that contains the method.
  ///
  /// If the method is a top-level function, this will be `__top_level__`.
  final String className;

  /// The name of the method or function.
  final String methodName;

  /// The return type of the method.
  ///
  /// Examples:
  /// - `String`
  /// - `Future<int>`
  /// - `void`
  final String returnType;

  /// Indicates whether the method is asynchronous.
  ///
  /// Typically true when the return type is `Future` or `Future<T>`.
  final bool isAsync;

  /// Indicates whether the method is declared as `static`.
  final bool isStatic;

  /// The list of parameters required by the method.
  ///
  /// Each parameter is represented by a [ParameterInfo].
  final List<ParameterInfo> parameters;

  /// The list of dependencies required by the class constructor.
  ///
  /// These dependencies are typically used for generating mock
  /// objects in unit tests.
  final List<Dependency> constructorDependencies;

  /// Dependencies that originate from the method parameters.
  ///
  /// These are parameters whose types represent external collaborators
  /// that may need to be mocked or stubbed when generating tests.
  ///
  /// Unlike [constructorDependencies], which come from the class
  /// constructor injection, these dependencies are passed directly
  /// into the method call.
  ///
  /// Example:
  /// ```dart
  /// void login(AuthService authService)
  /// ```
  ///
  /// In this case, `AuthService` would appear in [parameterDependencies].
  final List<Dependency> parameterDependencies;

  /// Represents detected switch pattern cases within a method.
  ///
  /// This field is populated by the parser when it detects a
  /// `switch` expression or `switch` statement that performs
  /// pattern matching on sealed classes.
  ///
  /// Each [SwitchCaseInfo] contains:
  /// - the variable being switched on
  /// - the concrete types used in the cases
  ///
  /// Example detected pattern:
  /// ```dart
  /// return switch (error) {
  ///   UserNotFound() => local.invalidUser,
  ///   UserBlocked() => "User blocked",
  ///   _ => "Unknown error",
  /// };
  /// ```
  ///
  /// This allows the test generator to automatically create
  /// separate test cases for each detected type.
  final List<SwitchCaseInfo> switchCases;

  /// Stores the import directives from the original source file.
  ///
  /// These imports are extracted from the parsed `CompilationUnit`
  /// and propagated to the generated test file to ensure that all
  /// referenced types (such as models, errors, or localization
  /// classes) are correctly resolved.
  ///
  /// Example:
  /// ```dart
  /// import '../errors/user_error.dart';
  /// import '../localization/app_local.dart';
  /// ```
  ///
  /// During test generation these imports are converted into
  /// `package:` imports based on the project name.
  final List<String> sourceImports;

  /// Information about properties accessed inside the method body.
  ///
  /// These represent field or getter accesses performed within the method.
  /// The generator uses this information to understand interactions with
  /// class members or injected dependencies.
  ///
  /// Example:
  /// ```dart
  /// userRepository.save(user);
  /// ```
  ///
  /// Here, `userRepository` would be recorded as a property access.
  ///
  /// This data helps the test generator:
  /// - Detect dependency interactions
  /// - Generate `verify()` statements
  /// - Improve test coverage by tracking method side effects
  final List<PropertyAccessInfo> propertyAccesses;

  /// Creates a new [MethodInfo] describing a discovered method.
  ///
  /// All fields are required to ensure the test generator has
  /// complete metadata for generating test cases.
  MethodInfo({
    required this.className,
    required this.methodName,
    required this.returnType,
    required this.isAsync,
    required this.isStatic,
    required this.parameters,
    required this.constructorDependencies,
    required this.parameterDependencies,
    required this.propertyAccesses,
    this.switchCases = const [],
    this.sourceImports = const [],
  });

  /// Returns `true` if the method is a top-level function.
  ///
  /// Top-level functions are grouped separately from class methods
  /// in generated tests.
  bool get isTopLevel => className == '__top_level__';

  /// Returns `true` if the method has one or more parameters.
  bool get hasParameters => parameters.isNotEmpty;

  /// Returns `true` if the method returns `void` or `dynamic`.
  ///
  /// This helps the test generator determine whether an assertion
  /// should be written for the method result.
  bool get isVoid => returnType.contains('void') || returnType == 'dynamic';

  @override
  String toString() =>
      'MethodInfo{className=$className, methodName=$methodName, returnType=$returnType, constructor=$constructorDependencies, parameter=$parameterDependencies, property=$propertyAccesses, switchCase=$switchCases, sourceImport=$sourceImports, isAsync=$isAsync, isStatic=$isStatic, parameters=$parameters, isTopLevel=$isTopLevel, hasParameters=$hasParameters, isVoid=$isVoid}';
}
