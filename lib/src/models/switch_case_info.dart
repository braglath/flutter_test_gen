/// Represents information about a detected switch pattern case.
///
/// [SwitchCaseInfo] is produced by the parser when a method contains a
/// `switch` expression or `switch` statement that performs pattern matching
/// on a variable.
///
/// It stores:
/// - the variable being evaluated in the switch
/// - the concrete types used in the pattern cases
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
/// )
/// ```
///
/// This information allows the test generator to automatically produce
/// individual tests for each detected switch case type.
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

  /// Creates a new [SwitchCaseInfo] instance.
  ///
  /// Parameters:
  /// - [variable]: The variable being switched on.
  /// - [types]: The list of concrete pattern types detected in the switch.
  SwitchCaseInfo({
    required this.variable,
    required this.types,
  });
}
