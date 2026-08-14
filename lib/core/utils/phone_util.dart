class PhoneUtil {
  static String? normalizeWhatsAppNumber(String? phone) {
    final trimmed = phone?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    var digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = '62${digits.substring(1)}';
    } else if (digits.startsWith('62')) {
      // already normalized
    } else if (digits.startsWith('8')) {
      digits = '62$digits';
    }

    return digits.length >= 10 ? digits : null;
  }

  static bool hasWhatsAppNumber(String? phone) =>
      normalizeWhatsAppNumber(phone) != null;
}
