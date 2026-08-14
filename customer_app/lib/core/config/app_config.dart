import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Known API targets for local/internal release builds.
///
/// Use `--dart-define-from-file=config/api/<profile>.json` or pass
/// `--dart-define=API_BASE_URL=...` explicitly at build/run time.
class AppConfig {
  AppConfig._();

  static const String defaultAndroidEmulatorApiBaseUrl =
      'http://10.0.2.2:3000/api/v1';

  static const String defaultLocalhostApiBaseUrl =
      'http://localhost:3000/api/v1';

  static const String internalWifiApiBaseUrl =
      'http://192.168.110.53:3000/api/v1';

  /// Resolves API base URL from compile-time defines and platform defaults.
  ///
  /// Priority:
  /// 1. `--dart-define=API_BASE_URL=...`
  /// 2. Android emulator host loopback (`10.0.2.2`)
  /// 3. iOS simulator / desktop localhost
  static String get apiBaseUrl => resolveApiBaseUrl(
        apiBaseUrlFromEnvironment: const String.fromEnvironment('API_BASE_URL'),
        isAndroid: !kIsWeb && Platform.isAndroid,
      );

  @visibleForTesting
  static String resolveApiBaseUrl({
    required String apiBaseUrlFromEnvironment,
    required bool isAndroid,
    String androidEmulatorUrl = defaultAndroidEmulatorApiBaseUrl,
    String localhostUrl = defaultLocalhostApiBaseUrl,
  }) {
    if (apiBaseUrlFromEnvironment.isNotEmpty) {
      return apiBaseUrlFromEnvironment;
    }

    if (isAndroid) {
      return androidEmulatorUrl;
    }

    return localhostUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const int defaultPageSize = 20;
}
