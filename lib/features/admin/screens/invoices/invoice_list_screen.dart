import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class InvoiceListScreen extends ConsumerWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = DummyData.bookings.where((b) => b.status != BookingStatus.cancelled).toList();
    final dateFmt = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Invoices')),
      body: bookings.isEmpty
          ? const Center(child: Text('No invoices'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];
                final invNum = 'INV-${b.bookingCode}';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(invNum, style: Theme.of(context).textTheme.titleSmall)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: b.paymentStatus == PaymentStatus.completed ? AppColors.successLight : AppColors.warningLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          b.paymentStatus.displayName,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: b.paymentStatus == PaymentStatus.completed ? AppColors.success : AppColors.warning),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text('${b.guestName} • ${b.roomName}', style: Theme.of(context).textTheme.bodySmall),
                    Text(dateFmt.format(b.createdAt), style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text('Room: \$${(b.roomPrice * b.numberOfNights).toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 12),
                      Text('Tax: \$${b.taxes.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
                      const Spacer(),
                      Text('\$${b.totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                );
              },
            ),
    );
  }
}
