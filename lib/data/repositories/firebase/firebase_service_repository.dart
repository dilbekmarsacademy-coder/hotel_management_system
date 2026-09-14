import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/service_model.dart';
import '../../converters/firestore_converters.dart';
import '../../../core/errors/app_exception.dart';
import '../service_repository.dart';

class FirebaseServiceRepository implements ServiceRepository {
  FirebaseServiceRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('services');

  ServiceModel _from(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = Fs.withId(doc);
    return ServiceModel(
      id: Fs.stringRequired(m['id']),
      name: Fs.stringRequired(m['name']),
      description: Fs.stringRequired(m['description']),
      category: Fs.stringRequired(m['category'], fallback: 'general'),
      price: Fs.doubleVal(m['price']),
      imageUrl: Fs.string(m['imageUrl']),
      iconName: Fs.string(m['iconName']),
      isAvailable: Fs.boolVal(m['isAvailable'], fallback: true),
      durationMinutes: Fs.intVal(m['durationMinutes'], fallback: 60),
      createdAt: Fs.dateTimeRequired(m['createdAt']),
      updatedAt: Fs.dateTimeRequired(m['updatedAt']),
    );
  }

  Map<String, dynamic> _to(ServiceModel s) => {
        'name': s.name,
        'description': s.description,
        'category': s.category,
        'price': s.price,
        'imageUrl': s.imageUrl,
        'iconName': s.iconName,
        'isAvailable': s.isAvailable,
        'durationMinutes': s.durationMinutes,
        'createdAt': Fs.timestamp(s.createdAt),
        'updatedAt': Fs.timestamp(s.updatedAt),
      };

  @override
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final snap = await _col.orderBy('name').get();
      return snap.docs.map(_from).toList();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<ServiceModel?> getServiceById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) return null;
      return _from(doc);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    try {
      final snap = await _col.where('category', isEqualTo: category).get();
      return snap.docs.map(_from).toList();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final all = await getAllServices();
      return all.map((s) => s.category).toSet().toList()..sort();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Future<ServiceModel> create(ServiceModel service) async {
    try {
      final ref = service.id.isEmpty ? _col.doc() : _col.doc(service.id);
      final data = _to(service);
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await ref.set(data);
      return service.copyWith(id: ref.id);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Future<ServiceModel> update(ServiceModel service) async {
    try {
      final data = _to(service);
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _col.doc(service.id).update(data);
      return service;
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Future<void> setAvailable(String id, bool available) async {
    try {
      await _col.doc(id).update({
        'isAvailable': available,
        'updatedAt': FieldValue.serverTimestamp(),
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
