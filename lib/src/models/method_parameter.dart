class MethodParameter {
  final String name;
  final String type;
  final bool isNamed;

  MethodParameter({
    required this.name,
    required this.type,
    this.isNamed = false,
  });
}
