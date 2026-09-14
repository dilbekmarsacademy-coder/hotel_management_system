import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/booking_providers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _method = 'creditCard';
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_method == 'creditCard') {
      if (_cardNumberCtrl.text.replaceAll(' ', '').length < 16 ||
          _expiryCtrl.text.length < 4 ||
          _cvvCtrl.text.length < 3 ||
          _nameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all card details')),
        );
        return;
      }
    }

    setState(() => _processing = true);
    ref.read(bookingFlowProvider.notifier).setPaymentMethod(_method);

    // Simulate payment processing
    await Future.delayed(const Duration(milliseconds: 1800));

    final booking =
        await ref.read(bookingFlowProvider.notifier).submitBooking();

    if (!mounted) return;
    setState(() => _processing = false);

    if (booking != null) {
      context.go('/guest/booking/success', extra: booking.id);
    } else {
      final error = ref.read(bookingFlowProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Payment failed. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(bookingFlowProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Total Amount',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${flow.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Text('Payment Method',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          _MethodTile(
            icon: Icons.credit_card,
            title: 'Credit / Debit Card',
            selected: _method == 'creditCard',
            onTap: () => setState(() => _method = 'creditCard'),
          ),
          _MethodTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Digital Wallet',
            selected: _method == 'wallet',
            onTap: () => setState(() => _method = 'wallet'),
          ),
          _MethodTile(
            icon: Icons.money,
            title: 'Pay at Hotel',
            selected: _method == 'cash',
            onTap: () => setState(() => _method = 'cash'),
          ),

          if (_method == 'creditCard') ...[
            const SizedBox(height: 24),
            Text('Card Details',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Cardholder Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cardNumberCtrl,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                prefixIcon: Icon(Icons.credit_card),
                hintText: '4242 4242 4242 4242',
              ),
              keyboardType: TextInputType.number,
              maxLength: 19,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'MM/YY',
                      hintText: '12/28',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cvvCtrl,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Test card: 4242 4242 4242 4242 • Any future expiry • Any CVV',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
            ),
          ],

          if (_method == 'wallet') ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You will be redirected to complete wallet payment after confirmation.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_method == 'cash') ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Payment will be collected at the hotel during check-in. Your booking will be held for 24 hours.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],

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
              onPressed: _processing ? null : _pay,
              child: _processing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _method == 'cash'
                          ? 'Confirm Booking'
                          : 'Pay \$${flow.total.toStringAsFixed(2)}',
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.title,
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
            Icon(icon,
                color: selected ? AppColors.secondary : AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleSmall),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}
