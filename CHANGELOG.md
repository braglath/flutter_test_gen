<!-- markdownlint-disable MD024 -->

# Changelog

All notable changes to this project will be documented in this file.

## 1.1.0

### Features

- Generate tests for all Dart files inside a directory (recursive)

### Improvements

- Cleaner CLI output and logging
- Improved path resolution

### Fixes

- Fixed directory detection issues
- Fixed duplicate test file naming
- Fixed conflicting CLI flags

## 1.0.0

🎉 Initial stable release

### ✨ Features

- Generate unit tests for Dart & Flutter code
- Supports classes, top-level functions, static & instance methods
- Automatically detects constructor dependencies and generates mocks
- Handles async methods and verification with mocktail
- Generates Arrange / Act / Assert structured tests
- Supports switch / sealed class test generation

### 🧪 Test Generation

- Groups tests by class and file
- Avoids duplicate test generation
- Supports:
  - Append mode (default)
  - Overwrite mode

## 0.1.3

- Fixed incorrect mock return generation in append mode (User() → User(name: 'test', age: 1))
- Fixed missing arguments in verify calls
- Fixed inconsistency between initial generation and append mode
- Reused TestBuilder for append (single source of truth)
- Improved model resolution using original sourceImports

## 0.1.2

- Corrected mock generation when regenerating tests in append mode.
- Fixed missing arguments in generated `when()` and `verify()` calls.
- Improved duplicate test detection to prevent duplicate tests/groups.
- Minor internal improvements and documentation updates.

## 0.1.1

### Added

- Detection of sealed class pattern matching in `switch` expressions and statements
- Automatic generation of test cases for each detected switch pattern type
- `SealedClassResolver` to detect subclasses of sealed/base classes
- `SwitchCaseInfo` model to represent parsed switch pattern information
- Support for generating tests for sealed class error/state mappings
- Propagation of source file imports into generated test files

### Improved

- Import resolution now prefers imports from the original source file
- Reduced incorrect or guessed imports when generating tests
- Improved handling of simple object parameters during test generation
- Cleaner test generation when switch-based logic is detected
- Improved generator stability when parsing complex method bodies

### Fixed

- Incorrect import generation for classes referenced inside switch patterns
- Duplicate or conflicting imports when resolving types
- Missing imports for subclasses used in generated switch tests

### Documentation

- Added documentation for:
  - `SwitchCaseInfo`
  - `SealedClassResolver`
  - `collectImportsForType`
  - additional model fields used by the generator

## 0.1.0

### Added

- Constructor dependency detection and automatic mock generation
- Parameter dependency detection
- Automatic mock stubbing for dependency method calls
- Detection of property accesses and method invocations inside methods
- Support for async dependency stubs using `thenAnswer`
- Automatic generation of `verify()` calls for mocked dependencies
- Improved argument-aware mock generation

### Improved

- Better test template generation
- Improved return type handling for generated mocks
- Automatic formatting of generated test files using `dart_style`
- Smarter detection of instance vs static methods
- Improved import resolution for generated tests

### Fixed

- Duplicate mock stubbing for repeated property access
- Incorrect mock verification generation
- Invalid stub generation for dependency methods

## 0.0.5

- API documentation
- Updated Dependencies

## 0.0.4

- Mock Dependencies
- Added Lint rules
- Added test
- CI workflow

## 0.0.3

- updated dependencies

## 0.0.2

- Improved README documentation
- Updated package metadata in `pubspec.yaml`
- Added repository and homepage links
- Improved package discoverability on pub.dev

## 0.0.1

- Initial release
- CLI tool to generate unit tests for Flutter/Dart methods
- Supports classes and top-level functions
- Generates structured test templates
- Appends missing tests to existing test files
