import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Represents a property or method access detected during AST analysis.
///
/// [PropertyAccessInfo] captures interactions with dependencies inside
/// a method body. This includes:
/// - Field access (`repository.user`)
/// - Getter access (`service.token`)
/// - Method invocation (`repository.fetchUser(id)`)
///
/// The test generator uses this metadata to understand how dependencies
/// are used and to generate better unit tests (for example `verify()`
/// calls or stubbing return values).
class PropertyAccessInfo {
  /// The object or dependency on which the property or method is accessed.
  ///
  /// Example:
  /// ```dart
  /// repository.fetchUser()
  /// ```
  /// Here, `repository` is the target.
  final String target;

  /// The name of the property, getter, or method being accessed.
  ///
  /// Examples:
  /// - `fetchUser`
  /// - `save`
  /// - `token`
  final String property;

  /// The list of arguments passed when the access represents
  /// a method invocation.
  ///
  /// Example:
  /// ```dart
  /// repository.fetchUser(userId)
  /// ```
  /// Here, `args` would contain `["userId"]`.
  ///
  /// For property or getter access, this list will be empty.
  final List<String> args;

  /// The resolved return type of the accessed method or property.
  ///
  /// This value is extracted from the analyzer's element model
  /// when available.
  ///
  /// Examples:
  /// - `Future<User>`
  /// - `String`
  /// - `void`
  ///
  /// This can be `null` if the analyzer cannot determine the type.
  final String? returnType;

  /// Creates a new [PropertyAccessInfo].
  ///
  /// Parameters:
  /// - [target]: The dependency or object being accessed.
  /// - [property]: The property, getter, or method name.
  /// - [args]: Optional list of arguments used in a method call.
  /// - [returnType]: Optional resolved return type of the access.
  ///
  /// Example:
  /// ```dart
  /// PropertyAccessInfo('repository', 'fetchUser', ['userId'], 'Future<User>')
  /// ```
  PropertyAccessInfo(
    this.target,
    this.property, [
    this.args = const [],
    this.returnType,
  ]);

  @override
  String toString() => '$target.$property';
}

/// AST visitor that discovers interactions with dependencies inside a method.
///
/// [PropertyAccessResolver] walks through a method's AST and collects
/// property accesses and method invocations performed on known dependencies.
/// These interactions are stored as [PropertyAccessInfo] objects.
///
/// This resolver is primarily used by the test generator to detect how
/// dependencies are used inside a method so it can generate appropriate
/// stubs and verification statements.
///
/// For example, given:
/// ```dart
/// userRepository.fetchUser(id);
/// cache.save(user);
/// ```
///
/// The resolver will record:
/// - `userRepository.fetchUser`
/// - `cache.save`
class PropertyAccessResolver extends RecursiveAstVisitor<void> {
  /// List of all detected dependency property accesses.
  ///
  /// Each entry represents a property read or method call performed
  /// on a dependency during method execution.
  ///
  /// Example collected entries:
  /// - `repository.fetchUser`
  /// - `cache.save`
  /// - `service.token`
  final List<PropertyAccessInfo> accesses = [];

  /// Names of dependencies that should be tracked.
  ///
  /// Only property accesses performed on these objects will be recorded.
  ///
  /// Example:
  /// ```dart
  /// {'repository', 'cache', 'authService'}
  /// ```
  ///
  /// Any AST access like `repository.fetchUser()` will be captured,
  /// while unrelated accesses will be ignored.
  final Set<String> dependencyNames;

  /// Creates a [PropertyAccessResolver].
  ///
  /// The [dependencyNames] parameter defines which identifiers represent
  /// dependencies whose property accesses should be captured.
  ///
  /// This allows the resolver to ignore internal variables and focus only
  /// on external collaborators that may need to be mocked in tests.
  ///
  /// Example:
  /// ```dart
  /// final resolver = PropertyAccessResolver({'repository', 'cache'});
  /// ```
  PropertyAccessResolver(this.dependencyNames);

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final target = node.target?.toSource();
    final property = node.propertyName.name;

    if (target != null && dependencyNames.contains(target)) {
      accesses.add(PropertyAccessInfo(target, property));
    }

    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    final target = node.prefix.name;
    final property = node.identifier.name;

    if (dependencyNames.contains(target)) {
      accesses.add(PropertyAccessInfo(target, property));
    }

    super.visitPrefixedIdentifier(node);
  }

  /// Detect method calls like repository.fetchUser()
  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target?.toSource();
    final methodName = node.methodName.name;

    if (target != null && dependencyNames.contains(target)) {
      final args =
          node.argumentList.arguments.map((a) => a.toSource()).toList();

      accesses.add(
        PropertyAccessInfo(
          target,
          methodName,
          args,
        ),
      );
    }

    super.visitMethodInvocation(node);
  }
}
