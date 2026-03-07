class MethodParameter {
  final String name;
  final String type;
  final bool isNamed;

  const MethodParameter({
    required this.name,
    required this.type,
    this.isNamed = false,
  });

  MethodParameter copyWith({
    String? name,
    String? type,
    bool? isNamed,
  }) {
    return MethodParameter(
      name: name ?? this.name,
      type: type ?? this.type,
      isNamed: isNamed ?? this.isNamed,
    );
  }

  @override
  String toString() {
    return 'MethodParameter(name: $name, type: $type, isNamed: $isNamed)';
  }
}
