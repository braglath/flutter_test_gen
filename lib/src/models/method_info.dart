import 'package:flutter_test_gen/src/di/dependency_resolver.dart';
import 'package:flutter_test_gen/src/models/method_parameter.dart';

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
  /// Each parameter is represented by a [MethodParameter].
  final List<MethodParameter> parameters;

  /// The list of dependencies required by the class constructor.
  ///
  /// These dependencies are typically used for generating mock
  /// objects in unit tests.
  final List<Dependency> dependencies;

  /// Creates a new [MethodInfo] describing a discovered method.
  ///
  /// All fields are required to ensure the test generator has
  /// complete metadata for generating test cases.
  MethodInfo(
      {required this.className,
      required this.methodName,
      required this.returnType,
      required this.isAsync,
      required this.isStatic,
      required this.parameters,
      required this.dependencies});

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
      'MethodInfo{className=$className, methodName=$methodName, returnType=$returnType, isAsync=$isAsync, isStatic=$isStatic, parameters=$parameters, isTopLevel=$isTopLevel, hasParameters=$hasParameters, isVoid=$isVoid}';
}
