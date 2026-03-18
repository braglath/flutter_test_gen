/// Provides ANSI escape codes for styling CLI output.
///
/// [Ansi] contains constants for applying colors and formatting
/// to terminal text. These can be used to enhance readability
/// and improve user experience in CLI applications.
///
/// Example:
/// ```dart
/// print('${Ansi.greenC}Success!${Ansi.reset}');
/// print('${Ansi.redC}Error occurred${Ansi.reset}');
/// ```
class Ansi {
  /// Resets all styles and returns text to default formatting.
  static const reset = '\x1B[0m';

  /// Red color (commonly used for errors).
  static const redC = '\x1B[31m';

  /// Green color (commonly used for success messages).
  static const greenC = '\x1B[32m';

  /// Yellow color (commonly used for warnings).
  static const yellowC = '\x1B[33m';

  /// Blue color (commonly used for informational messages).
  static const blueC = '\x1B[34m';

  /// Cyan color (used for highlights or secondary information).
  static const cyanC = '\x1B[36m';

  /// Bright cyan color (used for stronger emphasis).
  static const brightCyanC = '\x1B[96m';

  /// Magenta color (used for emphasis or special output).
  static const magentaC = '\x1B[35m';

  static String _wrap(String code, String text) => '$code$text$reset';

  /// Wraps the given [text] with green color formatting.
  ///
  /// Commonly used for success messages.
  static String green(String text) => _wrap(greenC, text);

  /// Wraps the given [text] with red color formatting.
  ///
  /// Commonly used for error messages.
  static String red(String text) => _wrap(redC, text);

  /// Wraps the given [text] with yellow color formatting.
  ///
  /// Commonly used for warnings or highlights.
  static String yellow(String text) => _wrap(yellowC, text);

  /// Wraps the given [text] with blue color formatting.
  ///
  /// Commonly used for informational messages.
  static String blue(String text) => _wrap(blueC, text);

  /// Wraps the given [text] with cyan color formatting.
  ///
  /// Useful for secondary information or emphasis.
  static String cyan(String text) => _wrap(cyanC, text);

  /// Wraps the given [text] with bright cyan color formatting.
  ///
  /// Used for stronger emphasis compared to standard cyan.
  static String brightCyan(String text) => _wrap(brightCyanC, text);

  /// Wraps the given [text] with magenta color formatting.
  ///
  /// Used for special highlights or distinct output.
  static String magenta(String text) => _wrap(magentaC, text);
}
