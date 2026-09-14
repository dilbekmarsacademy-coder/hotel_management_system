import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class BookingCalendarScreen extends ConsumerStatefulWidget {
  const BookingCalendarScreen({super.key});

  @override
  ConsumerState<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends ConsumerState<BookingCalendarScreen> {
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final bookings = DummyData.bookings;
    final dateFmt = DateFormat('EEEE, MMM d');
    final dayBookings = bookings.where((b) {
      return (b.checkIn.isBefore(_selected.add(const Duration(days: 1))) && b.checkOut.isAfter(_selected));
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Booking Calendar')),
      body: Column(children: [
        CalendarDatePicker(
          initialDate: _selected,
          firstDate: DateTime.now().subtract(const Duration(days: 90)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          onDateChanged: (d) => setState(() => _selected = d),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Text(dateFmt.format(_selected), style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text('${dayBookings.length} bookings', style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: dayBookings.isEmpty
              ? Center(child: Text('No bookings on this date', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mediumGrey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dayBookings.length,
                  itemBuilder: (context, index) {
                    final b = dayBookings[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
                      child: Row(children: [
                        Container(
                          width: 4, height: 40,
                          decoration: BoxDecoration(
                            color: b.status == BookingStatus.checkedIn ? AppColors.success : AppColors.info,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(b.guestName, style: Theme.of(context).textTheme.titleSmall),
                          Text('${b.roomNumber} • ${b.status.displayName}', style: Theme.of(context).textTheme.bodySmall),
                        ])),
                        Text('\$${b.totalPrice.toStringAsFixed(0)}', style: Theme.of(context).textTheme.labelMedium),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
