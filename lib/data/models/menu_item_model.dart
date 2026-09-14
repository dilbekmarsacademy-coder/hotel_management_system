import 'package:equatable/equatable.dart';

class MenuItemModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String? imageUrl;
  final List<String> ingredients;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final bool isVegetarian;
  final bool isSpicy;
  final int preparationTimeMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.imageUrl,
    this.ingredients = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.isVegetarian = false,
    this.isSpicy = false,
    this.preparationTimeMinutes = 20,
    required this.createdAt,
    required this.updatedAt,
  });

  MenuItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    List<String>? ingredients,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    bool? isVegetarian,
    bool? isSpicy,
    int? preparationTimeMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isSpicy: isSpicy ?? this.isSpicy,
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
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
      'ingredients': ingredients,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'isVegetarian': isVegetarian,
      'isSpicy': isSpicy,
      'preparationTimeMinutes': preparationTimeMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isSpicy: json['isSpicy'] as bool? ?? false,
      preparationTimeMinutes: json['preparationTimeMinutes'] as int? ?? 20,
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
        ingredients,
        rating,
        reviewCount,
        isAvailable,
        isVegetarian,
        isSpicy,
        preparationTimeMinutes,
        createdAt,
        updatedAt,
      ];
}
