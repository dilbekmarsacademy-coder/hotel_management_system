import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _roomCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _deliveryType = 'room';
  bool _processing = false;

  @override
  void dispose() {
    _roomCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_deliveryType == 'room' && _roomCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your room number')),
      );
      return;
    }

    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final orderId = const Uuid().v4().substring(0, 8).toUpperCase();
    ref.read(cartProvider.notifier).clear();
    setState(() => _processing = false);

    context.go('/guest/restaurant/order-confirmation', extra: orderId);
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Cart is empty')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Delivery', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _OptionTile(
            title: 'Deliver to Room',
            subtitle: 'We will bring it to your room',
            selected: _deliveryType == 'room',
            onTap: () => setState(() => _deliveryType = 'room'),
          ),
          _OptionTile(
            title: 'Pick up at Restaurant',
            subtitle: 'Collect from The Grand Restaurant',
            selected: _deliveryType == 'pickup',
            onTap: () => setState(() => _deliveryType = 'pickup'),
          ),
          if (_deliveryType == 'room') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _roomCtrl,
              decoration: const InputDecoration(
                labelText: 'Room Number',
                prefixIcon: Icon(Icons.meeting_room_outlined),
                hintText: 'e.g. 1205',
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('Special Instructions',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Allergies, preferences, etc.',
            ),
          ),
          const SizedBox(height: 24),
          Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Column(
              children: [
                ...cart.items.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text('${c.quantity}x ${c.item.name}'),
                          const Spacer(),
                          Text('\$${c.subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                    )),
                const Divider(height: 20),
                Row(
                  children: [
                    Text('Total',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      '\$${cart.total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _processing ? null : _placeOrder,
              child: _processing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text('Place Order • \$${cart.total.toStringAsFixed(2)}'),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.lightGrey,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.secondary : AppColors.mediumGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
