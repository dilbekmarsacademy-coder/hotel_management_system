import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String? imageUrl;
  final String? iconName;
  final bool isAvailable;
  final int durationMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.imageUrl,
    this.iconName,
    this.isAvailable = true,
    this.durationMinutes = 60,
    required this.createdAt,
    required this.updatedAt,
  });

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    String? iconName,
    bool? isAvailable,
    int? durationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      iconName: iconName ?? this.iconName,
      isAvailable: isAvailable ?? this.isAvailable,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'iconName': iconName,
      'isAvailable': isAvailable,
      'durationMinutes': durationMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      iconName: json['iconName'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        price,
        imageUrl,
        iconName,
        isAvailable,
        durationMinutes,
        createdAt,
        updatedAt,
      ];
}
