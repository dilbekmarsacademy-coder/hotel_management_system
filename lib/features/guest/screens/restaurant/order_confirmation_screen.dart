import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;

  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    size: 64, color: AppColors.success),
              ),
              const SizedBox(height: 28),
              Text(
                'Order Placed!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your order has been received and is being prepared.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.darkGrey,
                    ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Column(
                  children: [
                    Text('Order ID',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      '#$orderId',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    const _StatusStep(label: 'Order Received', done: true),
                    const _StatusStep(label: 'Confirmed', done: true),
                    const _StatusStep(label: 'Preparing', done: false, active: true),
                    const _StatusStep(label: 'Ready', done: false),
                    const _StatusStep(label: 'Delivered', done: false),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      context.push('/guest/restaurant/order-tracking', extra: orderId),
                  child: const Text('Track Order'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.go('/guest'),
                  child: const Text('Back to Home'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;

  const _StatusStep({
    required this.label,
    this.done = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            done
                ? Icons.check_circle
                : active
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
            size: 22,
            color: done || active ? AppColors.success : AppColors.mediumGrey,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: done || active ? AppColors.primary : AppColors.mediumGrey,
                ),
          ),
        ],
      ),
    );
  }
}
