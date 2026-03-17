/// Represents a parameter of a method discovered during source analysis.
///
/// [ParameterInfo] stores metadata about a method argument such as
/// its name, type, and whether it is a named parameter or an enum.
/// This information is used by the test generator to create appropriate
/// input values when generating unit tests.
class ParameterInfo {
  /// The name of the method parameter.
  final String name;

  /// The Dart type of the parameter.
  ///
  /// Examples:
  /// - `String`
  /// - `int`
  /// - `UserModel`
  final String type;

  /// Indicates whether the parameter is a named parameter.
  ///
  /// Example:
  /// ```dart
  /// void example({required String name})
  /// ```
  /// In this case, `name` would have `isNamed = true`.
  final bool isNamed;

  /// Indicates whether the parameter type is an enum.
  ///
  /// This helps the test generator choose valid enum values
  /// when creating test input data.
  final bool isEnum;

  /// Creates a new [ParameterInfo] describing a method argument.
  ///
  /// The [name] and [type] are required. Optional flags indicate whether
  /// the parameter is named or represents an enum type.
  const ParameterInfo({
    required this.name,
    required this.type,
    this.isNamed = false,
    this.isEnum = false,
  });

  /// Creates a copy of this [ParameterInfo] with updated values.
  ///
  /// Any provided parameter will replace the corresponding value,
  /// while omitted parameters will keep the current value.
  ///
  /// Example:
  /// ```dart
  /// final updated = param.copyWith(isNamed: true);
  /// ```
  ParameterInfo copyWith({
    String? name,
    String? type,
    bool? isNamed,
    bool? isEnum,
  }) =>
      ParameterInfo(
        name: name ?? this.name,
        type: type ?? this.type,
        isNamed: isNamed ?? this.isNamed,
        isEnum: isEnum ?? this.isEnum,
      );

  @override
  String toString() =>
      'MethodParameter(name: $name, type: $type, isNamed: $isNamed, isEnum: $isEnum)';
}
