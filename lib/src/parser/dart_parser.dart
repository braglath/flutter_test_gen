import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test_gen/src/di/dependency_filter..dart';
import 'package:flutter_test_gen/src/di/dependency_resolver.dart';
import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/models/method_parameter.dart';
import 'package:flutter_test_gen/src/resolver/property_access_resolver.dart';

/// Parses Dart source files and extracts method metadata.
///
/// [DartParser] analyzes Dart files using the `analyzer` package and
/// collects information about methods, functions, and their metadata.
/// The extracted information is converted into [MethodInfo] objects,
/// which are later used by the test generator to create unit tests.
///
/// This class is implemented as a **singleton** to avoid repeatedly
/// creating parser instances during test generation.
class DartParser {
  DartParser._internal();

  static final DartParser _instance = DartParser._internal();

  /// Returns the shared singleton instance of [DartParser].
  ///
  /// This factory constructor ensures that only one parser instance
  /// exists throughout the test generation process.
  factory DartParser() => _instance;

  /// Extracts method information from the Dart file located at [filePath].
  ///
  /// The parser analyzes the file using the Dart analyzer and collects
  /// methods from the following declarations:
  /// - Classes
  /// - Mixins
  /// - Extensions
  /// - Top-level functions
  ///
  /// Each discovered method is converted into a [MethodInfo] object
  /// containing metadata such as:
  /// - method name
  /// - return type
  /// - parameters
  /// - dependencies
  /// - async/static flags
  ///
  /// Returns a list of extracted [MethodInfo] objects.
  List<MethodInfo> extractMethods(String filePath) {
    final result = parseFile(
        path: filePath,
        featureSet: FeatureSet.latestLanguageVersion(),
        throwIfDiagnostics: false);

    final unit = result.unit;

    final methods = <MethodInfo>[];

    for (final declaration in unit.declarations) {
      methods.addAll(_processDeclaration(declaration, unit));
    }

    return methods;
  }

  List<MethodInfo> _processDeclaration(
    CompilationUnitMember declaration,
    CompilationUnit unit,
  ) {
    if (declaration is ClassDeclaration) {
      final constructorDeps = DependencyResolver.resolve(declaration);

      return _extractMembers(
        containerName: declaration.name.lexeme,
        members: declaration.members,
        dependencies: constructorDeps,
        unit: unit,
      );
    }

    if (declaration is MixinDeclaration) {
      return _extractMembers(
        containerName: declaration.name.lexeme,
        members: declaration.members,
        dependencies: [],
        unit: unit,
      );
    }

    if (declaration is ExtensionDeclaration) {
      return _extractMembers(
        containerName: declaration.name?.lexeme ?? 'Extension',
        members: declaration.members,
        dependencies: [],
        unit: unit,
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
    required CompilationUnit unit,
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
            unit,
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
        constructorDependencies: [],
        parameterDependencies: [],
        propertyAccesses: [],
      );

  MethodInfo _parseMethod(
    MethodDeclaration member,
    String className,
    List<Dependency> constructorDeps,
    CompilationUnit unit,
  ) {
    final paramDeps = _extractParameterDependencies(member.parameters);

    final constructorFiltered = DependencyFilter.filter(constructorDeps, unit);

    final paramFiltered = DependencyFilter.filter(paramDeps, unit);

    final dependencyNames = {
      ...constructorDeps.map((d) => d.name),
      ...paramDeps.map((d) => d.name),
    };

    final resolver = PropertyAccessResolver(dependencyNames);

    final body = member.body;

    if (body is BlockFunctionBody) {
      body.block.visitChildren(resolver);
    } else if (body is ExpressionFunctionBody) {
      body.expression.visitChildren(resolver);
    }

    final propertyAccesses = resolver.accesses;

    return MethodInfo(
      className: className,
      methodName: member.name.lexeme,
      returnType: member.returnType?.toSource() ?? 'dynamic',
      isAsync: member.body.isAsynchronous,
      isStatic: member.isStatic,
      parameters: _parseParameters(member.parameters),
      constructorDependencies: constructorFiltered,
      parameterDependencies: paramFiltered,
      propertyAccesses: propertyAccesses,
    );
  }

  List<Dependency> _extractParameterDependencies(
      FormalParameterList? parameterList) {
    if (parameterList == null) return [];

    final deps = <Dependency>[];

    for (final p in parameterList.parameters) {
      final param = _unwrapParameter(p);

      final type = param?.type?.toSource();
      final name = param?.name?.lexeme;

      if (type == null || name == null) continue;

      deps.add(Dependency(name, type));
    }

    return deps;
  }

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
