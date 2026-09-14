import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class CancellationReportScreen extends ConsumerWidget {
  const CancellationReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = DummyData.bookings;
    final cancelled = bookings.where((b) => b.status == BookingStatus.cancelled).toList();
    final rate = bookings.isEmpty ? 0.0 : (cancelled.length / bookings.length) * 100;
    final lostRevenue = cancelled.fold<double>(0, (s, b) => s + b.totalPrice);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Cancellation Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Text('Cancellation Rate', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('${rate.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.error, fontWeight: FontWeight.w700)),
              Text('${cancelled.length} of ${bookings.length} bookings', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            _Card('Cancelled', '${cancelled.length}', AppColors.error),
            const SizedBox(width: 8),
            _Card('Lost Revenue', '\$${lostRevenue.toStringAsFixed(0)}', AppColors.warning),
          ]),
          const SizedBox(height: 24),
          Text('Cancelled Bookings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (cancelled.isEmpty)
            const Center(child: Text('No cancellations'))
          else
            ...cancelled.map((b) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.guestName, style: Theme.of(context).textTheme.titleSmall),
                Text('${b.roomName} • ${b.bookingCode} • \$${b.totalPrice.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
                if (b.cancellationReason != null)
                  Text('Reason: ${b.cancellationReason}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error)),
              ]),
            )),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ]),
    ));
  }
}
