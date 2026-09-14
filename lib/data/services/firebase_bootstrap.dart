import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../firebase_options.dart';
import '../../core/constants/app_config.dart';

/// Initializes Firebase when enabled. Never crashes Demo mode.
class FirebaseBootstrap {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<bool> init() async {
    if (!AppConfig.kFirebaseEnabled) {
      if (kDebugMode) {
        debugPrint('[FirebaseBootstrap] Disabled – Demo mode');
      }
      return false;
    }

    if (_initialized) return true;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (AppConfig.kUseEmulators) {
        await _connectEmulators();
      }

      _initialized = true;
      if (kDebugMode) {
        debugPrint('[FirebaseBootstrap] Initialized successfully');
      }
      return true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[FirebaseBootstrap] Init failed – staying in Demo mode: $e');
        debugPrint('$st');
      }
      _initialized = false;
      return false;
    }
  }

  static Future<void> _connectEmulators() async {
    final host = AppConfig.emulatorHost;
    try {
      await FirebaseAuth.instance.useAuthEmulator(host, AppConfig.authEmulatorPort);
      FirebaseFirestore.instance.useFirestoreEmulator(
        host,
        AppConfig.firestoreEmulatorPort,
      );
      await FirebaseStorage.instance.useStorageEmulator(
        host,
        AppConfig.storageEmulatorPort,
      );
      if (kDebugMode) {
        debugPrint('[FirebaseBootstrap] Connected to emulators at $host');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseBootstrap] Emulator connect failed: $e');
      }
    }
  }
}
