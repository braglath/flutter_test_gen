/// Represents information about a detected switch pattern case.
///
/// [SwitchCaseInfo] is produced by the analyzer when a method contains a
/// `switch` expression or statement that performs pattern matching.
///
/// It stores:
/// - the variable being evaluated in the switch
/// - the concrete types used in pattern cases
/// - the expected return values mapped to each type
///
/// Example source code:
/// ```dart
/// return switch (error) {
///   UserNotFound() => local.invalidUser,
///   UserBlocked() => "User blocked",
///   _ => "Unknown error",
/// };
/// ```
///
/// Parsed result:
/// ```dart
/// SwitchCaseInfo(
///   variable: 'error',
///   types: ['UserNotFound', 'UserBlocked'],
///   expectedValues: {
///     'UserNotFound': 'local.invalidUser',
///     'UserBlocked': '"User blocked"',
///   },
/// )
/// ```
///
/// This information allows the test generator to automatically produce
/// individual test cases for each detected switch branch.
class SwitchCaseInfo {
  /// The variable used in the `switch` expression.
  ///
  /// Example:
  /// ```dart
  /// switch (error) { ... }
  /// ```
  /// In this case the variable is `error`.
  final String variable;

  /// The list of concrete types matched in the switch cases.
  ///
  /// Example:
  /// ```dart
  /// UserNotFound()
  /// UserBlocked()
  /// ```
  /// These will be stored as:
  /// ```dart
  /// ['UserNotFound', 'UserBlocked']
  /// ```
  final List<String> types;

  /// A mapping of each type to its expected return value.
  ///
  /// The key represents the matched type and the value represents
  /// the corresponding expression returned in that case.
  ///
  /// Example:
  /// ```dart
  /// {
  ///   'UserNotFound': 'local.invalidUser',
  ///   'UserBlocked': '"User blocked"',
  /// }
  /// ```
  ///
  /// This is used to generate precise assertions for each test case.
  Map<String, String> expectedValues;

  /// Creates a new [SwitchCaseInfo] instance.
  ///
  /// Parameters:
  /// - [variable]: The variable being switched on.
  /// - [types]: The list of concrete pattern types detected.
  /// - [expectedValues]: Mapping of types to expected return values.
  SwitchCaseInfo({
    required this.variable,
    required this.types,
    required this.expectedValues,
  });
}
