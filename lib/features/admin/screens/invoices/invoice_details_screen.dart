import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/booking_model.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final BookingModel booking;
  const InvoiceDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    final roomCharges = booking.roomPrice * booking.numberOfNights;
    final grandTotal = booking.totalPrice;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: Text('Invoice INV-${booking.bookingCode}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INVOICE',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'INV-${booking.bookingCode}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Date: ${dateFmt.format(booking.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 24),
                Text('Bill To', style: Theme.of(context).textTheme.labelMedium),
                Text(
                  booking.guestName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  booking.guestEmail,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 24),
                _Line(
                  'Room (${booking.roomName})',
                  '${booking.numberOfNights} nights × \$${booking.roomPrice.toStringAsFixed(0)}',
                  '\$${roomCharges.toStringAsFixed(2)}',
                ),
                _Line(
                  'Service Fee',
                  '',
                  '\$${booking.serviceFee.toStringAsFixed(2)}',
                ),
                _Line(
                  'Taxes',
                  '',
                  '\$${booking.taxes.toStringAsFixed(2)}',
                ),
                if (booking.discount > 0)
                  _Line(
                    'Discount',
                    '',
                    '-\$${booking.discount.toStringAsFixed(2)}',
                  ),
                const Divider(height: 24),
                Row(
                  children: [
                    Text(
                      'Grand Total',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${grandTotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment: ${booking.paymentStatus.displayName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invoice downloaded'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String detail;
  final String amount;

  const _Line(this.label, this.detail, this.amount);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                if (detail.isNotEmpty) Text(detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(amount, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
