import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Privacy Policy', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Last updated: January 2026', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          _Section('Information We Collect',
              'We collect personal information you provide when making a reservation, creating an account, or contacting us. This includes name, email, phone number, payment details, and stay preferences.'),
          _Section('How We Use Your Information',
              'Your information is used to process bookings, personalize your stay, process payments, send confirmations and reminders, and improve our services. We do not sell your personal data to third parties.'),
          _Section('Data Security',
              'We implement industry-standard security measures including encryption, secure servers, and access controls to protect your personal information.'),
          _Section('Cookies & Tracking',
              'Our mobile application and website may use cookies and similar technologies to enhance your experience and analyze usage patterns.'),
          _Section('Your Rights',
              'You may request access to, correction of, or deletion of your personal data. Contact us at ${AppConstants.hotelEmail} to exercise these rights.'),
          _Section('Contact',
              'For privacy-related inquiries, please contact our Data Protection Officer at ${AppConstants.hotelEmail} or call ${AppConstants.hotelPhone}.'),
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
