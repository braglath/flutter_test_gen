import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/utils/naming_utils.dart';

class VerifyBuilder {
  String build(MethodInfo method) {
    final buffer = StringBuffer();

    for (final access in method.propertyAccesses) {
      for (final dep in method.constructorDependencies) {
        if (access.target == dep.name) {
          final mockVar = NamingUtils.mockVar(dep.name);
          final args = access.args.isEmpty ? '' : '(${access.args.join(', ')})';

          buffer.writeln(
            '    verify(() => $mockVar.${access.property}$args).called(1);',
          );
        }
      }
    }

    return buffer.toString().trim();
  }
}
