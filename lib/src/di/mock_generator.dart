import 'package:flutter_test_gen/src/di/dependency_resolver.dart';

class MockGenerator {
  static String generateMockClasses(List<Dependency> deps) {
    final buffer = StringBuffer();

    for (var dep in deps) {
      buffer.writeln(
          'class Mock${dep.type} extends Mock implements ${dep.type} {}');
    }

    return buffer.toString();
  }

  static String generateMockVariables(List<Dependency> deps) {
    final buffer = StringBuffer();

    for (var dep in deps) {
      buffer.writeln('late Mock${dep.type} mock${dep.type};');
    }

    return buffer.toString();
  }

  static String generateMockInit(List<Dependency> deps) {
    final buffer = StringBuffer();

    for (var dep in deps) {
      buffer.writeln('mock${dep.type} = Mock${dep.type}();');
    }

    return buffer.toString();
  }
}
