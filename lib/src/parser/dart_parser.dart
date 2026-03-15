import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_test_gen/src/di/dependency_filter.dart';
import 'package:flutter_test_gen/src/di/dependency_resolver.dart';
import 'package:flutter_test_gen/src/models/method_info.dart';
import 'package:flutter_test_gen/src/models/method_parameter.dart';
import 'package:flutter_test_gen/src/models/switch_case_info.dart';
import 'package:flutter_test_gen/src/resolver/property_access_resolver.dart';
import 'package:flutter_test_gen/src/resolver/sealed_class_resolver.dart';

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

    final sourceImports = unit.directives
        .whereType<ImportDirective>()
        .map((d) => d.uri.stringValue ?? '')
        .toList();

    final methods = <MethodInfo>[];

    for (final declaration in unit.declarations) {
      methods.addAll(_processDeclaration(declaration, unit, sourceImports));
    }

    return methods;
  }

  List<MethodInfo> _processDeclaration(
    CompilationUnitMember declaration,
    CompilationUnit unit,
    List<String> sourceImports,
  ) {
    if (declaration is ClassDeclaration) {
      final constructorDeps = DependencyResolver.resolve(declaration);

      return _extractMembers(
        containerName: declaration.name.lexeme,
        members: declaration.members,
        dependencies: constructorDeps,
        unit: unit,
        sourceImports: sourceImports,
      );
    }

    if (declaration is MixinDeclaration) {
      return _extractMembers(
        containerName: declaration.name.lexeme,
        members: declaration.members,
        dependencies: [],
        unit: unit,
        sourceImports: sourceImports,
      );
    }

    if (declaration is ExtensionDeclaration) {
      return _extractMembers(
        containerName: declaration.name?.lexeme ?? 'Extension',
        members: declaration.members,
        dependencies: [],
        unit: unit,
        sourceImports: sourceImports,
      );
    }

    if (declaration is FunctionDeclaration) {
      return [_parseTopLevelFunction(declaration, sourceImports)];
    }

    return [];
  }

  List<MethodInfo> _extractMembers({
    required String containerName,
    required List<ClassMember> members,
    required List<Dependency> dependencies,
    required CompilationUnit unit,
    required List<String> sourceImports,
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
            sourceImports,
          ),
        );
      }
    }

    return methods;
  }

  MethodInfo _parseTopLevelFunction(
    FunctionDeclaration declaration,
    List<String> sourceImports,
  ) {
    final method = MethodInfo(
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
        switchCases: [],
        sourceImports: sourceImports);

    _detectSwitchCases(declaration.functionExpression.body, method);

    return method;
  }

  MethodInfo _parseMethod(
    MethodDeclaration member,
    String className,
    List<Dependency> constructorDeps,
    CompilationUnit unit,
    List<String> sourceImports,
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

    /// NEW: detect sealed class switch patterns
    final methodInfo = MethodInfo(
        className: className,
        methodName: member.name.lexeme,
        returnType: member.returnType?.toSource() ?? 'dynamic',
        isAsync: member.body.isAsynchronous,
        isStatic: member.isStatic,
        parameters: _parseParameters(member.parameters),
        constructorDependencies: constructorFiltered,
        parameterDependencies: paramFiltered,
        propertyAccesses: propertyAccesses,
        switchCases: [],
        sourceImports: sourceImports);

    _detectSwitchCases(member.body, methodInfo);

    /// NEW: detect subclasses of sealed dependencies
    for (final dep in constructorFiltered) {
      final subclasses = SealedClassResolver.findSubclasses(
        dep.type,
        unit,
      );

      if (subclasses.isNotEmpty) {
        methodInfo.switchCases.add(
          SwitchCaseInfo(
            variable: dep.name,
            types: subclasses,
          ),
        );
      }
    }

    return methodInfo;
  }

  List<Dependency> _extractParameterDependencies(
      FormalParameterList? parameterList) {
    if (parameterList == null) return [];

    final deps = <Dependency>[];

    for (final p in parameterList.parameters) {
      final param = _unwrapParameter(p);

      final typeNode = param?.type;
      final type = typeNode?.toSource();
      final name = param?.name?.lexeme;

      if (type == null || name == null) continue;

      final element = typeNode?.type?.element;

      /// Skip enums completely
      if (element is EnumElement) {
        continue;
      }

      deps.add(Dependency(name, type));
    }

    return deps;
  }

  List<MethodParameter> _parseParameters(FormalParameterList? parameterList) {
    if (parameterList == null) return [];

    return parameterList.parameters.map((p) {
      final param = _unwrapParameter(p);

      final typeNode = param?.type;
      final type = typeNode?.toSource() ?? 'dynamic';

      bool isEnum = false;

      final element = typeNode?.type?.element;
      if (element is EnumElement) {
        isEnum = true;
      }

      return MethodParameter(
        name: param?.name?.lexeme ?? 'param',
        type: type,
        isNamed: p.isNamed,
        isEnum: isEnum,
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

  void _detectSwitchCases(
    AstNode node,
    MethodInfo method,
  ) {
    node.visitChildren(
      _SwitchVisitor(method),
    );
  }
}

class _SwitchVisitor extends RecursiveAstVisitor<void> {
  final MethodInfo method;

  _SwitchVisitor(this.method);

  @override
  void visitSwitchExpression(SwitchExpression node) {
    final variable = node.expression.toSource();
    final types = <String>[];

    for (final c in node.cases) {
      final guarded = c.guardedPattern;
      final pattern = guarded.pattern;

      if (pattern is ObjectPattern) {
        final type = pattern.type.toSource();
        types.add(type);
      }
    }

    if (types.isNotEmpty) {
      method.switchCases.add(
        SwitchCaseInfo(
          variable: variable,
          types: types,
        ),
      );
    }

    super.visitSwitchExpression(node);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    final variable = node.expression.toSource();
    final types = <String>[];

    for (final member in node.members) {
      if (member is SwitchPatternCase) {
        final pattern = member.guardedPattern.pattern;

        if (pattern is ObjectPattern) {
          final type = pattern.type.toSource();
          types.add(type);
        }
      }
    }

    if (types.isNotEmpty) {
      method.switchCases.add(
        SwitchCaseInfo(
          variable: variable,
          types: types,
        ),
      );
    }

    super.visitSwitchStatement(node);
  }
}
