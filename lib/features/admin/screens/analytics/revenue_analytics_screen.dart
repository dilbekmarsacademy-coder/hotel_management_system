import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class RevenueAnalyticsScreen extends ConsumerWidget {
  const RevenueAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = DummyData.payments.where((p) => p.status == PaymentStatus.completed).toList();
    final total = payments.fold<double>(0, (s, p) => s + p.amount);
    final bookings = DummyData.bookings.where((b) => b.status != BookingStatus.cancelled);
    final roomRev = bookings.fold<double>(0, (s, b) => s + b.roomPrice * b.numberOfNights);
    final taxRev = bookings.fold<double>(0, (s, b) => s + b.taxes);
    final serviceRev = bookings.fold<double>(0, (s, b) => s + b.serviceFee);

    final byMonth = <String, double>{};
    for (final p in payments) {
      final key = DateFormat('MMM yyyy').format(p.createdAt);
      byMonth[key] = (byMonth[key] ?? 0) + p.amount;
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Revenue Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Text('Total Revenue', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              Text('\$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            _Card('Room', '\$${roomRev.toStringAsFixed(0)}', AppColors.primary),
            const SizedBox(width: 8),
            _Card('Tax', '\$${taxRev.toStringAsFixed(0)}', AppColors.warning),
            const SizedBox(width: 8),
            _Card('Service', '\$${serviceRev.toStringAsFixed(0)}', AppColors.info),
          ]),
          const SizedBox(height: 24),
          Text('Revenue Trend', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.lightGrey)),
            child: Column(children: byMonth.entries.map((e) {
              final maxV = byMonth.values.fold<double>(0, (a, b) => a > b ? a : b);
              final pct = maxV == 0 ? 0.0 : e.value / maxV;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  SizedBox(width: 70, child: Text(e.key, style: Theme.of(context).textTheme.bodySmall)),
                  Expanded(child: LinearProgressIndicator(value: pct, backgroundColor: AppColors.lightGrey, color: AppColors.secondary, minHeight: 10, borderRadius: BorderRadius.circular(5))),
                  const SizedBox(width: 8),
                  Text('\$${e.value.toStringAsFixed(0)}', style: Theme.of(context).textTheme.labelMedium),
                ]),
              );
            }).toList()),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title, value;
  final Color color;
  const _Card(this.title, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(title, style: Theme.of(context).textTheme.labelSmall),
      ]),
    ));
  }
}
