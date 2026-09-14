import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';
import '../../../../providers/booking_providers.dart';

class ReceptionDashboardScreen extends ConsumerWidget {
  const ReceptionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = DummyData.bookings;
    final now = DateTime.now();
    final dateFmt = DateFormat('MMM d');

    final arrivals = bookings.where((b) {
      return b.checkIn.year == now.year &&
          b.checkIn.month == now.month &&
          b.checkIn.day == now.day &&
          (b.status == BookingStatus.confirmed || b.status == BookingStatus.pending);
    }).toList();

    final departures = bookings.where((b) {
      return b.checkOut.year == now.year &&
          b.checkOut.month == now.month &&
          b.checkOut.day == now.day &&
          b.status == BookingStatus.checkedIn;
    }).toList();

    final inHouse = bookings.where((b) => b.status == BookingStatus.checkedIn).toList();
    final pending = bookings.where((b) => b.status == BookingStatus.pending).toList();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Reception')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _Kpi('Arrivals', '${arrivals.length}', Icons.login, AppColors.info),
              const SizedBox(width: 10),
              _Kpi('Departures', '${departures.length}', Icons.logout, AppColors.warning),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Kpi('In-House', '${inHouse.length}', Icons.hotel, AppColors.success),
              const SizedBox(width: 10),
              _Kpi('Pending', '${pending.length}', Icons.schedule, AppColors.primary),
            ],
          ),
          const SizedBox(height: 24),

          Text("Today's Arrivals", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (arrivals.isEmpty)
            _EmptyBox('No arrivals today')
          else
            ...arrivals.map((b) => _BookingTile(
                  name: b.guestName,
                  detail: '${b.roomName} • ${b.bookingCode}',
                  trailing: 'Check-in',
                  color: AppColors.info,
                  onTap: () async {
                    final updated = b.copyWith(status: BookingStatus.checkedIn, updatedAt: DateTime.now());
                    await ref.read(bookingRepositoryProvider).updateBooking(updated);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${b.guestName} checked in'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                )),

          const SizedBox(height: 24),
          Text("Today's Departures", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (departures.isEmpty)
            _EmptyBox('No departures today')
          else
            ...departures.map((b) => _BookingTile(
                  name: b.guestName,
                  detail: '${b.roomName} • Checkout ${dateFmt.format(b.checkOut)}',
                  trailing: 'Check-out',
                  color: AppColors.warning,
                  onTap: () async {
                    final updated = b.copyWith(status: BookingStatus.checkedOut, updatedAt: DateTime.now());
                    await ref.read(bookingRepositoryProvider).updateBooking(updated);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${b.guestName} checked out'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                )),

          const SizedBox(height: 24),
          Text('Currently In-House', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (inHouse.isEmpty)
            _EmptyBox('No guests in-house')
          else
            ...inHouse.take(10).map((b) => _BookingTile(
                  name: b.guestName,
                  detail: '${b.roomName} • Until ${dateFmt.format(b.checkOut)}',
                  trailing: b.roomNumber,
                  color: AppColors.success,
                  onTap: () => context.push('/admin/reception/check-out'),
                )),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Kpi(this.label, this.value, this.icon, this.color);

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
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final String name, detail, trailing;
  final Color color;
  final VoidCallback onTap;

  const _BookingTile({
    required this.name,
    required this.detail,
    required this.trailing,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleSmall),
                Text(detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(trailing, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String message;
  const _EmptyBox(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Center(child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mediumGrey))),
    );
  }
}
