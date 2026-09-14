import 'package:equatable/equatable.dart';
import 'enums.dart';

class RoomModel extends Equatable {
  final String id;
  final String roomNumber;
  final String name;
  final RoomType type;
  final String description;
  final double pricePerNight;
  final int capacity;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final List<String> amenities;
  final int floor;
  final BedType bedType;
  final bool isAvailable;
  final RoomStatus status;
  final int sizeSqm;
  final bool isFeatured;
  final bool isPopular;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RoomModel({
    required this.id,
    required this.roomNumber,
    required this.name,
    required this.type,
    required this.description,
    required this.pricePerNight,
    required this.capacity,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.imageUrls = const [],
    this.amenities = const [],
    required this.floor,
    required this.bedType,
    this.isAvailable = true,
    this.status = RoomStatus.available,
    this.sizeSqm = 30,
    this.isFeatured = false,
    this.isPopular = false,
    required this.createdAt,
    required this.updatedAt,
  });

  RoomModel copyWith({
    String? id,
    String? roomNumber,
    String? name,
    RoomType? type,
    String? description,
    double? pricePerNight,
    int? capacity,
    double? rating,
    int? reviewCount,
    List<String>? imageUrls,
    List<String>? amenities,
    int? floor,
    BedType? bedType,
    bool? isAvailable,
    RoomStatus? status,
    int? sizeSqm,
    bool? isFeatured,
    bool? isPopular,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      capacity: capacity ?? this.capacity,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      floor: floor ?? this.floor,
      bedType: bedType ?? this.bedType,
      isAvailable: isAvailable ?? this.isAvailable,
      status: status ?? this.status,
      sizeSqm: sizeSqm ?? this.sizeSqm,
      isFeatured: isFeatured ?? this.isFeatured,
      isPopular: isPopular ?? this.isPopular,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'name': name,
      'type': type.name,
      'description': description,
      'pricePerNight': pricePerNight,
      'capacity': capacity,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrls': imageUrls,
      'amenities': amenities,
      'floor': floor,
      'bedType': bedType.name,
      'isAvailable': isAvailable,
      'status': status.name,
      'sizeSqm': sizeSqm,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      roomNumber: json['roomNumber'] as String,
      name: json['name'] as String,
      type: RoomType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RoomType.standard,
      ),
      description: json['description'] as String,
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      capacity: json['capacity'] as int,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      floor: json['floor'] as int,
      bedType: BedType.values.firstWhere(
        (e) => e.name == json['bedType'],
        orElse: () => BedType.queen,
      ),
      isAvailable: json['isAvailable'] as bool? ?? true,
      status: RoomStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RoomStatus.available,
      ),
      sizeSqm: json['sizeSqm'] as int? ?? 30,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isPopular: json['isPopular'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomNumber,
        name,
        type,
        description,
        pricePerNight,
        capacity,
        rating,
        reviewCount,
        imageUrls,
        amenities,
        floor,
        bedType,
        isAvailable,
        status,
        sizeSqm,
        isFeatured,
        isPopular,
        createdAt,
        updatedAt,
      ];
}
