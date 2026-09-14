import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/room_model.dart';
import '../../models/enums.dart';
import '../../models/booking_model.dart';
import '../../services/availability_service.dart';
import '../room_repository.dart';

/// Firebase implementation of [RoomRepository].
/// Swap in providers when `kFirebaseEnabled` is true.
class FirebaseRoomRepository implements RoomRepository {
  FirebaseRoomRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _rooms =>
      _db.collection('rooms');
  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');

  @override
  Future<List<RoomModel>> getAllRooms() async {
    final snap = await _rooms.orderBy('roomNumber').get();
    return snap.docs.map((d) => RoomModel.fromJson({...d.data(), 'id': d.id})).toList();
  }

  @override
  Future<RoomModel?> getRoomById(String id) async {
    final doc = await _rooms.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return RoomModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<List<RoomModel>> searchRooms({
    String? query,
    RoomType? type,
    double? minPrice,
    double? maxPrice,
    int? minCapacity,
    double? minRating,
    int? floor,
    BedType? bedType,
    List<String>? amenities,
    bool? availableOnly,
    String sortBy = 'recommended',
  }) async {
    // Firestore limited queries – filter remaining client-side
    Query<Map<String, dynamic>> q = _rooms;
    if (type != null) {
      q = q.where('type', isEqualTo: type.name);
    }
    if (availableOnly == true) {
      q = q.where('isAvailable', isEqualTo: true);
    }
    final snap = await q.get();
    var results = snap.docs
        .map((d) => RoomModel.fromJson({...d.data(), 'id': d.id}))
        .toList();

    if (query != null && query.isNotEmpty) {
      final lower = query.toLowerCase();
      results = results
          .where((r) =>
              r.name.toLowerCase().contains(lower) ||
              r.roomNumber.toLowerCase().contains(lower) ||
              r.description.toLowerCase().contains(lower))
          .toList();
    }
    if (minPrice != null) {
      results = results.where((r) => r.pricePerNight >= minPrice).toList();
    }
    if (maxPrice != null) {
      results = results.where((r) => r.pricePerNight <= maxPrice).toList();
    }
    if (minCapacity != null) {
      results = results.where((r) => r.capacity >= minCapacity).toList();
    }
    if (minRating != null) {
      results = results.where((r) => r.rating >= minRating).toList();
    }
    if (floor != null) {
      results = results.where((r) => r.floor == floor).toList();
    }
    if (bedType != null) {
      results = results.where((r) => r.bedType == bedType).toList();
    }
    if (amenities != null && amenities.isNotEmpty) {
      results = results
          .where((r) => amenities.every((a) => r.amenities.contains(a)))
          .toList();
    }

    switch (sortBy) {
      case 'price_low':
        results.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
        break;
      case 'price_high':
        results.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
        break;
      case 'rating':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        results.sort((a, b) {
          if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
          return b.rating.compareTo(a.rating);
        });
    }
    return results;
  }

  @override
  Future<List<RoomModel>> getFeaturedRooms() async {
    final snap = await _rooms.where('isFeatured', isEqualTo: true).get();
    return snap.docs.map((d) => RoomModel.fromJson({...d.data(), 'id': d.id})).toList();
  }

  @override
  Future<List<RoomModel>> getPopularRooms() async {
    final snap = await _rooms.where('isPopular', isEqualTo: true).get();
    return snap.docs.map((d) => RoomModel.fromJson({...d.data(), 'id': d.id})).toList();
  }

  @override
  Future<List<RoomModel>> getRoomsByType(RoomType type) async {
    final snap = await _rooms.where('type', isEqualTo: type.name).get();
    return snap.docs.map((d) => RoomModel.fromJson({...d.data(), 'id': d.id})).toList();
  }

  @override
  Future<List<RoomModel>> getFavoriteRooms(List<String> favoriteIds) async {
    if (favoriteIds.isEmpty) return [];
    // Firestore whereIn limited to 10 – batch if needed
    final ids = favoriteIds.take(10).toList();
    final snap = await _rooms.where(FieldPath.documentId, whereIn: ids).get();
    return snap.docs.map((d) => RoomModel.fromJson({...d.data(), 'id': d.id})).toList();
  }

  @override
  Future<bool> checkAvailability(
    String roomId,
    DateTime checkIn,
    DateTime checkOut,
  ) async {
    final room = await getRoomById(roomId);
    if (room == null) return false;

    final snap = await _bookings.where('roomId', isEqualTo: roomId).get();
    final bookings = snap.docs
        .map((d) => BookingModel.fromJson({...d.data(), 'id': d.id}))
        .toList();

    return AvailabilityService.isRoomAvailable(
      room: room,
      checkIn: checkIn,
      checkOut: checkOut,
      existingBookings: bookings,
    );
  }

  @override
  Future<void> createRoom(RoomModel room) async {
    await _rooms.doc(room.id).set(room.toJson());
  }

  @override
  Future<void> updateRoom(RoomModel room) async {
    await _rooms.doc(room.id).update({
      ...room.toJson(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteRoom(String id) async {
    await _rooms.doc(id).delete();
  }
}
