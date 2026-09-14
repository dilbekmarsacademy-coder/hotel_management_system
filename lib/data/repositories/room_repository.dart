import '../models/room_model.dart';
import '../models/enums.dart';
import '../dummy_data/dummy_data.dart';
import '../services/availability_service.dart';


abstract class RoomRepository {
  Future<List<RoomModel>> getAllRooms();
  Future<RoomModel?> getRoomById(String id);
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
  });
  Future<List<RoomModel>> getFeaturedRooms();
  Future<List<RoomModel>> getPopularRooms();
  Future<List<RoomModel>> getRoomsByType(RoomType type);
  Future<List<RoomModel>> getFavoriteRooms(List<String> favoriteIds);
  Future<bool> checkAvailability(String roomId, DateTime checkIn, DateTime checkOut);
  Future<void> createRoom(RoomModel room);
  Future<void> updateRoom(RoomModel room);
  Future<void> deleteRoom(String id);
}

class DummyRoomRepository implements RoomRepository {
  @override
  Future<List<RoomModel>> getAllRooms() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(DummyData.rooms);
  }

  @override
  Future<RoomModel?> getRoomById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return DummyData.rooms.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
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
    await Future.delayed(const Duration(milliseconds: 350));
    var results = List<RoomModel>.from(DummyData.rooms);

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((r) {
        return r.name.toLowerCase().contains(q) ||
            r.roomNumber.toLowerCase().contains(q) ||
            r.type.displayName.toLowerCase().contains(q) ||
            r.description.toLowerCase().contains(q);
      }).toList();
    }

    if (type != null) {
      results = results.where((r) => r.type == type).toList();
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
      results = results.where((r) {
        return amenities.every((a) => r.amenities.contains(a));
      }).toList();
    }
    if (availableOnly == true) {
      results = results.where((r) => r.isAvailable).toList();
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
      case 'newest':
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default: // recommended
        results.sort((a, b) {
          if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
          return b.rating.compareTo(a.rating);
        });
    }

    return results;
  }

  @override
  Future<List<RoomModel>> getFeaturedRooms() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return DummyData.rooms.where((r) => r.isFeatured).toList();
  }

  @override
  Future<List<RoomModel>> getPopularRooms() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return DummyData.rooms.where((r) => r.isPopular).toList();
  }

  @override
  Future<List<RoomModel>> getRoomsByType(RoomType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return DummyData.rooms.where((r) => r.type == type).toList();
  }

  @override
  Future<List<RoomModel>> getFavoriteRooms(List<String> favoriteIds) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return DummyData.rooms.where((r) => favoriteIds.contains(r.id)).toList();
  }

  @override
  Future<bool> checkAvailability(
      String roomId, DateTime checkIn, DateTime checkOut) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final room = DummyData.rooms.where((r) => r.id == roomId).firstOrNull;
    if (room == null) return false;

    return AvailabilityService.isRoomAvailable(
      room: room,
      checkIn: checkIn,
      checkOut: checkOut,
      existingBookings: DummyData.bookings,
    );
  }

  Future<List<RoomModel>> getAvailableRoomsForDates(
    DateTime checkIn,
    DateTime checkOut,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return AvailabilityService.filterAvailableRooms(
      rooms: DummyData.rooms,
      checkIn: checkIn,
      checkOut: checkOut,
      existingBookings: DummyData.bookings,
    );
  }

  @override
  Future<void> createRoom(RoomModel room) async {
    await Future.delayed(const Duration(milliseconds: 300));
    DummyData.rooms.add(room);
  }

  @override
  Future<void> updateRoom(RoomModel room) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = DummyData.rooms.indexWhere((r) => r.id == room.id);
    if (index == -1) {
      throw StateError('Room ${room.id} not found');
    }
    DummyData.rooms[index] = room;
  }

  @override
  Future<void> deleteRoom(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    DummyData.rooms.removeWhere((r) => r.id == id);
  }
}
