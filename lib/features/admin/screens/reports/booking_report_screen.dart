import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class BookingReportScreen extends ConsumerWidget {
  const BookingReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = DummyData.bookings;
    final confirmed = bookings.where((b) => b.status == BookingStatus.confirmed).length;
    final checkedIn = bookings.where((b) => b.status == BookingStatus.checkedIn).length;
    final checkedOut = bookings.where((b) => b.status == BookingStatus.checkedOut).length;
    final cancelled = bookings.where((b) => b.status == BookingStatus.cancelled).length;
    final pending = bookings.where((b) => b.status == BookingStatus.pending).length;
    final totalNights = bookings.fold<int>(0, (s, b) => s + b.numberOfNights);
    final avgNights = bookings.isEmpty ? 0.0 : totalNights / bookings.length;
    final totalRevenue = bookings.where((b) => b.status != BookingStatus.cancelled).fold<double>(0, (s, b) => s + b.totalPrice);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Booking Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            _Card('Total', '${bookings.length}', AppColors.primary),
            const SizedBox(width: 8),
            _Card('Confirmed', '$confirmed', AppColors.success),
            const SizedBox(width: 8),
            _Card('Pending', '$pending', AppColors.warning),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _Card('Checked In', '$checkedIn', AppColors.info),
            const SizedBox(width: 8),
            _Card('Checked Out', '$checkedOut', AppColors.darkGrey),
            const SizedBox(width: 8),
            _Card('Cancelled', '$cancelled', AppColors.error),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _Card('Total Nights', '$totalNights', AppColors.secondary),
            const SizedBox(width: 8),
            _Card('Avg Nights', avgNights.toStringAsFixed(1), AppColors.primary),
            const SizedBox(width: 8),
            _Card('Revenue', '\$${totalRevenue.toStringAsFixed(0)}', AppColors.success),
          ]),
          const SizedBox(height: 24),
          Text('Status Distribution', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...BookingStatus.values.map((s) {
            final count = bookings.where((b) => b.status == s).length;
            final pct = bookings.isEmpty ? 0.0 : count / bookings.length;
            return _BarRow(label: s.displayName, value: count, pct: pct);
          }),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(title, style: Theme.of(context).textTheme.labelSmall),
        ]),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int value;
  final double pct;
  const _BarRow({required this.label, required this.value, required this.pct});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 90, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        Expanded(child: LinearProgressIndicator(value: pct, backgroundColor: AppColors.lightGrey, color: AppColors.secondary, minHeight: 8, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text('$value', style: Theme.of(context).textTheme.labelMedium),
      ]),
    );
  }
}
