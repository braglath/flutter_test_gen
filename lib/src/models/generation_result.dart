sealed class GenerationResult {}

class Generated extends GenerationResult {
  final String? path;
  final int? count;
  Generated({this.path, this.count});
}

class Overwritten extends GenerationResult {
  final String path;
  Overwritten(this.path);
}

class Appended extends GenerationResult {
  final String path;
  Appended(this.path);
}

class Skipped extends GenerationResult {
  final String path;
  Skipped(this.path);
}

class ErrorResult extends GenerationResult {
  final String path;
  final String message;
  ErrorResult(this.path, this.message);
}

class ShowError extends GenerationResult {
  final String error;
  ShowError(this.error);
}

class NoMethodsFound extends GenerationResult {
  NoMethodsFound();
}

class MocksGenerated extends GenerationResult {
  MocksGenerated();
}

class MultipleFilesFound extends GenerationResult {
  MultipleFilesFound();
}

class InvalidPath extends GenerationResult {
  final String path;
  InvalidPath(this.path);
}

class InvalidSelection extends GenerationResult {
  InvalidSelection();
}

class showFilePath extends GenerationResult {
  final String path;
  showFilePath(this.path);
}

class NoNewTest extends GenerationResult {
  NoNewTest();
}

class CurrentFile extends GenerationResult {
  final String file;
  CurrentFile(this.file);
}

class ProvideFileName extends GenerationResult {
  ProvideFileName();
}

class ShowFolderPath extends GenerationResult {
  final String path;
  ShowFolderPath(this.path);
}

class ShowRelativePath extends GenerationResult {
  final int index;
  final String path;
  ShowRelativePath(this.index, this.path);
}

class ShowHelp extends GenerationResult {
  ShowHelp();
}

class AddMockDependency extends GenerationResult{
  AddMockDependency();
}
