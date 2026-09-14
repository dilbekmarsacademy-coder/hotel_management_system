import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      ('Booking & Reservations', Icons.calendar_month, 'How to book, modify, or cancel'),
      ('Check-in & Check-out', Icons.login, 'Arrival times, early check-in, late checkout'),
      ('Payments & Invoices', Icons.payment, 'Payment methods, refunds, invoices'),
      ('Restaurant & Room Service', Icons.restaurant, 'Ordering food, delivery times'),
      ('Hotel Services', Icons.spa, 'Spa, gym, transfers, laundry'),
      ('Loyalty Program', Icons.card_giftcard, 'Points, rewards, tiers'),
      ('Account & Profile', Icons.person, 'Password, personal info, preferences'),
    ];

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('How can we help?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Browse topics or contact our support team', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 20),
          ...topics.map((t) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              tileColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.lightGrey)),
              leading: Icon(t.$2, color: AppColors.primary),
              title: Text(t.$1),
              subtitle: Text(t.$3, style: Theme.of(context).textTheme.bodySmall),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/guest/help/faq'),
            ),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/guest/help/contact'),
              icon: const Icon(Icons.support_agent),
              label: const Text('Contact Support'),
            ),
          ),
        ],
      ),
    );
  }
}
