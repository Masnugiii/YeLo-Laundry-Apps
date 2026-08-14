import 'package:flutter_test/flutter_test.dart';
import 'package:yelo_laundry_erp/features/customer/data/customer_mapper.dart';

void main() {
  group('mapCustomerFromJson', () {
    test('maps defaultAddress object to address string', () {
      final customer = mapCustomerFromJson({
        'id': 'customer-1',
        'fullName': 'Budi',
        'phone': '081234567890',
        'defaultAddress': {
          'id': 'address-1',
          'addressDetail': 'Jl. Melati No. 10',
        },
        'walletBalance': 125000,
        'loyaltyPoints': 40,
        'memberStatus': 'MEMBER',
      });

      expect(customer.address, 'Jl. Melati No. 10');
      expect(customer.walletBalance, 125000);
      expect(customer.isMember, isTrue);
    });

    test('returns null address when defaultAddress is null', () {
      final customer = mapCustomerFromJson({
        'id': 'customer-2',
        'fullName': 'Ani',
        'phone': '081234567891',
        'defaultAddress': null,
      });

      expect(customer.address, isNull);
    });

    test('falls back to top-level addressDetail when defaultAddress missing', () {
      final customer = mapCustomerFromJson({
        'id': 'customer-3',
        'fullName': 'Citra',
        'phone': '081234567892',
        'addressDetail': 'Jl. Mawar 5',
      });

      expect(customer.address, 'Jl. Mawar 5');
    });

    test('supports legacy string defaultAddress', () {
      final customer = mapCustomerFromJson({
        'id': 'customer-4',
        'fullName': 'Dewi',
        'phone': '081234567893',
        'defaultAddress': 'Jl. Anggrek 2',
      });

      expect(customer.address, 'Jl. Anggrek 2');
    });
  });
}
