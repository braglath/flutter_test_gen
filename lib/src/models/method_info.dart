import 'method_parameter.dart';

class MethodInfo {
  final String className;
  final String methodName;
  final String returnType;
  final bool isAsync;
  final bool isStatic;
  final List<MethodParameter> parameters;

  MethodInfo(
      {required this.className,
      required this.methodName,
      required this.returnType,
      required this.isAsync,
      required this.isStatic,
      required this.parameters});

  bool get isTopLevel => className == '__top_level__';

  bool get hasParameters => parameters.isNotEmpty;

  bool get isVoid => returnType.contains('void') || returnType == 'dynamic';

  @override
  String toString() {
    return 'MethodInfo{className=$className, methodName=$methodName, returnType=$returnType, isAsync=$isAsync, isStatic=$isStatic, parameters=$parameters, isTopLevel=$isTopLevel, hasParameters=$hasParameters, isVoid=$isVoid}';
  }
}
