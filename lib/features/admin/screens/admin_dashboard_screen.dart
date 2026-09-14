import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/dummy_data/dummy_data.dart';
import '../../../data/models/enums.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = DummyData.rooms;
    final bookings = DummyData.bookings;
    final guests = DummyData.guests;
    final staff = DummyData.staff;
    final payments = DummyData.payments;

    final availableRooms =
        rooms.where((r) => r.status == RoomStatus.available).length;
    final occupiedRooms =
        rooms.where((r) => r.status == RoomStatus.occupied).length;
    final cleaningRooms =
        rooms.where((r) => r.status == RoomStatus.cleaning).length;
    final maintenanceRooms =
        rooms.where((r) => r.status == RoomStatus.maintenance).length;

    final todayBookings = bookings
        .where((b) =>
            b.checkIn.day == DateTime.now().day &&
            b.status != BookingStatus.cancelled)
        .length;

    final totalRevenue = payments
        .where((p) => p.status == PaymentStatus.completed)
        .fold<double>(0, (sum, p) => sum + p.amount);

    final pendingPayments =
        payments.where((p) => p.status == PaymentStatus.pending).length;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              AppConstants.hotelName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI Cards
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _KpiCard(
                    title: 'Total Revenue',
                    value: '\$${totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: AppColors.success,
                  ),
                  _KpiCard(
                    title: 'Today\'s Bookings',
                    value: '$todayBookings',
                    icon: Icons.calendar_today,
                    color: AppColors.info,
                  ),
                  _KpiCard(
                    title: 'Available Rooms',
                    value: '$availableRooms',
                    icon: Icons.meeting_room,
                    color: AppColors.available,
                  ),
                  _KpiCard(
                    title: 'Occupied Rooms',
                    value: '$occupiedRooms',
                    icon: Icons.hotel,
                    color: AppColors.occupied,
                  ),
                  _KpiCard(
                    title: 'Cleaning',
                    value: '$cleaningRooms',
                    icon: Icons.cleaning_services,
                    color: AppColors.cleaning,
                  ),
                  _KpiCard(
                    title: 'Maintenance',
                    value: '$maintenanceRooms',
                    icon: Icons.build,
                    color: AppColors.maintenance,
                  ),
                  _KpiCard(
                    title: 'Total Guests',
                    value: '${guests.length}',
                    icon: Icons.people,
                    color: AppColors.primary,
                  ),
                  _KpiCard(
                    title: 'Pending Payments',
                    value: '$pendingPayments',
                    icon: Icons.pending_actions,
                    color: AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Bookings
              Text(
                'Recent Bookings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              ...bookings.take(5).map((booking) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.hotel, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.guestName,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '${booking.roomName} • ${booking.bookingCode}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${booking.totalPrice.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          _StatusChip(status: booking.status.displayName),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Staff Summary
              Text(
                'Staff Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: staff.length,
                  itemBuilder: (context, index) {
                    final s = staff[index];
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              s.firstName[0],
                              style: const TextStyle(color: AppColors.white),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            s.fullName,
                            style: Theme.of(context).textTheme.labelLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            s.position.displayName,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.darkGrey,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'confirmed':
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case 'checked in':
        bg = AppColors.infoLight;
        fg = AppColors.info;
        break;
      case 'pending':
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        break;
      case 'cancelled':
        bg = AppColors.errorLight;
        fg = AppColors.error;
        break;
      default:
        bg = AppColors.lightGrey;
        fg = AppColors.darkGrey;
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
