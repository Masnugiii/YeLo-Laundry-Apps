import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// Resolves API base URL for local development.
  ///
  /// Priority:
  /// 1. `--dart-define=API_BASE_URL=...`
  /// 2. Android emulator host loopback (`10.0.2.2`)
  /// 3. iOS simulator / desktop localhost
  static String get apiBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    }

    return 'http://localhost:3000/api/v1';
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const int defaultPageSize = 20;
}
