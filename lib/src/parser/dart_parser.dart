import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import '../models/method_info.dart';
import '../models/method_parameter.dart';

class DartParser {
  DartParser._internal();

  static final DartParser _instance = DartParser._internal();

  factory DartParser() => _instance;

  List<MethodInfo> extractMethods(String filePath) {
    final result = parseFile(
      path: filePath,
      featureSet: FeatureSet.latestLanguageVersion(),
    );

    final unit = result.unit;

    final methods = <MethodInfo>[];

    for (final declaration in unit.declarations) {
      methods.addAll(_processDeclaration(declaration));
    }

    return methods;
  }

  List<MethodInfo> _processDeclaration(CompilationUnitMember declaration) {
    if (declaration is ClassDeclaration) {
      return _extractMembers(
        containerName: declaration.name.lexeme,
        members: declaration.members,
      );
    }

    if (declaration is MixinDeclaration) {
      return _extractMembers(
        containerName: declaration.name.lexeme,
        members: declaration.members,
      );
    }

    if (declaration is ExtensionDeclaration) {
      return _extractMembers(
        containerName: declaration.name?.lexeme ?? 'Extension',
        members: declaration.members,
      );
    }

    if (declaration is FunctionDeclaration) {
      return [_parseTopLevelFunction(declaration)];
    }

    return [];
  }

  List<MethodInfo> _extractMembers({
    required String containerName,
    required List<ClassMember> members,
  }) {
    final methods = <MethodInfo>[];

    for (final member in members) {
      if (member is MethodDeclaration) {
        if (member.isGetter || member.isSetter) continue;

        methods.add(_parseMethod(member, containerName));
      }
    }

    return methods;
  }

  MethodInfo _parseTopLevelFunction(FunctionDeclaration declaration) =>
      MethodInfo(
        className: '__top_level__',
        methodName: declaration.name.lexeme,
        returnType: declaration.returnType?.toSource() ?? 'dynamic',
        isAsync: declaration.functionExpression.body.isAsynchronous,
        isStatic: true,
        parameters: _parseParameters(declaration.functionExpression.parameters),
      );

  MethodInfo _parseMethod(MethodDeclaration member, String className) =>
      MethodInfo(
        className: className,
        methodName: member.name.lexeme,
        returnType: member.returnType?.toSource() ?? 'dynamic',
        isAsync: member.body.isAsynchronous,
        isStatic: member.isStatic,
        parameters: _parseParameters(member.parameters),
      );

  List<MethodParameter> _parseParameters(FormalParameterList? parameterList) {
    if (parameterList == null) return [];

    return parameterList.parameters.map((p) {
      final param = _unwrapParameter(p);

      return MethodParameter(
        name: param?.name?.lexeme ?? 'param',
        type: param?.type?.toSource() ?? 'dynamic',
        isNamed: p.isNamed,
      );
    }).toList();
  }

  SimpleFormalParameter? _unwrapParameter(FormalParameter p) {
    if (p is DefaultFormalParameter) {
      final inner = p.parameter;

      if (inner is SimpleFormalParameter) {
        return inner;
      }
    }

    if (p is SimpleFormalParameter) {
      return p;
    }

    return null;
  }
}
