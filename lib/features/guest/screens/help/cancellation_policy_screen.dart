import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CancellationPolicyScreen extends StatelessWidget {
  const CancellationPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Cancellation Policy')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Cancellation Policy', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _PolicyCard(
          title: 'Free Cancellation',
          subtitle: 'More than 24 hours before check-in',
          detail: 'Cancel your booking free of charge. Full refund will be processed within 5–7 business days.',
          color: AppColors.success,
        ),
        _PolicyCard(
          title: 'Late Cancellation',
          subtitle: 'Within 24 hours of check-in',
          detail: 'A charge equal to one night\'s stay will apply. Remaining nights will be refunded.',
          color: AppColors.warning,
        ),
        _PolicyCard(
          title: 'No-Show',
          subtitle: 'Failure to arrive',
          detail: 'The full amount of the reservation will be charged. No refund will be issued.',
          color: AppColors.error,
        ),
        const SizedBox(height: 16),
        Text('How to Cancel', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '1. Open My Bookings\n2. Select the booking you wish to cancel\n3. Tap Cancel Booking\n4. Confirm the cancellation\n\nYou will receive a confirmation email with refund details.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6, color: AppColors.darkGrey),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final String title, subtitle, detail;
  final Color color;
  const _PolicyCard({required this.title, required this.subtitle, required this.detail, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
        ]),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(detail, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4)),
      ]),
    );
  }
}
