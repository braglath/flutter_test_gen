<!-- markdownlint-disable MD024 -->

# Changelog

All notable changes to this project will be documented in this file.

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
