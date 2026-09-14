import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_config.dart';

/// FCM token registration & handling.
/// Demo mode / missing config: no-ops so the app still builds and runs.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  bool _initialized = false;
  String? _token;

  String? get token => _token;

  Future<void> initialize({String? userId}) async {
    if (!AppConfig.kFirebaseEnabled || _initialized) return;

    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (kDebugMode) {
        debugPrint('[FCM] permission: ${settings.authorizationStatus}');
      }

      _token = await messaging.getToken();
      if (userId != null && _token != null) {
        await _saveToken(userId, _token!);
      }

      messaging.onTokenRefresh.listen((t) async {
        _token = t;
        if (userId != null) await _saveToken(userId, t);
      });

      FirebaseMessaging.onMessage.listen((message) {
        if (kDebugMode) {
          debugPrint('[FCM] foreground: ${message.notification?.title}');
        }
      });

      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] init skipped: $e');
      }
    }
  }

  Future<void> _saveToken(String userId, String token) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] token save failed: $e');
    }
  }

  Future<void> clearToken(String userId) async {
    if (_token == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmTokens': FieldValue.arrayRemove([_token]),
      }, SetOptions(merge: true));
    } catch (_) {}
    _token = null;
  }
}
