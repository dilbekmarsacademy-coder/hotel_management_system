import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/enums.dart';
import '../../../providers/booking_providers.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingRepo = ref.watch(bookingRepositoryProvider);

    return FutureBuilder(
      future: bookingRepo.getBookingById(bookingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final booking = snapshot.data;
        if (booking == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Booking not found')),
          );
        }

        final dateFmt = DateFormat('EEE, MMM d, yyyy');

        return Scaffold(
          backgroundColor: AppColors.offWhite,
          appBar: AppBar(
            title: Text(booking.bookingCode),
            actions: [
              if (booking.status == BookingStatus.confirmed ||
                  booking.status == BookingStatus.pending)
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  onPressed: () => _showCancelDialog(context, ref),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Row(
                  children: [
                    Text('Status', style: Theme.of(context).textTheme.titleSmall),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        booking.status.displayName,
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Room
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.roomName,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('Room ${booking.roomNumber}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Dates
              _Card(
                child: Column(
                  children: [
                    _InfoRow('Check-in', dateFmt.format(booking.checkIn)),
                    const Divider(height: 20),
                    _InfoRow('Check-out', dateFmt.format(booking.checkOut)),
                    const Divider(height: 20),
                    _InfoRow('Nights', '${booking.numberOfNights}'),
                    const Divider(height: 20),
                    _InfoRow('Guests', '${booking.numberOfGuests}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Price
              _Card(
                child: Column(
                  children: [
                    _InfoRow('Room',
                        '\$${booking.roomPrice.toStringAsFixed(2)} × ${booking.numberOfNights}'),
                    _InfoRow('Taxes', '\$${booking.taxes.toStringAsFixed(2)}'),
                    _InfoRow(
                        'Service Fee', '\$${booking.serviceFee.toStringAsFixed(2)}'),
                    if (booking.discount > 0)
                      _InfoRow('Discount',
                          '-\$${booking.discount.toStringAsFixed(2)}'),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Text('Total',
                            style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        Text(
                          '\$${booking.totalPrice.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // QR
              if (booking.status == BookingStatus.confirmed ||
                  booking.status == BookingStatus.checkedIn)
                _Card(
                  child: Column(
                    children: [
                      QrImageView(
                        data: 'BOOKING-${booking.bookingCode}',
                        version: QrVersions.auto,
                        size: 140,
                      ),
                      const SizedBox(height: 8),
                      Text('Show at check-in',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              if (booking.status == BookingStatus.confirmed ||
                  booking.status == BookingStatus.pending)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    onPressed: () => _showCancelDialog(context, ref),
                    child: const Text('Cancel Booking'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref
                  .read(bookingRepositoryProvider)
                  .cancelBooking(bookingId, 'Cancelled by guest');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Booking cancelled'
                        : 'Failed to cancel booking'),
                    backgroundColor:
                        ok ? AppColors.success : AppColors.error,
                  ),
                );
                if (ok) context.pop();
              }
            },
            child: const Text('Cancel Booking',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
