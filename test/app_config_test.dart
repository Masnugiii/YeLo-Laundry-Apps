import 'package:flutter_test/flutter_test.dart';
import 'package:yelo_laundry_erp/core/config/app_config.dart';

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

    test('builds physical URL from API_HOST when API_BASE_URL is empty', () {
      expect(
        AppConfig.resolveApiBaseUrl(
          apiBaseUrlFromEnvironment: '',
          apiHost: '192.168.110.53',
          apiEnv: 'physical',
          isAndroid: true,
        ),
        'http://192.168.110.53:3000/api/v1',
      );
    });

    test('API_ENV=emulator forces emulator loopback', () {
      expect(
        AppConfig.resolveApiBaseUrl(
          apiBaseUrlFromEnvironment: '',
          apiEnv: 'emulator',
          isAndroid: false,
        ),
        AppConfig.defaultAndroidEmulatorApiBaseUrl,
      );
    });

    test('API_ENV=physical without host/url throws', () {
      expect(
        () => AppConfig.resolveApiBaseUrl(
          apiBaseUrlFromEnvironment: '',
          apiEnv: 'physical',
          isAndroid: true,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('API_ENV=production without URL throws', () {
      expect(
        () => AppConfig.resolveApiBaseUrl(
          apiBaseUrlFromEnvironment: '',
          apiEnv: 'production',
          isAndroid: true,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('API_ENV=production rejects localhost and 10.0.2.2', () {
      expect(
        () => AppConfig.resolveApiBaseUrl(
          apiBaseUrlFromEnvironment: 'http://10.0.2.2:3000/api/v1',
          apiEnv: 'production',
          isAndroid: true,
        ),
        throwsA(isA<StateError>()),
      );
      expect(
        () => AppConfig.resolveApiBaseUrl(
          apiBaseUrlFromEnvironment: 'http://localhost:3000/api/v1',
          apiEnv: 'production',
          isAndroid: false,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('API_ENV=production accepts HTTPS domain', () {
      expect(
        AppConfig.resolveApiBaseUrl(
          apiBaseUrlFromEnvironment: 'https://api.yelolaundry.example/api/v1',
          apiEnv: 'production',
          isAndroid: true,
        ),
        'https://api.yelolaundry.example/api/v1',
      );
    });

    test('defaults Android emulator to 10.0.2.2 when defines are empty', () {
      expect(
        AppConfig.resolveApiBaseUrl(
          apiBaseUrlFromEnvironment: '',
          isAndroid: true,
        ),
        AppConfig.defaultAndroidEmulatorApiBaseUrl,
      );
    });

    test('defaults non-Android platforms to localhost when defines are empty', () {
      expect(
        AppConfig.resolveApiBaseUrl(
          apiBaseUrlFromEnvironment: '',
          isAndroid: false,
        ),
        AppConfig.defaultLocalhostApiBaseUrl,
      );
    });
  });
}
