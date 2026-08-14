import 'package:flutter/foundation.dart';

/// Development-only UI preview gate. Never active in release builds.
abstract final class DevPreviewGate {
  static bool _active = false;

  static bool get isAvailable => kDebugMode;

  static bool get isActive => kDebugMode && _active;

  /// Clears any dev-preview state when running a release/profile build.
  static void resetForProduction() {
    if (kReleaseMode) {
      _active = false;
    }
  }

  static void activate() {
    if (!kDebugMode) return;
    _active = true;
  }

  static void deactivate() {
    _active = false;
  }
}
