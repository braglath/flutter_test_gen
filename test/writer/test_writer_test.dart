import 'dart:io';

import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/models/method_parameter.dart';
import 'package:flutter_test_gen/src/writer/test_writer.dart';
import 'package:test/test.dart';

void main() {
  late TestWriter writer;
  late File tempFile;

  setUp(() async {
    writer = TestWriter();

    final dir = await Directory.systemTemp.createTemp();
    tempFile = File('${dir.path}/test_file.dart');
    tempFile.createSync();
  });

  group('TestWriter', () {
    test('returns content when file does not exist', () {
      final file = File('non_existing.dart');

      final result = writer.process(
        file: file,
        existing: "",
        content: "new content",
        methods: [],
        relativePath: "lib/service.dart",
        append: true,
        overwrite: false,
        imports: [],
      );

      expect(result, "new content");
    });

    test('returns content when existing content is empty', () {
      final result = writer.process(
        file: tempFile,
        existing: "",
        content: "new test file",
        methods: [],
        relativePath: "lib/service.dart",
        append: true,
        overwrite: false,
        imports: [],
      );

      expect(result, "new test file");
    });

    test('overwrite mode replaces existing file', () {
      final result = writer.process(
        file: tempFile,
        existing: "old content",
        content: "new content",
        methods: [],
        relativePath: "lib/service.dart",
        append: true,
        overwrite: true,
        imports: [],
      );

      expect(result, "new content");
    });

    test('returns null when append disabled', () {
      final result = writer.process(
        file: tempFile,
        existing: "existing",
        content: "new",
        methods: [],
        relativePath: "lib/service.dart",
        append: false,
        overwrite: false,
        imports: [],
      );

      expect(result, null);
    });

    test('skips private methods', () {
      final methods = [
        MethodInfo(
          methodName: "_privateMethod",
          className: "UserService",
          parameters: [],
          returnType: "int",
          isAsync: false,
          isStatic: false,
          dependencies: [],
        ),
      ];

      final result = writer.process(
        file: tempFile,
        existing: """
void main() {
}
""",
        content: "generated",
        methods: methods,
        relativePath: "lib/user_service.dart",
        append: true,
        overwrite: false,
        imports: [],
      );

      expect(result, contains("void main()"));
    });

    test('creates new group when group does not exist', () {
      final methods = [
        MethodInfo(
          methodName: "getUser",
          className: "UserService",
          parameters: [],
          returnType: "int",
          isAsync: false,
          isStatic: false,
          dependencies: [],
        ),
      ];

      final existing = """
void main() {
}
""";

      final result = writer.process(
        file: tempFile,
        existing: existing,
        content: "generated",
        methods: methods,
        relativePath: "lib/user_service.dart",
        append: true,
        overwrite: false,
        imports: [],
      );

      expect(result, contains("group('UserService | lib/user_service.dart'"));
      expect(result, contains("test('getUser'"));
    });

    test('skips test if it already exists', () {
      final methods = [
        MethodInfo(
          methodName: "getUser",
          className: "UserService",
          parameters: [],
          returnType: "int",
          isAsync: false,
          isStatic: false,
          dependencies: [],
        ),
      ];

      final existing = """
void main() {
  test('getUser', () {});
}
""";

      final result = writer.process(
        file: tempFile,
        existing: existing,
        content: "generated",
        methods: methods,
        relativePath: "lib/user_service.dart",
        append: true,
        overwrite: false,
        imports: [],
      );

      expect(result, existing);
    });

    test('restores missing imports', () {
      final methods = [
        MethodInfo(
          methodName: "getUser",
          className: "UserService",
          parameters: [],
          returnType: "int",
          isAsync: false,
          isStatic: false,
          dependencies: [],
        ),
      ];

      final existing = """
void main() {
}
""";

      final imports = ["import 'package:flutter_test/flutter_test.dart';"];

      final result = writer.process(
        file: tempFile,
        existing: existing,
        content: "generated",
        methods: methods,
        relativePath: "lib/user_service.dart",
        append: true,
        overwrite: false,
        imports: imports,
      );

      expect(result, contains(imports.first));
    });

    test('generates arrange variables for parameters', () {
      final methods = [
        MethodInfo(
          methodName: "createUser",
          className: "UserService",
          parameters: [
            MethodParameter(
              name: "age",
              type: "int",
              isNamed: false,
            )
          ],
          returnType: "int",
          isAsync: false,
          isStatic: false,
          dependencies: [],
        ),
      ];

      final existing = """
void main() {
}
""";

      final result = writer.process(
        file: tempFile,
        existing: existing,
        content: "generated",
        methods: methods,
        relativePath: "lib/user_service.dart",
        append: true,
        overwrite: false,
        imports: [],
      );

      expect(result, contains("final age = 1"));
    });
  });
}
