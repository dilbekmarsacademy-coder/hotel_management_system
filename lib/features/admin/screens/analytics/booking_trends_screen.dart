import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class BookingTrendsScreen extends ConsumerWidget {
  const BookingTrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = DummyData.bookings;
    final byMonth = <String, int>{};
    for (final b in bookings) {
      final key = DateFormat('MMM yyyy').format(b.createdAt);
      byMonth[key] = (byMonth[key] ?? 0) + 1;
    }
    final byStatus = <BookingStatus, int>{};
    for (final b in bookings) {
      byStatus[b.status] = (byStatus[b.status] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Booking Trends')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Bookings Over Time', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.lightGrey)),
          child: Column(children: byMonth.entries.map((e) {
            final maxV = byMonth.values.fold<int>(0, (a, b) => a > b ? a : b);
            final pct = maxV == 0 ? 0.0 : e.value / maxV;
            return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
              SizedBox(width: 70, child: Text(e.key, style: Theme.of(context).textTheme.bodySmall)),
              Expanded(child: LinearProgressIndicator(value: pct, backgroundColor: AppColors.lightGrey, color: AppColors.info, minHeight: 10, borderRadius: BorderRadius.circular(5))),
              const SizedBox(width: 8),
              Text('${e.value}', style: Theme.of(context).textTheme.labelMedium),
            ]));
          }).toList()),
        ),
        const SizedBox(height: 24),
        Text('By Status', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...byStatus.entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
          child: Row(children: [
            Expanded(child: Text(e.key.displayName, style: Theme.of(context).textTheme.titleSmall)),
            Text('${e.value}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ]),
        )),
      ]),
    );
  }
}
