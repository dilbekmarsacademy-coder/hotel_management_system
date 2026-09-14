import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';
import '../../../../providers/booking_providers.dart';

class CheckOutQueueScreen extends ConsumerWidget {
  const CheckOutQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final queue = DummyData.bookings.where((b) {
      return b.checkOut.year == now.year &&
          b.checkOut.month == now.month &&
          b.checkOut.day == now.day &&
          b.status == BookingStatus.checkedIn;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: Text('Check-out Queue (${queue.length})')),
      body: queue.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.logout, size: 64, color: AppColors.mediumGrey),
              const SizedBox(height: 16),
              Text('No departures pending', style: Theme.of(context).textTheme.headlineSmall),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: queue.length,
              itemBuilder: (context, index) {
                final b = queue[index];
                final hasOutstanding = b.paymentStatus != PaymentStatus.completed;
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
                        Text('Room ${b.roomNumber} • ${b.roomName}', style: Theme.of(context).textTheme.bodySmall),
                      ])),
                      Text('\$${b.totalPrice.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 10),
                    if (hasOutstanding)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(20)),
                        child: const Text('Outstanding payment', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning)),
                      ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          final updated = b.copyWith(status: BookingStatus.checkedOut, updatedAt: DateTime.now());
                          await ref.read(bookingRepositoryProvider).updateBooking(updated);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${b.guestName} checked out from Room ${b.roomNumber}'), backgroundColor: AppColors.success),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                          child: const Text('Check Out', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.warning, fontSize: 13)),
                        ),
                      ),
                    ),
                  ]),
                );
              },
            ),
    );
  }
}
