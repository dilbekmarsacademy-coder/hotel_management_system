import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/menu_item_model.dart';
import '../../../../data/repositories/restaurant_repository.dart';
import '../../../../providers/cart_provider.dart';

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return DummyRestaurantRepository();
});

final menuItemsProvider = FutureProvider<List<MenuItemModel>>((ref) async {
  return ref.watch(restaurantRepositoryProvider).getAllMenuItems();
});

final menuCategoriesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(restaurantRepositoryProvider).getCategories();
});

class RestaurantHomeScreen extends ConsumerStatefulWidget {
  const RestaurantHomeScreen({super.key});

  @override
  ConsumerState<RestaurantHomeScreen> createState() =>
      _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends ConsumerState<RestaurantHomeScreen> {
  String? _selectedCategory;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuItemsProvider);
    final categoriesAsync = ref.watch(menuCategoriesProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Restaurant'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  // Navigate to cart - will be wired when cart screen is ready
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        cart.totalItems == 0
                            ? 'Cart is empty'
                            : '${cart.totalItems} items • \$${cart.total.toStringAsFixed(2)}',
                      ),
                    ),
                  );
                },
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search menu...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Categories
          categoriesAsync.when(
            loading: () => const SizedBox(height: 48),
            error: (_, __) => const SizedBox.shrink(),
            data: (categories) {
              return SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategory == null,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = null),
                      ),
                    ),
                    ...categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(cat),
                          selected: _selectedCategory == cat,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = cat),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          // Menu list
          Expanded(
            child: menuAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    const Text('Failed to load menu'),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(menuItemsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (items) {
                var filtered = items;
                if (_selectedCategory != null) {
                  filtered = filtered
                      .where((i) => i.category == _selectedCategory)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered
                      .where((i) =>
                          i.name.toLowerCase().contains(q) ||
                          i.description.toLowerCase().contains(q))
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu,
                            size: 64, color: AppColors.mediumGrey),
                        const SizedBox(height: 16),
                        Text('No items found',
                            style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _MenuItemCard(
                      item: item,
                      onAdd: () {
                        ref.read(cartProvider.notifier).addItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} added to cart'),
                            duration: const Duration(seconds: 1),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .removeItem(item.id);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: cart.totalItems > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cart: ${cart.totalItems} items • \$${cart.total.toStringAsFixed(2)}',
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.primary,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                '${cart.totalItems} • \$${cart.total.toStringAsFixed(2)}',
              ),
            )
          : null,
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onAdd;

  const _MenuItemCard({required this.item, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(14)),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl ?? AppConstants.placeholderFoodImage,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 110,
                height: 110,
                color: AppColors.lightGrey,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.isVegetarian)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.eco, size: 16, color: Colors.green),
                        ),
                      if (item.isSpicy)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.local_fire_department,
                              size: 16, color: Colors.red),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Spacer(),
                      if (item.isAvailable)
                        GestureDetector(
                          onTap: onAdd,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 18),
                          ),
                        )
                      else
                        Text(
                          'Unavailable',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.error),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
