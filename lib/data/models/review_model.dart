import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String guestId;
  final String guestName;
  final String? guestPhotoUrl;
  final String? roomId;
  final String? roomName;
  final double rating;
  final String comment;
  final List<String> imageUrls;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewModel({
    required this.id,
    required this.guestId,
    required this.guestName,
    this.guestPhotoUrl,
    this.roomId,
    this.roomName,
    required this.rating,
    required this.comment,
    this.imageUrls = const [],
    this.isApproved = true,
    required this.createdAt,
    required this.updatedAt,
  });

  ReviewModel copyWith({
    String? id,
    String? guestId,
    String? guestName,
    String? guestPhotoUrl,
    String? roomId,
    String? roomName,
    double? rating,
    String? comment,
    List<String>? imageUrls,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      guestId: guestId ?? this.guestId,
      guestName: guestName ?? this.guestName,
      guestPhotoUrl: guestPhotoUrl ?? this.guestPhotoUrl,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guestId': guestId,
      'guestName': guestName,
      'guestPhotoUrl': guestPhotoUrl,
      'roomId': roomId,
      'roomName': roomName,
      'rating': rating,
      'comment': comment,
      'imageUrls': imageUrls,
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      guestId: json['guestId'] as String,
      guestName: json['guestName'] as String,
      guestPhotoUrl: json['guestPhotoUrl'] as String?,
      roomId: json['roomId'] as String?,
      roomName: json['roomName'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      isApproved: json['isApproved'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        guestId,
        guestName,
        guestPhotoUrl,
        roomId,
        roomName,
        rating,
        comment,
        imageUrls,
        isApproved,
        createdAt,
        updatedAt,
      ];
}
