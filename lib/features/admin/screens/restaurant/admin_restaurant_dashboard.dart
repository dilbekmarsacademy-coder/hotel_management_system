import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/menu_item_model.dart';
import '../../../../data/repositories/restaurant_repository.dart';

final adminMenuProvider = FutureProvider<List<MenuItemModel>>((ref) async {
  return ref.watch(restaurantRepositoryProvider).getAllMenuItems();
});

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return DummyRestaurantRepository();
});

class AdminRestaurantDashboard extends ConsumerStatefulWidget {
  const AdminRestaurantDashboard({super.key});

  @override
  ConsumerState<AdminRestaurantDashboard> createState() => _AdminRestaurantDashboardState();
}

class _AdminRestaurantDashboardState extends ConsumerState<AdminRestaurantDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(adminMenuProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Restaurant Admin'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.secondary,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Menu'),
            Tab(text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DashboardTab(menuAsync: menuAsync),
          _MenuTab(menuAsync: menuAsync, search: _search, onSearch: (v) => setState(() => _search = v)),
          const _OrdersTab(),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final AsyncValue<List<MenuItemModel>> menuAsync;
  const _DashboardTab({required this.menuAsync});

  @override
  Widget build(BuildContext context) {
    return menuAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('Failed to load')),
      data: (items) {
        final available = items.where((i) => i.isAvailable).length;
        final categories = items.map((i) => i.category).toSet().length;
        final avgPrice = items.isEmpty ? 0.0 : items.fold<double>(0, (s, i) => s + i.price) / items.length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _Kpi('Menu Items', '${items.length}', Icons.restaurant_menu, AppColors.primary),
                const SizedBox(width: 10),
                _Kpi('Available', '$available', Icons.check_circle, AppColors.success),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Kpi('Categories', '$categories', Icons.category, AppColors.info),
                const SizedBox(width: 10),
                _Kpi('Avg Price', '\$${avgPrice.toStringAsFixed(0)}', Icons.attach_money, AppColors.secondary),
              ],
            ),
            const SizedBox(height: 24),
            Text('Popular Items', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...items.take(5).map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.name, style: Theme.of(context).textTheme.titleSmall)),
                      Text('\$${item.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.secondary)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.isAvailable ? AppColors.successLight : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.isAvailable ? 'Active' : 'Off',
                          style: TextStyle(fontSize: 11, color: item.isAvailable ? AppColors.success : AppColors.error),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Kpi(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MenuTab extends ConsumerWidget {
  final AsyncValue<List<MenuItemModel>> menuAsync;
  final String search;
  final ValueChanged<String> onSearch;

  const _MenuTab({required this.menuAsync, required this.search, required this.onSearch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(hintText: 'Search menu...', prefixIcon: Icon(Icons.search), isDense: true),
            onChanged: onSearch,
          ),
        ),
        Expanded(
          child: menuAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Center(child: Text('Error')),
            data: (items) {
              var filtered = items;
              if (search.isNotEmpty) {
                final q = search.toLowerCase();
                filtered = filtered.where((i) => i.name.toLowerCase().contains(q) || i.category.toLowerCase().contains(q)).toList();
              }
              if (filtered.isEmpty) {
                return const Center(child: Text('No items found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: Theme.of(context).textTheme.titleSmall),
                              Text('${item.category} • \$${item.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Switch(
                          value: item.isAvailable,
                          activeColor: AppColors.secondary,
                          onChanged: (v) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${item.name} ${v ? 'enabled' : 'disabled'}')),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    final demoOrders = [
      ('#A1B2', 'Room 1205', 'Preparing', 3, 48.50),
      ('#C3D4', 'Room 0802', 'Pending', 2, 32.00),
      ('#E5F6', 'Pickup', 'Ready', 1, 18.00),
      ('#G7H8', 'Room 1501', 'Delivered', 4, 76.25),
      ('#I9J0', 'Room 0310', 'Confirmed', 2, 41.00),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: demoOrders.length,
      itemBuilder: (context, index) {
        final (id, location, status, items, total) = demoOrders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(id, style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('$location • $items items • \$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  if (status == 'Pending')
                    _ActBtn('Confirm', AppColors.info, () {}),
                  if (status == 'Confirmed' || status == 'Pending')
                    _ActBtn('Prepare', AppColors.warning, () {}),
                  if (status == 'Preparing')
                    _ActBtn('Ready', AppColors.success, () {}),
                  if (status == 'Ready')
                    _ActBtn('Deliver', AppColors.primary, () {}),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActBtn(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}
