import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_erp/core/utils/greeting_helper.dart';

void main() {
  group('GreetingHelper', () {
    test('returns Selamat Pagi between 05:00 and 10:59', () {
      expect(GreetingHelper.greetingFor(DateTime(2026, 8, 7, 5)), 'Selamat Pagi');
      expect(GreetingHelper.greetingFor(DateTime(2026, 8, 7, 10, 59)), 'Selamat Pagi');
    });

    test('returns Selamat Siang between 11:00 and 14:59', () {
      expect(GreetingHelper.greetingFor(DateTime(2026, 8, 7, 11)), 'Selamat Siang');
      expect(GreetingHelper.greetingFor(DateTime(2026, 8, 7, 14, 59)), 'Selamat Siang');
    });

    test('returns Selamat Sore between 15:00 and 17:59', () {
      expect(GreetingHelper.greetingFor(DateTime(2026, 8, 7, 15)), 'Selamat Sore');
      expect(GreetingHelper.greetingFor(DateTime(2026, 8, 7, 17, 59)), 'Selamat Sore');
    });

    test('returns Selamat Malam between 18:00 and 04:59', () {
      expect(GreetingHelper.greetingFor(DateTime(2026, 8, 7, 18)), 'Selamat Malam');
      expect(GreetingHelper.greetingFor(DateTime(2026, 8, 7, 23)), 'Selamat Malam');
      expect(GreetingHelper.greetingFor(DateTime(2026, 8, 7, 4, 59)), 'Selamat Malam');
    });
  });
}
