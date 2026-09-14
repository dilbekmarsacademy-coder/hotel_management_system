import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';
import '../../../../providers/booking_providers.dart';

class TodaysDeparturesScreen extends ConsumerWidget {
  const TodaysDeparturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final departures = DummyData.bookings.where((b) {
      return b.checkOut.year == now.year && b.checkOut.month == now.month && b.checkOut.day == now.day &&
          b.status == BookingStatus.checkedIn;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: Text("Today's Departures (${departures.length})")),
      body: departures.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.logout, size: 64, color: AppColors.mediumGrey),
              const SizedBox(height: 16),
              Text('No departures today', style: Theme.of(context).textTheme.headlineSmall),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: departures.length,
              itemBuilder: (context, index) {
                final b = departures[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(b.guestName, style: Theme.of(context).textTheme.titleSmall)),
                      Text('Room ${b.roomNumber}', style: Theme.of(context).textTheme.bodySmall),
                    ]),
                    const SizedBox(height: 4),
                    Text('${b.roomName} • \$${b.totalPrice.toStringAsFixed(0)} • ${b.paymentStatus.displayName}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 10),
                    Row(children: [
                      if (b.paymentStatus != PaymentStatus.completed)
                        Text('Payment pending', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.warning)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          final updated = b.copyWith(status: BookingStatus.checkedOut, updatedAt: DateTime.now());
                          await ref.read(bookingRepositoryProvider).updateBooking(updated);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${b.guestName} checked out'), backgroundColor: AppColors.success),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                          child: const Text('Check Out', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.warning, fontSize: 13)),
                        ),
                      ),
                    ]),
                  ]),
                );
              },
            ),
    );
  }
}
