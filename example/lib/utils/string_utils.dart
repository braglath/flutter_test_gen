String capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

bool isLong(String text) {
  return text.length > 10;
}
