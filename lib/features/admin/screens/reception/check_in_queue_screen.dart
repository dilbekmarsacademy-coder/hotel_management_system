import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';
import '../../../../providers/booking_providers.dart';

class CheckInQueueScreen extends ConsumerWidget {
  const CheckInQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final queue = DummyData.bookings.where((b) {
      return b.checkIn.year == now.year &&
          b.checkIn.month == now.month &&
          b.checkIn.day == now.day &&
          (b.status == BookingStatus.confirmed || b.status == BookingStatus.pending);
    }).toList();
    final timeFmt = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: Text('Check-in Queue (${queue.length})')),
      body: queue.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.login, size: 64, color: AppColors.mediumGrey),
              const SizedBox(height: 16),
              Text('No guests waiting for check-in', style: Theme.of(context).textTheme.headlineSmall),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: queue.length,
              itemBuilder: (context, index) {
                final b = queue[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.lightGrey)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(radius: 20, backgroundColor: AppColors.primary, child: Text(b.guestName[0], style: const TextStyle(color: Colors.white))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b.guestName, style: Theme.of(context).textTheme.titleSmall),
                        Text('${b.bookingCode} • ${b.numberOfGuests} guests', style: Theme.of(context).textTheme.bodySmall),
                      ])),
                      Text(timeFmt.format(b.checkIn), style: Theme.of(context).textTheme.labelMedium),
                    ]),
                    const SizedBox(height: 10),
                    Text('${b.roomName} (${b.roomNumber}) • ${b.numberOfNights} nights • \$${b.totalPrice.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 10),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: b.paymentStatus == PaymentStatus.completed ? AppColors.successLight : AppColors.warningLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(b.paymentStatus.displayName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: b.paymentStatus == PaymentStatus.completed ? AppColors.success : AppColors.warning)),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          final updated = b.copyWith(status: BookingStatus.checkedIn, updatedAt: DateTime.now());
                          await ref.read(bookingRepositoryProvider).updateBooking(updated);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${b.guestName} checked in to Room ${b.roomNumber}'), backgroundColor: AppColors.success),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.info.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                          child: const Text('Check In', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.info, fontSize: 13)),
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
