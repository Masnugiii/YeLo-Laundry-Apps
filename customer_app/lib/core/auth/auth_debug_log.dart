import 'package:flutter/foundation.dart';

void authDebugLog(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('[AUTH] $message');
  }
}
