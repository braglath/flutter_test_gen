/// Represents the result of a test generation operation.
///
/// [GenerationResult] is a sealed base class used to model all possible
/// outcomes of the CLI execution. Each subclass represents a specific
/// state or result, enabling structured handling of success, failure,
/// and informational scenarios.
sealed class GenerationResult {}

/// Indicates that test generation was successful.
///
/// Parameters:
/// - [path]: The path of the generated file (if applicable)
/// - [count]: Number of processed files or generated test cases
class Generated extends GenerationResult {
  /// The path of the generated file.
  final String? path;

  /// Number of processed files or generated items.
  final int? count;

  /// Creates a [Generated] result.
  Generated({this.path, this.count});
}

/// Indicates that an existing file was overwritten.
///
/// Parameters:
/// - [path]: The file path that was overwritten
class Overwritten extends GenerationResult {
  /// The file path that was overwritten.
  final String path;

  /// Creates an [Overwritten] result.
  Overwritten(this.path);
}

/// Indicates that content was appended or updated in an existing file.
///
/// Parameters:
/// - [path]: The file path that was updated
class Appended extends GenerationResult {
  /// The file path that was updated.
  final String path;

  /// Creates an [Appended] result.
  Appended(this.path);
}

/// Indicates that generation was skipped for a file.
///
/// Parameters:
/// - [path]: The file path that was skipped
class Skipped extends GenerationResult {
  /// The file path that was skipped.
  final String path;

  /// Creates a [Skipped] result.
  Skipped(this.path);
}

/// Represents an error during generation.
///
/// Parameters:
/// - [path]: File path where the error occurred
/// - [message]: Description of the error
class ErrorResult extends GenerationResult {
  /// File path where the error occurred.
  final String path;

  /// Description of the error.
  final String message;

  /// Creates an [ErrorResult].
  ErrorResult(this.path, this.message);
}

/// Represents a general error message to be displayed.
///
/// Parameters:
/// - [error]: The error message
class ShowError extends GenerationResult {
  /// The error message to display.
  final String error;

  /// Creates a [ShowError] result.
  ShowError(this.error);
}

/// Indicates that no methods were found for test generation.
class NoMethodsFound extends GenerationResult {
  /// Creates a [NoMethodsFound] result.
  NoMethodsFound();
}

/// Indicates that mock classes were generated.
class MocksGenerated extends GenerationResult {
  /// Creates a [MocksGenerated] result.
  MocksGenerated();
}

/// Indicates that multiple matching files were found.
class MultipleFilesFound extends GenerationResult {
  /// Creates a [MultipleFilesFound] result.
  MultipleFilesFound();
}

/// Indicates that the provided path is invalid.
///
/// Parameters:
/// - [path]: The invalid path provided by the user
class InvalidPath extends GenerationResult {
  /// The invalid path.
  final String path;

  /// Creates an [InvalidPath] result.
  InvalidPath(this.path);
}

/// Indicates that the user made an invalid selection.
class InvalidSelection extends GenerationResult {
  /// Creates an [InvalidSelection] result.
  InvalidSelection();
}

/// Represents a file path to be displayed to the user.
/// Parameters:
/// - [path]: The file path to display
class ShowFilePath extends GenerationResult {
  /// The file path to display.
  final String path;

  /// Creates a [ShowFilePath] result.
  ShowFilePath(this.path);
}

/// Indicates that no new tests were generated.
class NoNewTest extends GenerationResult {
  /// Creates a [NoNewTest] result.
  NoNewTest();
}

/// Represents the current file being processed.
///
/// Parameters:
/// - [file]: The file currently being processed
class CurrentFile extends GenerationResult {
  /// The file currently being processed.
  final String file;

  /// Creates a [CurrentFile] result.
  CurrentFile(this.file);
}

/// Indicates that the user must provide a file name.
class ProvideFileName extends GenerationResult {
  /// Creates a [ProvideFileName] result.
  ProvideFileName();
}

/// Represents a folder path to be displayed.
///
/// Parameters:
/// - [path]: The folder path
class ShowFolderPath extends GenerationResult {
  /// The folder path.
  final String path;

  /// Creates a [ShowFolderPath] result.
  ShowFolderPath(this.path);
}

/// Represents a relative file path with an index (used in selections).
///
/// Parameters:
/// - [index]: The position in the list
/// - [path]: The relative file path
class ShowRelativePath extends GenerationResult {
  /// The index of the item.
  final int index;

  /// The relative file path.
  final String path;

  /// Creates a [ShowRelativePath] result.
  ShowRelativePath(this.index, this.path);
}

/// Indicates that help information should be displayed.
class ShowHelp extends GenerationResult {
  /// Creates a [ShowHelp] result.
  ShowHelp();
}

/// Indicates that a mock dependency needs to be added/generated.
class AddMockDependency extends GenerationResult {
  /// Creates an [AddMockDependency] result.
  AddMockDependency();
}
