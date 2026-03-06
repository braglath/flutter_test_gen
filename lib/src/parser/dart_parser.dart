import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import '../models/method_info.dart';
import '../models/method_parameter.dart';

class DartParser {
  List<MethodInfo> extractMethods(String filePath) {
    final result = parseFile(
      path: filePath,
      featureSet: FeatureSet.latestLanguageVersion(),
    );

    final unit = result.unit;

    List<MethodInfo> methods = [];

    for (var declaration in unit.declarations) {
      // ==========================
      // CLASS METHODS
      // ==========================
      if (declaration is ClassDeclaration) {
        final className = declaration.name.lexeme;

        for (var member in declaration.members) {
          if (member is MethodDeclaration) {
            // ignore constructors, getters, setters
            if (member.isGetter || member.isSetter) {
              continue;
            }

            methods.add(_parseMethod(member, className));
          }
        }
      }

      // ==========================
      // MIXIN METHODS
      // ==========================
      if (declaration is MixinDeclaration) {
        final mixinName = declaration.name.lexeme;

        for (var member in declaration.members) {
          if (member is MethodDeclaration) {
            if (member.isGetter || member.isSetter) {
              continue;
            }

            methods.add(_parseMethod(member, mixinName));
          }
        }
      }

      // ==========================
      // EXTENSION METHODS
      // ==========================
      if (declaration is ExtensionDeclaration) {
        final extensionName = declaration.name?.lexeme ?? "Extension";

        for (var member in declaration.members) {
          if (member is MethodDeclaration) {
            if (member.isGetter || member.isSetter) {
              continue;
            }

            methods.add(_parseMethod(member, extensionName));
          }
        }
      }

      // ==========================
      // TOP LEVEL FUNCTIONS
      // ==========================
      if (declaration is FunctionDeclaration) {
        final function = declaration.functionExpression;

        final methodName = declaration.name.lexeme;

        final returnType = declaration.returnType?.toSource() ?? "dynamic";

        final isAsync = function.body.isAsynchronous;

        final parameters =
            function.parameters?.parameters.map((p) {
              final type = p is SimpleFormalParameter
                  ? p.type?.toSource() ?? "dynamic"
                  : "dynamic";

              final name = p.name.toString();

              return MethodParameter(name: name, type: type);
            }).toList() ??
            [];

        methods.add(
          MethodInfo(
            className: "__top_level__",
            methodName: methodName,
            returnType: returnType,
            isAsync: isAsync,
            isStatic: true,
            parameters: parameters,
          ),
        );
      }
    }

    return methods;
  }

  MethodInfo _parseMethod(MethodDeclaration member, String className) {
    final methodName = member.name.lexeme;

    final returnType = member.returnType?.toSource() ?? "dynamic";

    final isAsync = member.body.isAsynchronous;

    final isStatic = member.isStatic;

    final parameters =
        member.parameters?.parameters.map((p) {
          final type = p is SimpleFormalParameter
              ? p.type?.toSource() ?? "dynamic"
              : "dynamic";

          final name = p.name.toString();

          return MethodParameter(name: name, type: type);
        }).toList() ??
        [];

    return MethodInfo(
      className: className,
      methodName: methodName,
      returnType: returnType,
      isAsync: isAsync,
      isStatic: isStatic,
      parameters: parameters,
    );
  }
}
