import 'package:yelo_laundry_customer/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig.resolveApiBaseUrl', () {
    test('uses explicit API_BASE_URL when provided', () {
      expect(
        AppConfig.resolveApiBaseUrl(
          apiBaseUrlFromEnvironment: 'http://192.168.110.53:3000/api/v1',
          isAndroid: true,
        ),
        'http://192.168.110.53:3000/api/v1',
      );
    });

    test('defaults Android emulator to 10.0.2.2 when API_BASE_URL is empty', () {
      expect(
        AppConfig.resolveApiBaseUrl(
          apiBaseUrlFromEnvironment: '',
          isAndroid: true,
        ),
        AppConfig.defaultAndroidEmulatorApiBaseUrl,
      );
    });

    test('defaults non-Android platforms to localhost when API_BASE_URL is empty', () {
      expect(
        AppConfig.resolveApiBaseUrl(
          apiBaseUrlFromEnvironment: '',
          isAndroid: false,
        ),
        AppConfig.defaultLocalhostApiBaseUrl,
      );
    });

    test('documents internal Wi-Fi target for dart-define profiles', () {
      expect(
        AppConfig.internalWifiApiBaseUrl,
        'http://192.168.110.53:3000/api/v1',
      );
    });
  });
}
