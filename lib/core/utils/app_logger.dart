import 'package:flutter/foundation.dart';

/// Production-safe logging. Never logs secrets or PII in release.
class AppLogger {
  AppLogger._();

  static void d(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint(_format('D', tag, message));
    }
  }

  static void i(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint(_format('I', tag, message));
    }
  }

  static void w(String message, {String? tag, Object? error}) {
    if (kDebugMode) {
      debugPrint(_format('W', tag, message));
      if (error != null) debugPrint('  cause: $error');
    }
  }

  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stack,
  }) {
    // Errors may be forwarded to CrashReporter in release
    if (kDebugMode) {
      debugPrint(_format('E', tag, message));
      if (error != null) debugPrint('  error: $error');
      if (stack != null) debugPrint('$stack');
    }
  }

  static String _format(String level, String? tag, String message) {
    final t = tag != null ? '[$tag] ' : '';
    return '[$level] $t$message';
  }
}
