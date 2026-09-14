import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class AdminReportsDashboard extends ConsumerWidget {
  const AdminReportsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = DummyData.bookings;
    final payments = DummyData.payments;
    final rooms = DummyData.rooms;
    final guests = DummyData.guests;

    final totalRevenue = payments.where((p) => p.status == PaymentStatus.completed).fold<double>(0, (s, p) => s + p.amount);
    final totalBookings = bookings.length;
    final occupied = rooms.where((r) => r.status == RoomStatus.occupied).length;
    final occupancyRate = rooms.isEmpty ? 0.0 : (occupied / rooms.length) * 100;
    final cancelled = bookings.where((b) => b.status == BookingStatus.cancelled).length;
    final avgBookingValue = totalBookings == 0 ? 0.0 : totalRevenue / totalBookings;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _ReportCard(title: 'Total Revenue', value: '\$${totalRevenue.toStringAsFixed(0)}', icon: Icons.attach_money, color: AppColors.success),
                _ReportCard(title: 'Total Bookings', value: '$totalBookings', icon: Icons.calendar_month, color: AppColors.info),
                _ReportCard(title: 'Occupancy', value: '${occupancyRate.toStringAsFixed(1)}%', icon: Icons.hotel, color: AppColors.secondary),
                _ReportCard(title: 'Guests', value: '${guests.length}', icon: Icons.people, color: AppColors.primary),
                _ReportCard(title: 'Cancellations', value: '$cancelled', icon: Icons.cancel, color: AppColors.error),
                _ReportCard(title: 'Avg Booking', value: '\$${avgBookingValue.toStringAsFixed(0)}', icon: Icons.trending_up, color: AppColors.warning),
              ],
            ),
            const SizedBox(height: 28),
            Text('Detailed Reports', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...[
              ('Revenue Report', Icons.attach_money, 'Daily, weekly, monthly revenue breakdown'),
              ('Booking Report', Icons.calendar_month, 'Booking trends and status distribution'),
              ('Occupancy Report', Icons.hotel, 'Room occupancy rates by floor and type'),
              ('Guest Report', Icons.people, 'Guest demographics and loyalty'),
              ('Restaurant Sales', Icons.restaurant, 'Menu item performance and order stats'),
              ('Staff Performance', Icons.badge, 'Staff activity and task completion'),
              ('Payment Report', Icons.payment, 'Payment methods and success rates'),
              ('Cancellation Report', Icons.cancel_outlined, 'Cancellation reasons and trends'),
              ('Housekeeping Report', Icons.cleaning_services, 'Cleaning efficiency metrics'),
              ('Maintenance Report', Icons.build, 'Repair costs and resolution times'),
            ].map((item) => _ReportTile(title: item.$1, icon: item.$2, subtitle: item.$3)),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _ReportCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _ReportTile({required this.title, required this.icon, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        tileColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.lightGrey)),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening $title...')));
        },
      ),
    );
  }
}
