import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_config.dart';
import '../../core/errors/app_exception.dart';

/// Secure Firebase Storage paths and upload helpers.
/// Paths:
///   users/{uid}/avatar.jpg
///   rooms/{roomId}/{filename}
///   menu/{itemId}/{filename}
///   services/{serviceId}/{filename}
///   hotel/gallery/{filename}
abstract class StorageService {
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    required String contentType,
  });
  Future<void> delete(String path);
  Future<String> getDownloadUrl(String path);
}

class DemoStorageService implements StorageService {
  @override
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Return a stable placeholder URL for Demo
    return 'https://picsum.photos/seed/${path.hashCode.abs()}/800/600';
  }

  @override
  Future<void> delete(String path) async {}

  @override
  Future<String> getDownloadUrl(String path) async =>
      'https://picsum.photos/seed/${path.hashCode.abs()}/800/600';
}

class FirebaseStorageService implements StorageService {
  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  static const _allowedTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/jpg',
  };
  static const _maxBytes = 5 * 1024 * 1024; // 5 MB

  void _validate(String contentType, int size) {
    if (!_allowedTypes.contains(contentType.toLowerCase())) {
      throw const AppException(
        'Only JPEG, PNG or WebP images are allowed.',
        code: 'invalid-file-type',
      );
    }
    if (size > _maxBytes) {
      throw const AppException(
        'Image must be 5 MB or smaller.',
        code: 'file-too-large',
      );
    }
  }

  static String userAvatarPath(String uid) => 'users/$uid/avatar.jpg';
  static String roomImagePath(String roomId, String filename) =>
      'rooms/$roomId/$filename';
  static String menuImagePath(String itemId, String filename) =>
      'menu/$itemId/$filename';
  static String serviceImagePath(String serviceId, String filename) =>
      'services/$serviceId/$filename';
  static String galleryPath(String filename) => 'hotel/gallery/$filename';

  @override
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      _validate(contentType, bytes.length);
      final ref = _storage.ref(path);
      await ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Upload failed. Please try again.', cause: e);
    }
  }

  @override
  Future<void> delete(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      if (kDebugMode) debugPrint('Storage delete: $e');
    }
  }

  @override
  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      throw AppException('Could not load file.', cause: e);
    }
  }
}

StorageService createStorageService() {
  if (AppConfig.useFirebaseDataEffective) {
    try {
      return FirebaseStorageService();
    } catch (_) {}
  }
  return DemoStorageService();
}
