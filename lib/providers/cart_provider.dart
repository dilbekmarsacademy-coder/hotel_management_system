import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/menu_item_model.dart';

class CartItem {
  final MenuItemModel item;
  final int quantity;
  final String? notes;

  const CartItem({
    required this.item,
    this.quantity = 1,
    this.notes,
  });

  double get subtotal => item.price * quantity;

  CartItem copyWith({int? quantity, String? notes}) {
    return CartItem(
      item: item,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}

class CartState {
  final List<CartItem> items;
  final String? roomNumber;
  final String specialInstructions;

  const CartState({
    this.items = const [],
    this.roomNumber,
    this.specialInstructions = '',
  });

  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => items.fold(0.0, (sum, i) => sum + i.subtotal);
  double get tax => subtotal * 0.08;
  double get serviceFee => subtotal * 0.05;
  double get total => subtotal + tax + serviceFee;

  CartState copyWith({
    List<CartItem>? items,
    String? roomNumber,
    String? specialInstructions,
  }) {
    return CartState(
      items: items ?? this.items,
      roomNumber: roomNumber ?? this.roomNumber,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(MenuItemModel item, {int quantity = 1}) {
    final existing = state.items.indexWhere((c) => c.item.id == item.id);
    final list = List<CartItem>.from(state.items);
    if (existing >= 0) {
      list[existing] = list[existing].copyWith(
        quantity: list[existing].quantity + quantity,
      );
    } else {
      list.add(CartItem(item: item, quantity: quantity));
    }
    state = state.copyWith(items: list);
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((c) => c.item.id != itemId).toList(),
    );
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }
    final list = state.items.map((c) {
      if (c.item.id == itemId) return c.copyWith(quantity: quantity);
      return c;
    }).toList();
    state = state.copyWith(items: list);
  }

  void setRoomNumber(String room) {
    state = state.copyWith(roomNumber: room);
  }

  void setInstructions(String text) {
    state = state.copyWith(specialInstructions: text);
  }

  void clear() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
