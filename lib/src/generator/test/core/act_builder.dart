import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/utils/test_utils.dart';

class ActBuilder {
  String build({
    required MethodInfo method,
    required String call,
  }) {
    final buffer = StringBuffer();

    final isAsync = TestUtils.needsAsync(method);
    final isVoid = method.isVoid;

    if (isAsync) {
      buffer.writeln('    final result = await $call;');
    } else if (!isVoid) {
      buffer.writeln('    final result = $call;');
    } else {
      buffer.writeln('    $call;');
    }

    return buffer.toString();
  }
}
