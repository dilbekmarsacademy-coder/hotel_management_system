import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clear();
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 72, color: AppColors.mediumGrey),
                  const SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Add items from the menu',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Browse Menu'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cartItem.item.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${cartItem.item.price.toStringAsFixed(2)} each',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .updateQuantity(
                                          cartItem.item.id,
                                          cartItem.quantity - 1,
                                        );
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: AppColors.primary,
                                ),
                                Text(
                                  '${cartItem.quantity}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                IconButton(
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .updateQuantity(
                                          cartItem.item.id,
                                          cartItem.quantity + 1,
                                        );
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${cartItem.subtotal.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        _PriceLine(label: 'Subtotal', value: cart.subtotal),
                        _PriceLine(label: 'Tax (8%)', value: cart.tax),
                        _PriceLine(
                            label: 'Service Fee (5%)', value: cart.serviceFee),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Text('Total',
                                style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            Text(
                              '\$${cart.total.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () =>
                                context.push('/guest/restaurant/checkout'),
                            child: const Text('Proceed to Checkout'),
                          ),
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

class _PriceLine extends StatelessWidget {
  final String label;
  final double value;

  const _PriceLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text('\$${value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
