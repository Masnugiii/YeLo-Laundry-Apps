/// Stable member card serial sourced from profile/API.
abstract final class MemberSerialNumber {
  static String? parseFromJson(Map<String, dynamic> json) {
    final direct = json['memberSerialNumber'];
    if (direct is String && direct.trim().isNotEmpty) {
      return direct.trim();
    }

    final customerCode = json['customerCode'];
    if (customerCode is String && customerCode.trim().isNotEmpty) {
      return customerCode.trim();
    }

    return null;
  }

  static String formatForCard(String memberSerialNumber) {
    final normalized = memberSerialNumber.trim();
    final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return 'YELO • ${normalized.toUpperCase()}';
    }

    final displayDigits =
        digits.length > 10 ? digits.substring(digits.length - 10) : digits.padLeft(10, '0');

    return 'YELO • $displayDigits';
  }

  static String qrPayload(String memberSerialNumber) {
    return memberSerialNumber.trim();
  }
}
