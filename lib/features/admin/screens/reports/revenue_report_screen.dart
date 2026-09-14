import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class RevenueReportScreen extends ConsumerStatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  ConsumerState<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends ConsumerState<RevenueReportScreen> {
  String _period = 'month';

  @override
  Widget build(BuildContext context) {
    final payments = DummyData.payments.where((p) => p.status == PaymentStatus.completed).toList();
    final total = payments.fold<double>(0, (s, p) => s + p.amount);
    final bookings = DummyData.bookings;
    final roomRevenue = bookings.where((b) => b.status != BookingStatus.cancelled).fold<double>(0, (s, b) => s + b.roomPrice * b.numberOfNights);
    final taxTotal = bookings.fold<double>(0, (s, b) => s + b.taxes);
    final avgTransaction = payments.isEmpty ? 0.0 : total / payments.length;

    // Group by day for chart data
    final byDay = <String, double>{};
    for (final p in payments) {
      final key = DateFormat('MMM d').format(p.createdAt);
      byDay[key] = (byDay[key] ?? 0) + p.amount;
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Revenue Report')),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Period selector
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['today', 'week', 'month', 'year'].map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p[0].toUpperCase() + p.substring(1)),
                      selected: _period == p,
                      onSelected: (_) => setState(() => _period = p),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Summary cards
            Row(
              children: [
                _Card('Total Revenue', '\$${total.toStringAsFixed(0)}', AppColors.success),
                const SizedBox(width: 10),
                _Card('Transactions', '${payments.length}', AppColors.info),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Card('Room Revenue', '\$${roomRevenue.toStringAsFixed(0)}', AppColors.primary),
                const SizedBox(width: 10),
                _Card('Avg Transaction', '\$${avgTransaction.toStringAsFixed(0)}', AppColors.secondary),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Card('Taxes Collected', '\$${taxTotal.toStringAsFixed(0)}', AppColors.warning),
                const SizedBox(width: 10),
                _Card('Completed', '${payments.length}', AppColors.success),
              ],
            ),
            const SizedBox(height: 24),

            Text('Revenue by Day', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Column(
                children: byDay.entries.take(10).map((e) {
                  final maxVal = byDay.values.fold<double>(0, (a, b) => a > b ? a : b);
                  final pct = maxVal == 0 ? 0.0 : e.value / maxVal;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(width: 60, child: Text(e.key, style: Theme.of(context).textTheme.bodySmall)),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: AppColors.lightGrey,
                            color: AppColors.secondary,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('\$${e.value.toStringAsFixed(0)}', style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            Text('Payment Methods', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...PaymentMethod.values.map((method) {
              final methodPayments = payments.where((p) => p.method == method).toList();
              final methodTotal = methodPayments.fold<double>(0, (s, p) => s + p.amount);
              if (methodPayments.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(method.displayName, style: Theme.of(context).textTheme.titleSmall)),
                    Text('${methodPayments.length} txns', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 12),
                    Text('\$${methodTotal.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            }),
          ],
        ),
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
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
