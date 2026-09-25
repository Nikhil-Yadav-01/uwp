import 'package:flutter/foundation.dart';

/// Clean debug logging utility
class AppLogger {
  AppLogger._();

  static void debug(String message, {String tag = 'DEBUG'}) {
    if (kDebugMode) {
      debugPrint('🔵 [$tag] $message');
    }
  }

  static void info(String message, {String tag = 'INFO'}) {
    if (kDebugMode) {
      debugPrint('ℹ️ [$tag] $message');
    }
  }

  static void warning(String message, {String tag = 'WARN'}) {
    if (kDebugMode) {
      debugPrint('⚠️ [$tag] $message');
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String tag = 'ERROR'}) {
    if (kDebugMode) {
      debugPrint('❌ [$tag] $message');
      if (error != null) debugPrint('   Error: $error');
      if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
    }
  }
}
