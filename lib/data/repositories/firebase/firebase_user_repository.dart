import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/enums.dart';
import '../../converters/firestore_converters.dart';
import '../../../core/errors/app_exception.dart';

abstract class UserRepository {
  Future<UserModel?> getById(String id);
  Future<UserModel?> getByEmail(String email);
  Future<UserModel> create(UserModel user);
  Future<UserModel> update(UserModel user);
  Future<void> updatePhotoUrl(String userId, String photoUrl);
  Future<void> setRole(String userId, UserRole role);
  Stream<UserModel?> watchUser(String userId);
}

class DummyUserRepository implements UserRepository {
  final Map<String, UserModel> _users = {};

  @override
  Future<UserModel?> getById(String id) async => _users[id];

  @override
  Future<UserModel?> getByEmail(String email) async {
    final lower = email.toLowerCase();
    try {
      return _users.values.firstWhere((u) => u.email.toLowerCase() == lower);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel> create(UserModel user) async {
    _users[user.id] = user;
    return user;
  }

  @override
  Future<UserModel> update(UserModel user) async {
    _users[user.id] = user.copyWith(updatedAt: DateTime.now());
    return _users[user.id]!;
  }

  @override
  Future<void> updatePhotoUrl(String userId, String photoUrl) async {
    final u = _users[userId];
    if (u != null) {
      _users[userId] = u.copyWith(photoUrl: photoUrl, updatedAt: DateTime.now());
    }
  }

  @override
  Future<void> setRole(String userId, UserRole role) async {
    final u = _users[userId];
    if (u != null) {
      _users[userId] = u.copyWith(role: role, updatedAt: DateTime.now());
    }
  }

  @override
  Stream<UserModel?> watchUser(String userId) async* {
    yield _users[userId];
  }
}

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('users');

  UserModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = Fs.withId(doc);
    return UserModel(
      id: Fs.stringRequired(m['id']),
      email: Fs.stringRequired(m['email']),
      firstName: Fs.stringRequired(m['firstName']),
      lastName: Fs.stringRequired(m['lastName']),
      phone: Fs.string(m['phone']),
      photoUrl: Fs.string(m['photoUrl']),
      role: Fs.enumByName(UserRole.values, m['role'], fallback: UserRole.guest),
      country: Fs.string(m['country']),
      idDocument: Fs.string(m['idDocument']),
      createdAt: Fs.dateTimeRequired(m['createdAt']),
      updatedAt: Fs.dateTimeRequired(m['updatedAt']),
      isEmailVerified: Fs.boolVal(m['isEmailVerified']),
      isActive: Fs.boolVal(m['isActive'], fallback: true),
    );
  }

  Map<String, dynamic> _toMap(UserModel u) => {
        'email': u.email,
        'firstName': u.firstName,
        'lastName': u.lastName,
        'phone': u.phone,
        'photoUrl': u.photoUrl,
        'role': u.role.name,
        'country': u.country,
        'idDocument': u.idDocument,
        'createdAt': Fs.timestamp(u.createdAt),
        'updatedAt': Fs.timestamp(u.updatedAt),
        'isEmailVerified': u.isEmailVerified,
        'isActive': u.isActive,
      };

  @override
  Future<UserModel?> getById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) return null;
      return _fromDoc(doc);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<UserModel?> getByEmail(String email) async {
    try {
      final snap =
          await _col.where('email', isEqualTo: email.toLowerCase()).limit(1).get();
      if (snap.docs.isEmpty) return null;
      return _fromDoc(snap.docs.first);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<UserModel> create(UserModel user) async {
    try {
      final existing = await _col.doc(user.id).get();
      if (existing.exists) {
        return _fromDoc(existing);
      }
      final data = _toMap(user);
      data['email'] = user.email.toLowerCase();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _col.doc(user.id).set(data);
      return user;
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<UserModel> update(UserModel user) async {
    try {
      final data = _toMap(user);
      data['updatedAt'] = FieldValue.serverTimestamp();
      // Never allow client to escalate role via generic update – role uses setRole
      data.remove('role');
      await _col.doc(user.id).update(data);
      return user.copyWith(updatedAt: DateTime.now());
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<void> updatePhotoUrl(String userId, String photoUrl) async {
    try {
      await _col.doc(userId).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<void> setRole(String userId, UserRole role) async {
    // Must only be callable by Admin (enforced in Firestore rules)
    try {
      await _col.doc(userId).update({
        'role': role.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Stream<UserModel?> watchUser(String userId) {
    return _col.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _fromDoc(doc);
    });
  }
}
