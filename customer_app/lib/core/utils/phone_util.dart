/// WhatsApp / Indonesian mobile phone helpers.
abstract final class PhoneUtil {
  static final RegExp _indonesianMobileRegex = RegExp(
    r'^(\+62|62|0)8[1-9][0-9]{6,11}$',
  );

  /// Normalizes input to E.164 Indonesia format, e.g. `+6281234567890`.
  static String normalizeToE164(String phone) {
    var normalized = phone.replaceAll(RegExp(r'[\s-]'), '');

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

  /// Phone string sent to API (E.164, accepted by backend DTO validation).
  static String normalizeForApi(String phone) => normalizeToE164(phone);

  static bool isValidWhatsAppNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');
    if (_indonesianMobileRegex.hasMatch(cleaned)) return true;
    return _indonesianMobileRegex.hasMatch(normalizeToE164(phone));
  }

  /// Returns a user-friendly validation message, or `null` when valid.
  static String? validate(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) {
      return 'Nomor WhatsApp wajib diisi';
    }
    if (!isValidWhatsAppNumber(trimmed)) {
      return 'Nomor WhatsApp tidak valid. Contoh: 081234567890';
    }
    return null;
  }
}
