import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/enums.dart';
import '../../../providers/booking_providers.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using guest_1 as demo logged-in guest
    const guestId = 'guest_1';
    final bookingsAsync = ref.watch(guestBookingsProvider(guestId));

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.secondary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Failed to load bookings'),
              ElevatedButton(
                onPressed: () => ref.invalidate(guestBookingsProvider(guestId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (allBookings) {
          final upcoming = allBookings
              .where((b) =>
                  b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.pending ||
                  b.status == BookingStatus.checkedIn)
              .toList();
          final completed = allBookings
              .where((b) => b.status == BookingStatus.checkedOut)
              .toList();
          final cancelled = allBookings
              .where((b) => b.status == BookingStatus.cancelled)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _BookingList(
                bookings: upcoming,
                emptyMessage: 'No upcoming bookings',
                onRefresh: () =>
                    ref.invalidate(guestBookingsProvider(guestId)),
              ),
              _BookingList(
                bookings: completed,
                emptyMessage: 'No completed bookings',
                onRefresh: () =>
                    ref.invalidate(guestBookingsProvider(guestId)),
              ),
              _BookingList(
                bookings: cancelled,
                emptyMessage: 'No cancelled bookings',
                onRefresh: () =>
                    ref.invalidate(guestBookingsProvider(guestId)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final String emptyMessage;
  final VoidCallback onRefresh;

  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_outlined,
                size: 64, color: AppColors.mediumGrey),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Your bookings will appear here',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    final dateFmt = DateFormat('MMM d');

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          return GestureDetector(
            onTap: () => context.push('/guest/bookings/${b.id}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          b.roomName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      _StatusBadge(status: b.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${dateFmt.format(b.checkIn)} – ${dateFmt.format(b.checkOut)} • ${b.numberOfNights} nights',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Code: ${b.bookingCode}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${b.totalPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right,
                          color: AppColors.mediumGrey),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case BookingStatus.confirmed:
      case BookingStatus.checkedIn:
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case BookingStatus.pending:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        break;
      case BookingStatus.cancelled:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        break;
      default:
        bg = AppColors.lightGrey;
        fg = AppColors.darkGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
