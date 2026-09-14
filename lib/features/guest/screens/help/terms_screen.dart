import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Terms of Service', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Last updated: January 2026', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          _Section('1. Reservations',
              'All reservations are subject to availability. A valid credit card is required to guarantee your booking. Rates are confirmed at the time of booking and may vary based on season and occupancy.'),
          _Section('2. Check-in & Check-out',
              'Check-in time is ${AppConstants.defaultCheckInTime}. Check-out time is ${AppConstants.defaultCheckOutTime}. Early check-in and late check-out are subject to availability and may incur additional charges.'),
          _Section('3. Cancellation Policy',
              'Free cancellation is available up to 24 hours before the scheduled check-in time. Cancellations made within 24 hours of check-in may be charged one night\'s stay. No-shows will be charged the full amount.'),
          _Section('4. Payment',
              'We accept major credit/debit cards, digital wallets, and cash. Full payment or a deposit may be required at the time of booking. Outstanding balances are due at check-out.'),
          _Section('5. Guest Responsibilities',
              'Guests are responsible for any damage to hotel property during their stay. Smoking is prohibited in all indoor areas. Quiet hours are observed from 10:00 PM to 7:00 AM.'),
          _Section('6. Liability',
              '${AppConstants.hotelName} is not responsible for loss or damage to personal belongings. Safe deposit boxes are available in rooms and at reception.'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title, body;
  const _Section(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6, color: AppColors.darkGrey)),
      ]),
    );
  }
}
