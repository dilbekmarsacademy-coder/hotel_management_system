import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/menu_item_model.dart';
import '../../converters/firestore_converters.dart';
import '../../../core/errors/app_exception.dart';
import '../restaurant_repository.dart';

/// Menu items collection: restaurantMenu
class FirebaseRestaurantRepository implements RestaurantRepository {
  FirebaseRestaurantRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _menu =>
      _db.collection('restaurantMenu');
  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('restaurantOrders');

  MenuItemModel _fromMenu(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = Fs.withId(doc);
    return MenuItemModel(
      id: Fs.stringRequired(m['id']),
      name: Fs.stringRequired(m['name']),
      description: Fs.stringRequired(m['description']),
      category: Fs.stringRequired(m['category'], fallback: 'Main'),
      price: Fs.doubleVal(m['price']),
      imageUrl: Fs.string(m['imageUrl']),
      ingredients: Fs.stringList(m['ingredients']),
      rating: Fs.doubleVal(m['rating']),
      reviewCount: Fs.intVal(m['reviewCount']),
      isAvailable: Fs.boolVal(m['isAvailable'], fallback: true),
      isVegetarian: Fs.boolVal(m['isVegetarian']),
      isSpicy: Fs.boolVal(m['isSpicy']),
      preparationTimeMinutes: Fs.intVal(m['preparationTimeMinutes'], fallback: 20),
      createdAt: Fs.dateTimeRequired(m['createdAt']),
      updatedAt: Fs.dateTimeRequired(m['updatedAt']),
    );
  }

  @override
  Future<List<MenuItemModel>> getAllMenuItems() async {
    try {
      final snap = await _menu.orderBy('name').get();
      return snap.docs.map(_fromMenu).toList();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<MenuItemModel?> getMenuItemById(String id) async {
    try {
      final doc = await _menu.doc(id).get();
      if (!doc.exists) return null;
      return _fromMenu(doc);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<List<MenuItemModel>> getByCategory(String category) async {
    try {
      final snap = await _menu.where('category', isEqualTo: category).get();
      return snap.docs.map(_fromMenu).toList();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<List<String>> getCategories() async {
    final items = await getAllMenuItems();
    return items.map((e) => e.category).toSet().toList()..sort();
  }

  @override
  Future<List<MenuItemModel>> search(String query) async {
    final all = await getAllMenuItems();
    final q = query.toLowerCase();
    return all
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.description.toLowerCase().contains(q) ||
            m.category.toLowerCase().contains(q))
        .toList();
  }

  Future<MenuItemModel> createMenuItem(MenuItemModel item) async {
    try {
      final ref = item.id.isEmpty ? _menu.doc() : _menu.doc(item.id);
      await ref.set({
        'name': item.name,
        'description': item.description,
        'category': item.category,
        'price': item.price,
        'imageUrl': item.imageUrl,
        'ingredients': item.ingredients,
        'rating': item.rating,
        'reviewCount': item.reviewCount,
        'isAvailable': item.isAvailable,
        'isVegetarian': item.isVegetarian,
        'isSpicy': item.isSpicy,
        'preparationTimeMinutes': item.preparationTimeMinutes,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return item.copyWith(id: ref.id);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Future<void> setMenuAvailability(String id, bool available) async {
    try {
      await _menu.doc(id).update({
        'isAvailable': available,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  // ── Orders ─────────────────────────────────────────────────

  Future<String> createOrder({
    required String guestId,
    required String guestName,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double total,
    String? roomId,
    String? roomNumber,
    String deliveryType = 'room',
    String? notes,
  }) async {
    try {
      final id = const Uuid().v4();
      await _orders.doc(id).set({
        'guestId': guestId,
        'guestName': guestName,
        'items': items,
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'roomId': roomId,
        'roomNumber': roomNumber,
        'deliveryType': deliveryType,
        'notes': notes,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return id;
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _orders.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchOrdersByStatus(String status) {
    return _orders
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchGuestOrders(String guestId) {
    return _orders
        .where('guestId', isEqualTo: guestId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getGuestOrderHistory(String guestId) async {
    try {
      final snap = await _orders
          .where('guestId', isEqualTo: guestId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) => Fs.withId(d)).toList();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }
}
