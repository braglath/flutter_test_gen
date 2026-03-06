# Flutter Test Gen

[![pub package](https://img.shields.io/pub/v/flutter_test_gen.svg)](https://pub.dev/packages/flutter_test_gen)
[![likes](https://img.shields.io/pub/likes/flutter_test_gen)](https://pub.dev/packages/flutter_test_gen/score)
[![popularity](https://img.shields.io/pub/popularity/flutter_test_gen)](https://pub.dev/packages/flutter_test_gen/score)

A CLI tool to **automatically generate unit tests for Flutter/Dart methods**.

It analyzes Dart files and creates test files with structured templates, allowing developers to quickly start writing tests without manually creating boilerplate code.

---

## Features

• Generate unit tests for **classes and top-level functions**
• Automatically create the correct `test/` folder structure
• **Append missing tests** to existing test files
• **Restore deleted tests** inside groups
• **Restore deleted groups**
• Skip:

- private methods
- mixins
- extensions

• Supports **async methods**
• Supports **static methods**
• CLI help command for easy usage

---

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

---

## Usage

Generate tests for a Dart file:

```bash
dart run flutter_test_gen user_service
```

You can also specify a full path:

```bash
dart run flutter_test_gen lib/services/user_service.dart
```

---

## CLI Commands

### Generate tests

```bash
dart run flutter_test_gen user_service
```

Default behavior is **append missing tests**.

---

### Append missing tests

```bash
dart run flutter_test_gen user_service --append
```

Adds only tests that do not already exist.

---

### Overwrite existing tests

```bash
dart run flutter_test_gen user_service --overwrite
```

Recreates the test file completely.

---

### Generate tests for all files

```bash
dart run flutter_test_gen --all
```

Scans the `lib/` directory and generates tests for all Dart files.

---

### Show help

```bash
dart run flutter_test_gen --help
```

---

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

---

## Behaviour

The generator:

• Creates test files inside the `test/` directory
• Groups tests by class name
• Restores deleted tests if they are removed
• Restores deleted groups if they are removed
• Prevents duplicate test generation
• Does **not modify existing test structure**

---

## Requirements

• Dart SDK
• Flutter project (recommended)

---

## Project Structure

```
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

---

## Roadmap

Possible future improvements:

• Edge-case test generation
• Mock generation
• Coverage integration
• Watch mode for automatic test generation

---

## Contributing

Contributions are welcome.

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Open a pull request

---

## License

MIT License

---

## Repository

<https://github.com/YOUR_USERNAME/flutter_test_gen>

---

## Author

Built to make writing Flutter unit tests faster and easier.
