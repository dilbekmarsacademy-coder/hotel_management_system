import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/notification_model.dart';
import '../../models/enums.dart';
import '../../converters/firestore_converters.dart';
import '../../../core/errors/app_exception.dart';

class FirebaseNotificationRepository {
  FirebaseNotificationRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('notifications');

  NotificationModel _from(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = Fs.withId(doc);
    return NotificationModel(
      id: Fs.stringRequired(m['id']),
      userId: Fs.stringRequired(m['userId']),
      title: Fs.stringRequired(m['title']),
      body: Fs.stringRequired(m['body']),
      type: Fs.enumByName(
        NotificationType.values,
        m['type'],
        fallback: NotificationType.system,
      ),
      isRead: Fs.boolVal(m['isRead']),
      createdAt: Fs.dateTimeRequired(m['createdAt']),
      data: m['data'] is Map
          ? Map<String, dynamic>.from(m['data'] as Map)
          : null,
    );
  }

  Stream<List<NotificationModel>> watchUserNotifications(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(_from).toList());
  }

  Future<int> unreadCount(String userId) async {
    try {
      final snap = await _col
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      return snap.docs.length;
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _col.doc(id).update({'isRead': true});
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final snap = await _col
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      final batch = _db.batch();
      for (final d in snap.docs) {
        batch.update(d.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Future<void> create({
    required String userId,
    required String title,
    required String body,
    NotificationType type = NotificationType.system,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _col.add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type.name,
        'isRead': false,
        'data': data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _col.doc(id).delete();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }
}
