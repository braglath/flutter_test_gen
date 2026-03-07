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
- Automatically create the correct **`test/` folder structure**
- **Append missing tests** to existing test files
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
- CLI **help command**

## Installation

Add the package to your project:

```yaml
dev_dependencies:
  flutter_test_gen: ^0.0.1
```

Then run:

```bash
dart pub get
```

## Usage

Generate tests for a Dart file:

```bash
dart run flutter_test_gen generate user_service
```

You can also specify a full file path:

```bash
dart run flutter_test_gen generate lib/services/user_service.dart
```

For convenience, the command also works without `generate`:

```bash
dart run flutter_test_gen user_service
```

## CLI Commands

### Generate tests

```bash
dart run flutter_test_gen generate <FILE_NAME>
```

Default behavior is **append missing tests**.

### Append missing tests

```bash
dart run flutter_test_gen generate <FILE_NAME> --append
```

Adds only tests that do not already exist.

### Overwrite existing tests

```bash
dart run flutter_test_gen generate <FILE_NAME> --overwrite
```

Recreates the test file completely.

### Show help

```bash
dart run flutter_test_gen --help
```

## Example

### Source file

```dart
class UserService {
  int getAge() {
    return 30;
  }

  static int add(int a, int b) {
    return a + b;
  }
}
```

### Generated test

```dart
group('UserService | lib/user_service.dart', () {
  late UserService service;

  setUp(() {
    service = UserService();
  });

  test('getAge', () {
    // Arrange

    // Act
    final result = service.getAge();

    // Assert
    expect(result, isNotNull);
  });

  test('add', () {
    // Arrange

    // Act
    final result = UserService.add(1, 1);

    // Assert
    expect(result, isNotNull);
  });
});
```

## Behavior

The generator:

- Creates test files inside the **`test/` directory**
- Groups tests by **class name**
- Restores deleted tests if they are removed
- Restores deleted groups if they are removed
- Prevents duplicate test generation
- Does **not modify existing test structure**

## Requirements

- Dart SDK
- Flutter project (recommended)

## Quick Demo

_Generate tests for a service:_

dart run flutter_test_gen generate user_service

_Output:_

✓ Found Dart file  
✓ Parsed methods  
✓ Generated test templates  
✓ Appended missing tests

## Project Structure

```text
flutter_test_gen
 ├── bin/
 │   └── flutter_test_gen.dart
 ├── lib/
 │   ├── flutter_test_gen.dart
 │   └── src/
 │       ├── generator/
 │       ├── parser/
 │       ├── models/
 │       └── utils/
 ├── example/
 ├── test/
 ├── README.md
 ├── LICENSE
 └── pubspec.yaml
```

## Roadmap

Planned improvements:

- smarter test data generation
- automatic mock generation
- test coverage integration
- watch mode for automatic test generation

## Contributing

Contributions are welcome.

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Open a pull request

## License

MIT License

## Repository

<https://github.com/YOUR_USERNAME/flutter_test_gen>

## Author

Built by Flutter Zone to make **Flutter unit testing faster and easier**.

## Keywords

Flutter test generator  
Dart test generator  
Flutter unit test automation  
Flutter testing CLI tool
