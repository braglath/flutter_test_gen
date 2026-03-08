class MethodParameter {
  final String name;
  final String type;
  final bool isNamed;
  final bool isEnum;

  const MethodParameter({
    required this.name,
    required this.type,
    this.isNamed = false,
    this.isEnum = false,
  });

  MethodParameter copyWith({
    String? name,
    String? type,
    bool? isNamed,
    bool? isEnum,
  }) {
    return MethodParameter(
      name: name ?? this.name,
      type: type ?? this.type,
      isNamed: isNamed ?? this.isNamed,
      isEnum: isEnum ?? this.isEnum,
    );
  }

  @override
  String toString() {
    return 'MethodParameter(name: $name, type: $type, isNamed: $isNamed, isEnum: $isEnum)';
  }
}
