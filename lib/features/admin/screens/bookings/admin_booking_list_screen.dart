import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/models/enums.dart';
import '../../../../providers/booking_providers.dart';

final allBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  return ref.watch(bookingRepositoryProvider).getAllBookings();
});

class AdminBookingListScreen extends ConsumerStatefulWidget {
  const AdminBookingListScreen({super.key});

  @override
  ConsumerState<AdminBookingListScreen> createState() => _AdminBookingListScreenState();
}

class _AdminBookingListScreenState extends ConsumerState<AdminBookingListScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  BookingStatus? _statusFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(allBookingsProvider);
    final dateFmt = DateFormat('MMM d');

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Booking Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create booking flow')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by guest, code, room...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      })
                    : null,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _statusFilter == null,
                    onSelected: (_) => setState(() => _statusFilter = null),
                  ),
                ),
                ...BookingStatus.values.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(s.displayName),
                        selected: _statusFilter == s,
                        onSelected: (_) => setState(() => _statusFilter = s),
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: bookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    const Text('Failed to load bookings'),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(allBookingsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (bookings) {
                var filtered = bookings;
                if (_search.isNotEmpty) {
                  final q = _search.toLowerCase();
                  filtered = filtered.where((b) =>
                      b.guestName.toLowerCase().contains(q) ||
                      b.bookingCode.toLowerCase().contains(q) ||
                      b.roomName.toLowerCase().contains(q) ||
                      b.roomNumber.toLowerCase().contains(q)).toList();
                }
                if (_statusFilter != null) {
                  filtered = filtered.where((b) => b.status == _statusFilter).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 64, color: AppColors.mediumGrey),
                        const SizedBox(height: 16),
                        Text('No bookings found', style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(allBookingsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final b = filtered[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(b.guestName, style: Theme.of(context).textTheme.titleSmall),
                                ),
                                _StatusChip(status: b.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('${b.roomName} • ${b.bookingCode}', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            Text(
                              '${dateFmt.format(b.checkIn)} – ${dateFmt.format(b.checkOut)} • ${b.numberOfNights}n • \$${b.totalPrice.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (b.status == BookingStatus.pending)
                                  _ActionChip(label: 'Confirm', color: AppColors.success, onTap: () => _updateStatus(b, BookingStatus.confirmed)),
                                if (b.status == BookingStatus.confirmed)
                                  _ActionChip(label: 'Check-in', color: AppColors.info, onTap: () => _updateStatus(b, BookingStatus.checkedIn)),
                                if (b.status == BookingStatus.checkedIn)
                                  _ActionChip(label: 'Check-out', color: AppColors.primary, onTap: () => _updateStatus(b, BookingStatus.checkedOut)),
                                if (b.status != BookingStatus.cancelled && b.status != BookingStatus.checkedOut)
                                  _ActionChip(label: 'Cancel', color: AppColors.error, onTap: () => _cancelBooking(b)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BookingModel booking, BookingStatus status) async {
    final updated = booking.copyWith(status: status, updatedAt: DateTime.now());
    await ref.read(bookingRepositoryProvider).updateBooking(updated);
    ref.invalidate(allBookingsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking ${status.displayName}'), backgroundColor: AppColors.success),
      );
    }
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: Text('Cancel booking ${booking.bookingCode} for ${booking.guestName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(bookingRepositoryProvider).cancelBooking(booking.id, 'Cancelled by admin');
      ref.invalidate(allBookingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled'), backgroundColor: AppColors.success),
        );
      }
    }
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case BookingStatus.confirmed:
      case BookingStatus.checkedIn:
        bg = AppColors.successLight; fg = AppColors.success;
      case BookingStatus.pending:
        bg = AppColors.warningLight; fg = AppColors.warning;
      case BookingStatus.cancelled:
        bg = AppColors.errorLight; fg = AppColors.error;
      default:
        bg = AppColors.lightGrey; fg = AppColors.darkGrey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.displayName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionChip({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}
