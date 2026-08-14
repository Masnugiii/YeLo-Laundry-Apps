import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_customer/core/membership/member_serial_number.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';

void main() {
  group('MemberSerialNumber', () {
    test('parseFromJson prefers memberSerialNumber', () {
      expect(
        MemberSerialNumber.parseFromJson({
          'memberSerialNumber': 'CUS-0001234',
          'customerCode': 'CUS-9999999',
        }),
        'CUS-0001234',
      );
    });

    test('parseFromJson falls back to customerCode', () {
      expect(
        MemberSerialNumber.parseFromJson({
          'customerCode': 'CUS-0004827',
        }),
        'CUS-0004827',
      );
    });

    test('parseFromJson returns null when both fields missing', () {
      expect(MemberSerialNumber.parseFromJson({}), isNull);
    });

    test('qrPayload uses trimmed serial', () {
      expect(
        MemberSerialNumber.qrPayload('  CUS-0004827  '),
        'CUS-0004827',
      );
    });
  });

  group('CustomerSession member serial', () {
    test('fromJson maps customerCode to memberSerialNumber', () {
      final session = CustomerSession.fromJson({
        'id': 'cust-1',
        'fullName': 'Test',
        'phone': '081234567890',
        'customerCode': 'CUS-0004827',
      });

      expect(session.memberSerialNumber, 'CUS-0004827');
    });
  });
}
