import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HotelFacilitiesScreen extends StatelessWidget {
  const HotelFacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final facilities = [
      (Icons.pool, 'Infinity Pool', 'Rooftop infinity pool with city views, open 6 AM – 10 PM'),
      (Icons.spa, 'Spa & Wellness', 'Full-service spa with massage, sauna, and treatments'),
      (Icons.fitness_center, 'Fitness Center', '24-hour gym with cardio and strength equipment'),
      (Icons.restaurant, 'Fine Dining', 'Award-winning restaurant serving international cuisine'),
      (Icons.local_bar, 'Rooftop Bar', 'Craft cocktails and panoramic sunset views'),
      (Icons.business_center, 'Business Center', 'Meeting rooms, printing, and high-speed internet'),
      (Icons.local_parking, 'Valet Parking', 'Secure valet parking available for guests'),
      (Icons.airport_shuttle, 'Airport Transfer', 'Private luxury transfers to/from the airport'),
      (Icons.room_service, '24h Room Service', 'In-room dining available around the clock'),
      (Icons.child_care, 'Kids Club', 'Supervised activities for children ages 4–12'),
      (Icons.wifi, 'High-Speed Wi-Fi', 'Complimentary Wi-Fi throughout the property'),
      (Icons.local_convenience_store, 'Concierge', 'Personal concierge for reservations and arrangements'),
    ];

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Hotel Facilities')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: facilities.length,
        itemBuilder: (context, index) {
          final (icon, title, desc) = facilities[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.lightGrey)),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(desc, style: Theme.of(context).textTheme.bodySmall),
              ])),
            ]),
          );
        },
      ),
    );
  }
}
