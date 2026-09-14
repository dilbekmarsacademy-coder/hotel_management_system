import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = DummyData.payments.where((p) => p.status == PaymentStatus.completed);
    final revenue = payments.fold<double>(0, (s, p) => s + p.amount);
    final rooms = DummyData.rooms;
    final occupied = rooms.where((r) => r.status == RoomStatus.occupied).length;
    final occupancy = rooms.isEmpty ? 0.0 : (occupied / rooms.length) * 100;
    final bookings = DummyData.bookings.length;
    final guests = DummyData.guests.length;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            _Kpi('Revenue', '\$${revenue.toStringAsFixed(0)}', Icons.attach_money, AppColors.success),
            const SizedBox(width: 10),
            _Kpi('Occupancy', '${occupancy.toStringAsFixed(0)}%', Icons.hotel, AppColors.secondary),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _Kpi('Bookings', '$bookings', Icons.calendar_month, AppColors.info),
            const SizedBox(width: 10),
            _Kpi('Guests', '$guests', Icons.people, AppColors.primary),
          ]),
          const SizedBox(height: 24),
          Text('Analytics Modules', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...[
            ('Revenue Analytics', Icons.trending_up, '/admin/analytics/revenue'),
            ('Occupancy Analytics', Icons.hotel, '/admin/analytics/occupancy'),
            ('Booking Trends', Icons.show_chart, '/admin/analytics/bookings'),
            ('Guest Analytics', Icons.people, '/admin/analytics/guests'),
            ('Room Analytics', Icons.meeting_room, '/admin/analytics/rooms'),
            ('Restaurant Analytics', Icons.restaurant, '/admin/analytics/restaurant'),
            ('Payment Analytics', Icons.payment, '/admin/analytics/payments'),
            ('Staff Analytics', Icons.badge, '/admin/analytics/staff'),
          ].map((item) => _NavTile(title: item.$1, icon: item.$2, route: item.$3)),
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
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.lightGrey)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ]),
    ));
  }
}

class _NavTile extends StatelessWidget {
  final String title, route;
  final IconData icon;
  const _NavTile({required this.title, required this.icon, required this.route});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        tileColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.lightGrey)),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push(route);
        },
      ),
    );
  }
}
