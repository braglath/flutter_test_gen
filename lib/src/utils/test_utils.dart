import 'package:flutter_test_gen/flutter_test_gen.dart';

class TestUtils {
  static bool needsAsync(MethodInfo method) => method.isAsync;
}
