import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_config.dart';

/// Sensitive-operation audit trail.
/// Demo mode keeps an in-memory log; Firebase mode writes `auditLogs`.
abstract class AuditService {
  Future<void> log({
    required String actorId,
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? metadata,
  });
}

class DemoAuditService implements AuditService {
  final List<Map<String, dynamic>> entries = [];

  @override
  Future<void> log({
    required String actorId,
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? metadata,
  }) async {
    entries.add({
      'actorId': actorId,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'metadata': metadata ?? {},
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}

class FirestoreAuditService implements AuditService {
  FirestoreAuditService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<void> log({
    required String actorId,
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _db.collection('auditLogs').add({
        'actorId': actorId,
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'metadata': metadata ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Never fail the primary operation due to audit write
    }
  }
}

AuditService createAuditService() {
  if (AppConfig.useFirebaseDataEffective) {
    return FirestoreAuditService();
  }
  return DemoAuditService();
}
