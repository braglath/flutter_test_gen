import 'method_parameter.dart';

class MethodInfo {
  final String className;
  final String methodName;
  final String returnType;
  final bool isAsync;
  final bool isStatic;
  final List<MethodParameter> parameters;

  MethodInfo({
    required this.className,
    required this.methodName,
    required this.returnType,
    required this.isAsync,
    required this.isStatic,
    List<MethodParameter> parameters = const [],
  }) : parameters = List.unmodifiable(parameters);

  bool get isTopLevel => className == '__top_level__';

  bool get hasParameters => parameters.isNotEmpty;
}
