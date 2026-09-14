import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';
import '../../../../providers/booking_providers.dart';

class TodaysArrivalsScreen extends ConsumerWidget {
  const TodaysArrivalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final arrivals = DummyData.bookings.where((b) {
      return b.checkIn.year == now.year && b.checkIn.month == now.month && b.checkIn.day == now.day &&
          (b.status == BookingStatus.confirmed || b.status == BookingStatus.pending);
    }).toList();
    final dateFmt = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: Text("Today's Arrivals (${arrivals.length})")),
      body: arrivals.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.login, size: 64, color: AppColors.mediumGrey),
              const SizedBox(height: 16),
              Text('No arrivals today', style: Theme.of(context).textTheme.headlineSmall),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: arrivals.length,
              itemBuilder: (context, index) {
                final b = arrivals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(b.guestName, style: Theme.of(context).textTheme.titleSmall)),
                      Text(b.bookingCode, style: Theme.of(context).textTheme.bodySmall),
                    ]),
                    const SizedBox(height: 4),
                    Text('${b.roomName} (${b.roomNumber}) • ${b.numberOfGuests} guests • ${b.numberOfNights} nights', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 10),
                    Row(children: [
                      Text('ETA: ${dateFmt.format(b.checkIn)}', style: Theme.of(context).textTheme.labelMedium),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          final updated = b.copyWith(status: BookingStatus.checkedIn, updatedAt: DateTime.now());
                          await ref.read(bookingRepositoryProvider).updateBooking(updated);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${b.guestName} checked in'), backgroundColor: AppColors.success),
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
