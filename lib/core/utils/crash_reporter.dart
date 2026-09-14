import 'package:flutter/foundation.dart';
import 'app_logger.dart';

/// Abstraction for crash / error reporting (Sentry, Crashlytics, etc.).
/// Default implementation only logs in debug — no third-party dependency required.
abstract class CrashReporter {
  void recordError(Object error, StackTrace? stack, {String? reason});
  void setUserId(String? userId);
  void log(String message);
}

class NoOpCrashReporter implements CrashReporter {
  @override
  void recordError(Object error, StackTrace? stack, {String? reason}) {
    AppLogger.e(reason ?? 'Unhandled error', error: error, stack: stack);
  }

  @override
  void setUserId(String? userId) {
    // Intentionally no-op — avoid storing PII without a real provider
  }

  @override
  void log(String message) {
    AppLogger.d(message, tag: 'CrashReporter');
  }
}

/// Global accessor — swap implementation at startup when integrating Crashlytics.
CrashReporter crashReporter = NoOpCrashReporter();

void installFlutterErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    crashReporter.recordError(
      details.exception,
      details.stack,
      reason: details.context?.toString(),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    crashReporter.recordError(error, stack, reason: 'platform');
    return true;
  };
}
