class TypeUtils {
  static String unwrap(String type) {
    var clean = type.replaceAll('?', '');

    if (clean.startsWith('Future<')) {
      clean = clean.replaceFirst('Future<', '').replaceFirst('>', '');
    }

    return clean;
  }

  static bool isFuture(String type) => type.startsWith('Future<');
}
