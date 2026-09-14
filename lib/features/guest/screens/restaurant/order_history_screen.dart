import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, HH:mm');
    final orders = [
      ('#A1B2C3', 'Room 1205', 'Delivered', 3, 48.50, DateTime.now().subtract(const Duration(hours: 5))),
      ('#D4E5F6', 'Room 0802', 'Delivered', 2, 32.00, DateTime.now().subtract(const Duration(days: 1))),
      ('#G7H8I9', 'Pickup', 'Cancelled', 1, 18.00, DateTime.now().subtract(const Duration(days: 2))),
      ('#J0K1L2', 'Room 1501', 'Delivered', 4, 76.25, DateTime.now().subtract(const Duration(days: 3))),
      ('#M3N4O5', 'Room 0310', 'Delivered', 2, 41.00, DateTime.now().subtract(const Duration(days: 5))),
    ];

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Order History')),
      body: orders.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.mediumGrey),
              const SizedBox(height: 16),
              Text('No past orders', style: Theme.of(context).textTheme.headlineSmall),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final (id, location, status, items, total, date) = orders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(id, style: Theme.of(context).textTheme.titleSmall),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'Delivered' ? AppColors.successLight : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: status == 'Delivered' ? AppColors.success : AppColors.error)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text('$location • $items items • ${dateFmt.format(date)}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text('\$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      if (status == 'Delivered')
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Reordering $id...'), backgroundColor: AppColors.success),
                            );
                          },
                          child: const Text('Reorder'),
                        ),
                    ]),
                  ]),
                );
              },
            ),
    );
  }
}
