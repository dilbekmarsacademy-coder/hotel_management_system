import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/booking_providers.dart';

class BookingSuccessScreen extends ConsumerWidget {
  final String? bookingId;

  const BookingSuccessScreen({super.key, this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(bookingFlowProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Booking Confirmed!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your reservation has been successfully confirmed.\nA confirmation email has been sent.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.darkGrey,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 32),

              // QR Code
              if (flow.selectedRoom != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: 'BOOKING-${bookingId ?? 'DEMO'}-${flow.selectedRoom!.roomNumber}',
                        version: QrVersions.auto,
                        size: 140,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Show this QR at check-in',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (flow.selectedRoom != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          flow.selectedRoom!.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          'Total: \$${flow.total.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.secondary),
                        ),
                      ],
                    ],
                  ),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(bookingFlowProvider.notifier).reset();
                    context.go('/guest');
                  },
                  child: const Text('Back to Home'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(bookingFlowProvider.notifier).reset();
                    context.go('/guest');
                  },
                  child: const Text('View My Bookings'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
