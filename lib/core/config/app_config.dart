import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// API base URL resolution for Staff Internal App.
///
/// Prefer compile-time defines — do not bake LAN IPs into Dart source:
///
/// ```bash
/// # Android emulator
/// flutter run --dart-define-from-file=config/api/emulator.json
///
/// # Physical Android (same Wi-Fi as NestJS host)
/// ./scripts/flutter-run-mobile.sh physical staff
///
/// # Production (HTTPS only)
/// flutter build apk --release --dart-define-from-file=config/api/production.json
/// ```
class AppConfig {
  AppConfig._();

  static const String defaultAndroidEmulatorApiBaseUrl =
      'http://10.0.2.2:3000/api/v1';

  static const String defaultLocalhostApiBaseUrl =
      'http://localhost:3000/api/v1';

  /// Resolves API base URL from compile-time defines and platform defaults.
  ///
  /// Priority:
  /// 1. `--dart-define=API_BASE_URL=...`
  /// 2. `--dart-define=API_HOST=192.168.x.x` → `http://$API_HOST:3000/api/v1`
  /// 3. `--dart-define=API_ENV=emulator|physical|production|local`
  /// 4. Android → emulator loopback (`10.0.2.2`)
  /// 5. Desktop / iOS simulator → localhost
  static String get apiBaseUrl => resolveApiBaseUrl(
        apiBaseUrlFromEnvironment: const String.fromEnvironment('API_BASE_URL'),
        apiHost: const String.fromEnvironment('API_HOST'),
        apiEnv: const String.fromEnvironment('API_ENV'),
        isAndroid: !kIsWeb && Platform.isAndroid,
      );

  @visibleForTesting
  static String resolveApiBaseUrl({
    required String apiBaseUrlFromEnvironment,
    String apiHost = '',
    String apiEnv = '',
    required bool isAndroid,
    String androidEmulatorUrl = defaultAndroidEmulatorApiBaseUrl,
    String localhostUrl = defaultLocalhostApiBaseUrl,
  }) {
    final env = apiEnv.trim().toLowerCase();
    final explicit = apiBaseUrlFromEnvironment.trim();
    if (explicit.isNotEmpty) {
      if (env == 'production') {
        assertProductionApiBaseUrl(explicit);
      }
      return explicit;
    }

    final host = apiHost.trim();
    if (host.isNotEmpty) {
      final fromHost = 'http://$host:3000/api/v1';
      if (env == 'production') {
        assertProductionApiBaseUrl(fromHost);
      }
      return fromHost;
    }

    switch (env) {
      case 'production':
        throw StateError(
          'API_BASE_URL is required for API_ENV=production. '
          'Copy config/api/production.json.example → production.json '
          'and build with --dart-define-from-file=config/api/production.json',
        );
      case 'physical':
      case 'internal':
      case 'internal-wifi':
        throw StateError(
          'API_BASE_URL or API_HOST is required for physical Android. '
          'Use: ./scripts/flutter-run-mobile.sh physical staff',
        );
      case 'emulator':
        return androidEmulatorUrl;
      case 'local':
      case 'macos':
      case 'desktop':
        return localhostUrl;
      default:
        if (isAndroid) {
          return androidEmulatorUrl;
        }
        return localhostUrl;
    }
  }

  /// Production must be HTTPS and must not point at emulator/localhost.
  @visibleForTesting
  static void assertProductionApiBaseUrl(String url) {
    final normalized = url.trim().toLowerCase();
    final isHttps = normalized.startsWith('https://');
    final isLoopback = normalized.contains('://localhost') ||
        normalized.contains('://127.0.0.1') ||
        normalized.contains('://10.0.2.2');
    if (!isHttps || isLoopback) {
      throw StateError(
        'Production API_BASE_URL must be https://<API_DOMAIN>/api/v1 '
        '(got: $url)',
      );
    }
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const int defaultPageSize = 20;
}
