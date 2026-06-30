String newId(String prefix) {
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}
