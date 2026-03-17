/// Enables verbose debugging logs for the generator.
///
/// This flag is typically enabled via the CLI using:
/// `flutter_test_gen --debug`.
///
/// When `true`, additional internal information such as parsed
/// method metadata and generated verification calls will be printed.
bool debugMode = false;

/// Prints debug messages when [debugMode] is enabled.
///
/// This helper centralizes conditional logging so that generator
/// components can safely output diagnostic information without
/// cluttering the console during normal execution.
///
/// Example:
/// ```dart
/// debugLog('methodInfo: $method');
/// ```
void debugLog(Object message) {
  if (debugMode) print(message);
}
