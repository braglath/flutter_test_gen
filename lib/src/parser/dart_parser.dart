import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import '../di/dependency_resolver.dart';
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
      final dependencies = DependencyResolver.resolve(declaration);

      return _extractMembers(
        containerName: declaration.name.lexeme,
        members: declaration.members,
        dependencies: dependencies,
      );
    }

    if (declaration is MixinDeclaration) {
      return _extractMembers(
        containerName: declaration.name.lexeme,
        members: declaration.members,
        dependencies: [],
      );
    }

    if (declaration is ExtensionDeclaration) {
      return _extractMembers(
        containerName: declaration.name?.lexeme ?? 'Extension',
        members: declaration.members,
        dependencies: [],
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
    required List<Dependency> dependencies,
  }) {
    final methods = <MethodInfo>[];

    for (final member in members) {
      if (member is MethodDeclaration) {
        if (member.isGetter || member.isSetter) continue;

        methods.add(
          _parseMethod(
            member,
            containerName,
            dependencies,
          ),
        );
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
        parameters: _parseParameters(
          declaration.functionExpression.parameters,
        ),
        dependencies: [],
      );

  MethodInfo _parseMethod(
    MethodDeclaration member,
    String className,
    List<Dependency> dependencies,
  ) =>
      MethodInfo(
        className: className,
        methodName: member.name.lexeme,
        returnType: member.returnType?.toSource() ?? 'dynamic',
        isAsync: member.body.isAsynchronous,
        isStatic: member.isStatic,
        parameters: _parseParameters(member.parameters),
        dependencies: dependencies,
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
