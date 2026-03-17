class TypeValueGenerator {
  static String generate(String type, {bool isEnum = false}) {
    final clean = type.replaceAll('?', '');

    if (isEnum) {
      return '$clean.values.first';
    }

    switch (clean) {
      case 'int':
        return '1';
      case 'String':
        return "'test'";
      case 'bool':
        return 'true';
      case 'double':
        return '1.0';
      case 'DateTime':
        return 'DateTime.now()';
      default:
        return '$clean()';
      // return '$clean.values.first'; // safe fallback
    }
  }
}
