import '../models/menu_item_model.dart';
import '../dummy_data/dummy_data.dart';

abstract class RestaurantRepository {
  Future<List<MenuItemModel>> getAllMenuItems();
  Future<MenuItemModel?> getMenuItemById(String id);
  Future<List<MenuItemModel>> getByCategory(String category);
  Future<List<String>> getCategories();
  Future<List<MenuItemModel>> search(String query);
}

class DummyRestaurantRepository implements RestaurantRepository {
  @override
  Future<List<MenuItemModel>> getAllMenuItems() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return List.from(DummyData.menuItems);
  }

  @override
  Future<MenuItemModel?> getMenuItemById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return DummyData.menuItems.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MenuItemModel>> getByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return DummyData.menuItems
        .where((m) => m.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return DummyData.menuItems.map((m) => m.category).toSet().toList();
  }

  @override
  Future<List<MenuItemModel>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final q = query.toLowerCase();
    return DummyData.menuItems
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.description.toLowerCase().contains(q) ||
            m.category.toLowerCase().contains(q))
        .toList();
  }
}
