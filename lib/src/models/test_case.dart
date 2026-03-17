/// Represents a single generated test case.
///
/// [TestCase] contains the essential components required to render
/// a unit test:
/// - [description]: The human-readable test name
/// - [body]: The full test implementation (Arrange, Act, Assert, etc.)
///
/// This model is used by higher-level builders to compose
/// structured test groups and complete test files.
class TestCase {
  /// A descriptive name for the test case.
  ///
  /// This is used as the test title inside the `test()` function.
  final String description;

  /// The body of the test case.
  ///
  /// Typically includes:
  /// - Arrange (setup and mocks)
  /// - Act (method execution)
  /// - Assert (result validation)
  /// - Verify (interaction checks)
  final String body;

  /// Creates a new [TestCase] with the given [description] and [body].
  TestCase({
    required this.description,
    required this.body,
  });
}
