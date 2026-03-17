/// Represents parsed command-line options for the CLI.
///
/// [CliOptions] encapsulates user-provided arguments and flags,
/// making them easier to use throughout the application.
///
/// It supports:
/// - Input file path
/// - Append mode for existing test files
/// - Overwrite mode for replacing existing content
class CliOptions {
  /// The input file path provided via CLI.
  final String input;

  /// Whether to append generated tests to an existing file.
  final bool append;

  /// Whether to overwrite existing test files.
  final bool overwrite;

  /// Creates a [CliOptions] instance with the given values.
  ///
  /// - [input]: Path to the source file
  /// - [append]: Append mode flag
  /// - [overwrite]: Overwrite mode flag
  CliOptions({
    required this.input,
    required this.append,
    required this.overwrite,
  });

  /// Parses CLI arguments into a [CliOptions] instance.
  ///
  /// Expected arguments:
  /// - First argument: input file path
  /// - `--append`: append generated tests to existing content
  /// - `--overwrite`: overwrite existing test files
  ///
  /// Behavior:
  /// - If `--overwrite` is provided, append is disabled
  /// - If `--overwrite` is not provided, append defaults to `true`
  ///
  /// Returns:
  /// A configured [CliOptions] object.
  factory CliOptions.fromArgs(List<String> args) {
    final overwrite = args.contains('--overwrite');
    final append = args.contains('--append');

    return CliOptions(
      input: args.first,
      append: append || !overwrite,
      overwrite: overwrite,
    );
  }
}
