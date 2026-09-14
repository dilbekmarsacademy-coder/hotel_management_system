import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/room_model.dart';
import '../data/models/enums.dart';
import '../data/repositories/room_repository.dart';
import 'repository_providers.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return createRoomRepository();
});

final allRoomsProvider = FutureProvider<List<RoomModel>>((ref) async {
  return ref.watch(roomRepositoryProvider).getAllRooms();
});

final featuredRoomsProvider = FutureProvider<List<RoomModel>>((ref) async {
  return ref.watch(roomRepositoryProvider).getFeaturedRooms();
});

final popularRoomsProvider = FutureProvider<List<RoomModel>>((ref) async {
  return ref.watch(roomRepositoryProvider).getPopularRooms();
});

final roomByIdProvider =
    FutureProvider.family<RoomModel?, String>((ref, id) async {
  return ref.watch(roomRepositoryProvider).getRoomById(id);
});

// Search / Filter state
class RoomFilterState {
  final String query;
  final RoomType? type;
  final double minPrice;
  final double maxPrice;
  final int minCapacity;
  final double minRating;
  final int? floor;
  final BedType? bedType;
  final List<String> amenities;
  final bool availableOnly;
  final String sortBy;

  const RoomFilterState({
    this.query = '',
    this.type,
    this.minPrice = 0,
    this.maxPrice = 2000,
    this.minCapacity = 1,
    this.minRating = 0,
    this.floor,
    this.bedType,
    this.amenities = const [],
    this.availableOnly = false,
    this.sortBy = 'recommended',
  });

  RoomFilterState copyWith({
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
    String? sortBy,
    bool clearType = false,
    bool clearFloor = false,
    bool clearBedType = false,
  }) {
    return RoomFilterState(
      query: query ?? this.query,
      type: clearType ? null : (type ?? this.type),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minCapacity: minCapacity ?? this.minCapacity,
      minRating: minRating ?? this.minRating,
      floor: clearFloor ? null : (floor ?? this.floor),
      bedType: clearBedType ? null : (bedType ?? this.bedType),
      amenities: amenities ?? this.amenities,
      availableOnly: availableOnly ?? this.availableOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class RoomFilterNotifier extends StateNotifier<RoomFilterState> {
  RoomFilterNotifier() : super(const RoomFilterState());

  void setQuery(String query) => state = state.copyWith(query: query);
  void setType(RoomType? type) =>
      state = state.copyWith(type: type, clearType: type == null);
  void setPriceRange(double min, double max) =>
      state = state.copyWith(minPrice: min, maxPrice: max);
  void setMinCapacity(int capacity) =>
      state = state.copyWith(minCapacity: capacity);
  void setMinRating(double rating) =>
      state = state.copyWith(minRating: rating);
  void setFloor(int? floor) =>
      state = state.copyWith(floor: floor, clearFloor: floor == null);
  void setBedType(BedType? bedType) =>
      state = state.copyWith(bedType: bedType, clearBedType: bedType == null);
  void setAmenities(List<String> amenities) =>
      state = state.copyWith(amenities: amenities);
  void toggleAmenity(String amenity) {
    final list = List<String>.from(state.amenities);
    if (list.contains(amenity)) {
      list.remove(amenity);
    } else {
      list.add(amenity);
    }
    state = state.copyWith(amenities: list);
  }
  void setAvailableOnly(bool value) =>
      state = state.copyWith(availableOnly: value);
  void setSortBy(String sortBy) => state = state.copyWith(sortBy: sortBy);
  void reset() => state = const RoomFilterState();
}

final roomFilterProvider =
    StateNotifierProvider<RoomFilterNotifier, RoomFilterState>((ref) {
  return RoomFilterNotifier();
});

final filteredRoomsProvider = FutureProvider<List<RoomModel>>((ref) async {
  final filter = ref.watch(roomFilterProvider);
  final repo = ref.watch(roomRepositoryProvider);
  return repo.searchRooms(
    query: filter.query.isEmpty ? null : filter.query,
    type: filter.type,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    minCapacity: filter.minCapacity,
    minRating: filter.minRating,
    floor: filter.floor,
    bedType: filter.bedType,
    amenities: filter.amenities.isEmpty ? null : filter.amenities,
    availableOnly: filter.availableOnly,
    sortBy: filter.sortBy,
  );
});

// Favorites
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({});

  void toggle(String roomId) {
    final newSet = Set<String>.from(state);
    if (newSet.contains(roomId)) {
      newSet.remove(roomId);
    } else {
      newSet.add(roomId);
    }
    state = newSet;
  }

  bool isFavorite(String roomId) => state.contains(roomId);
}

// Compare
final compareRoomsProvider =
    StateNotifierProvider<CompareRoomsNotifier, List<String>>((ref) {
  return CompareRoomsNotifier();
});

class CompareRoomsNotifier extends StateNotifier<List<String>> {
  CompareRoomsNotifier() : super([]);

  void toggle(String roomId) {
    final list = List<String>.from(state);
    if (list.contains(roomId)) {
      list.remove(roomId);
    } else if (list.length < 3) {
      list.add(roomId);
    }
    state = list;
  }

  void clear() => state = [];
  bool isSelected(String roomId) => state.contains(roomId);
}
