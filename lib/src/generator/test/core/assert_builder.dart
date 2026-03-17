import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/utils/project_utils.dart';

class AssertBuilder {
  final ProjectUtil project;

  AssertBuilder(this.project);

  String build({
    required MethodInfo method,
    required String returnType,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('    // Assert');

    if (method.isVoid) {
      buffer.writeln('    // verify side effects');
      return buffer.toString();
    }

    final expectedValue = _expectedValue(returnType);

    buffer.writeln('    expect(result, $expectedValue);');

    return buffer.toString();
  }

  String _expectedValue(String returnType) {
    if (project.isPrimitive(returnType)) {
      /// Example:
      /// int → 1
      /// bool → true
      /// String → 'test'
      return project.primitiveValueForAssert(returnType);
    }

    /// Non-primitive → type matcher
    return 'isA<$returnType>()';
  }
}
