import 'package:flutter_test/flutter_test.dart';
import 'package:yelo_laundry_erp/core/utils/phone_util.dart';

void main() {
  group('PhoneUtil', () {
    test('normalizes Indonesian local numbers to 62 prefix', () {
      expect(PhoneUtil.normalizeWhatsAppNumber('081234567890'), '6281234567890');
    });

    test('keeps already normalized numbers', () {
      expect(PhoneUtil.normalizeWhatsAppNumber('6281234567890'), '6281234567890');
    });

    test('returns null for empty phone', () {
      expect(PhoneUtil.normalizeWhatsAppNumber(null), isNull);
      expect(PhoneUtil.normalizeWhatsAppNumber(''), isNull);
    });
  });
}
