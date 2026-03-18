# Flutter test generator (Flutter Test Gen)

[![pub
package](https://img.shields.io/pub/v/flutter_test_gen.svg)](https://pub.dev/packages/flutter_test_gen) [![likes](https://img.shields.io/pub/likes/flutter_test_gen)](https://pub.dev/packages/flutter_test_gen/score)

A CLI tool to **automatically generate unit tests for Flutter and Dart
projects**.

`flutter_test_gen` analyzes Dart files and generates structured test
templates, helping developers quickly start writing tests without
manually creating boilerplate code.

## Features

- Generate tests for **classes and top-level functions**
- Generate tests for **all Dart files inside a directory (recursive)**
- Automatically create the correct **`test/` folder structure**
- **Append missing tests** to existing test files (default)
- **Overwrite existing tests** when needed
- **Restore deleted tests** inside groups
- **Restore deleted groups**
- Prevent **duplicate test generation**
- Supports:
  - async methods
  - static methods
- Adds **tags** to each test
- Skips:
  - private methods
  - mixins
  - extensions
- Clean and structured **CLI output**
- CLI **help and debug support**

## Installation

Add the package using:

```bash
flutter pub add flutter_test_gen --dev
```

This will install the latest version from pub.dev automatically.

If your code uses dependencies, you may also need:

```bash
flutter pub add mocktail --dev
```

## Usage

### Generate for a single file

```bash
dart run flutter_test_gen user_service
```

### Generate using full path

```bash
dart run flutter_test_gen lib/services/user_service.dart
```

### Generate for all files in a folder

```bash
dart run flutter_test_gen lib/utils
```

### Append missing tests

```bash
dart run flutter_test_gen <FILE_NAME> --append
```

Adds only tests that do not already exist.

### Overwrite existing tests

```bash
dart run flutter_test_gen <FILE_NAME> --overwrite
```

Recreates the test file completely.

### Show help

```bash
dart run flutter_test_gen --help
```

## Example

### Input

```dart
class UserService { int getAge() => 30; }
```

### Generated test

```dart
group('UserService', () {
  late UserService service;

  setUp(() {
    service = UserService();
  });

  test('getAge', () {
    final result = service.getAge();
    expect(result, isNotNull);
  });
});
```

## Behavior

The generator:

- Supports both **files and directories**
- Recursively scans folders for Dart files
- Creates test files inside the **`test/` directory**
- Groups tests by **class name**
- Restores deleted tests and groups
- Prevents duplicate test generation
- Does **not modify existing test structure unnecessarily**

## Requirements

- Dart SDK
- Flutter project (recommended)

## Quick Demo

_Generate tests for a folder:_

dart run flutter_test_gen lob/utils

_Output:_

📂 lib/utils

→ string_utils.dart

✓ test/utils/string_utils_test.dart

→ math_utils.dart

⚙ mocks

✓ test/utils/math_utils_test.dart

✓ 2 files processed

## Contributing

Contributions are welcome.

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Open a pull request

## License

MIT License

## Repository

<https://github.com/braglath/flutter_test_gen>

## Author

Built by Flutter Zone to make **Flutter unit testing faster and easier**.

## Keywords

Flutter test generator  
Dart test generator  
Flutter unit test automation  
Flutter testing CLI tool
