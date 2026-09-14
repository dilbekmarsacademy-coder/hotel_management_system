import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Order Received', true, '10:32 AM'),
      ('Confirmed', true, '10:33 AM'),
      ('Preparing', true, '10:35 AM'),
      ('Ready', false, null),
      ('Delivering', false, null),
      ('Delivered', false, null),
    ];

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Order Tracking')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Order #$orderId',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Preparing',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estimated time: 25–35 min',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withOpacity(0.85),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Status Timeline',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final (label, done, time) = steps[i];
            final isLast = i == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? AppColors.success : AppColors.lightGrey,
                      ),
                      child: Icon(
                        done ? Icons.check : Icons.circle,
                        size: done ? 16 : 10,
                        color: done ? Colors.white : AppColors.mediumGrey,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: done
                            ? AppColors.success
                            : AppColors.lightGrey,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: done
                                      ? AppColors.primary
                                      : AppColors.mediumGrey,
                                ),
                          ),
                        ),
                        if (time != null)
                          Text(
                            time,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/guest'),
              child: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }
}
