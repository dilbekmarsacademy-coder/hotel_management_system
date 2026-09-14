import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/menu_item_model.dart';
import '../../../../providers/cart_provider.dart';

class MenuItemDetailsScreen extends ConsumerStatefulWidget {
  final MenuItemModel item;
  const MenuItemDetailsScreen({super.key, required this.item});

  @override
  ConsumerState<MenuItemDetailsScreen> createState() => _MenuItemDetailsScreenState();
}

class _MenuItemDetailsScreenState extends ConsumerState<MenuItemDetailsScreen> {
  int _qty = 1;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(color: AppColors.primary),
              title: Text(item.name),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.darkGrey,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
                  ),
                  if (item.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Ingredients: ${item.ingredients.join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.darkGrey,
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (item.isVegetarian)
                        Chip(
                          label: const Text('Vegetarian'),
                          backgroundColor: AppColors.successLight,
                          labelStyle: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      if (item.isSpicy)
                        Chip(
                          label: const Text('Spicy'),
                          backgroundColor: AppColors.warningLight,
                          labelStyle: const TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                          ),
                        ),
                      Chip(
                        label: Text('${item.preparationTimeMinutes} min'),
                        backgroundColor: AppColors.lightGrey,
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$_qty',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () => setState(() => _qty++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Special instructions',
                      hintText: 'e.g. no onions',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: item.isAvailable
                          ? () {
                              ref.read(cartProvider.notifier).addItem(
                                    item,
                                    quantity: _qty,
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added $_qty × ${item.name} to cart',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(
                        'Add to Cart • \$${(item.price * _qty).toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
