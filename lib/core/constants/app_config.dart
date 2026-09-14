import 'package:flutter/foundation.dart';

/// Single source of environment flags.
///
/// Valid combinations:
/// | kFirebaseEnabled | kUseFirebaseData | Mode     |
/// |------------------|------------------|----------|
/// | false            | false            | DEMO     |
/// | true             | false            | Auth-only|
/// | true             | true             | FIREBASE |
/// | false            | true             | INVALID → DEMO |
class AppConfig {
  /// Initialize Firebase SDK.
  static const bool kFirebaseEnabled = false;

  /// Use Firebase repositories instead of DummyData.
  /// Requires [kFirebaseEnabled] == true for meaningful effect.
  static const bool kUseFirebaseData = false;

  /// Firebase Emulator Suite (dev only — never enable in production builds).
  static const bool kUseEmulators = false;
  static const String emulatorHost = 'localhost';
  static const int authEmulatorPort = 9099;
  static const int firestoreEmulatorPort = 8080;
  static const int storageEmulatorPort = 9199;

  /// Demo-only credentials (not production secrets).
  static const String demoAdminEmail = 'admin@grandluxe.com';
  static const String demoGuestEmail = 'guest@example.com';
  static const String demoPassword = 'password123';

  /// Effective data backend after resolving invalid flag combinations.
  static bool get useFirebaseDataEffective {
    if (kUseFirebaseData && !kFirebaseEnabled) {
      if (kDebugMode) {
        debugPrint(
          '[AppConfig] INVALID: kUseFirebaseData=true but kFirebaseEnabled=false. '
          'Forcing DEMO repositories.',
        );
      }
      return false;
    }
    return kUseFirebaseData && kFirebaseEnabled;
  }

  static bool get isDemoMode => !useFirebaseDataEffective;

  static void logMode() {
    if (!kDebugMode) return;
    if (isDemoMode) {
      debugPrint('[AppConfig] Mode: DEMO (DummyData)');
    } else {
      debugPrint(
        '[AppConfig] Mode: FIREBASE (emulators=${kUseEmulators ? "on" : "off"})',
      );
    }
  }
}
