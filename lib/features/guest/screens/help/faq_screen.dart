import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      ('What is the check-in time?', 'Standard check-in is from 3:00 PM. Early check-in is subject to availability and may incur a fee.'),
      ('What is the check-out time?', 'Check-out is by 11:00 AM. Late check-out until 4:00 PM can be requested for an additional fee.'),
      ('How do I cancel my booking?', 'Go to My Bookings, select the booking, and tap Cancel. Free cancellation is available up to 24 hours before check-in.'),
      ('Is breakfast included?', 'Breakfast is available as an add-on service. You can book it from the Services section or at the restaurant.'),
      ('Do you offer airport transfers?', 'Yes. Book Airport Transfer from the Services section. Private luxury cars are available.'),
      ('How does the loyalty program work?', 'Earn points with every stay. Redeem points for free nights, upgrades, and exclusive experiences.'),
      ('Can I modify my reservation?', 'Yes. Contact reception or use Modify Booking from your booking details screen.'),
      ('What payment methods are accepted?', 'We accept credit/debit cards, digital wallets, and cash at the hotel.'),
      ('Is parking available?', 'Valet parking is available for a daily fee. Self-parking options may also be available nearby.'),
      ('Are pets allowed?', 'We are a pet-friendly hotel for small pets with prior arrangement. Additional fees apply.'),
    ];

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final (q, a) = faqs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(q, style: Theme.of(context).textTheme.titleSmall),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(a, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey, height: 1.5)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
