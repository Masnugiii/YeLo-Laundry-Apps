bool isValidIndonesianPhone(String value) {
  final normalized = value.replaceAll(RegExp(r'[\s\-]'), '');
  final pattern = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,11}$');
  return pattern.hasMatch(normalized);
}

String normalizeIndonesianPhone(String value) {
  final normalized = value.replaceAll(RegExp(r'[\s\-]'), '');
  if (normalized.startsWith('+62')) {
    return normalized;
  }
  if (normalized.startsWith('62')) {
    return '+$normalized';
  }
  if (normalized.startsWith('0')) {
    return '+62${normalized.substring(1)}';
  }
  return normalized;
}
