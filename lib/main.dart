import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/app/app.dart';
import 'package:yelo_laundry_erp/core/config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    debugPrint('[API] Base URL: ${AppConfig.apiBaseUrl}');
  }

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
