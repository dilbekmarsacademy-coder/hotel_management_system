import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class HotelInfoScreen extends StatelessWidget {
  const HotelInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
              title: const Text('About Us'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConstants.hotelName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'Experience unparalleled luxury at The Grand Luxe Hotel. '
                    'Nestled in the heart of the city, our 5-star property offers '
                    'world-class accommodations, fine dining, and exceptional service.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: AppColors.darkGrey),
                  ),
                  const SizedBox(height: 24),
                  _InfoRow(Icons.location_on, 'Address', AppConstants.hotelAddress),
                  _InfoRow(Icons.phone, 'Phone', AppConstants.hotelPhone),
                  _InfoRow(Icons.email, 'Email', AppConstants.hotelEmail),
                  _InfoRow(Icons.login, 'Check-in', AppConstants.defaultCheckInTime),
                  _InfoRow(Icons.logout, 'Check-out', AppConstants.defaultCheckOutTime),
                  const SizedBox(height: 24),
                  Text('Facilities', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      'Infinity Pool', 'Spa & Wellness', 'Fitness Center',
                      'Fine Dining', 'Business Center', 'Concierge',
                      'Valet Parking', 'Airport Transfer', '24h Room Service',
                      'Conference Rooms', 'Rooftop Bar', 'Kids Club',
                    ].map((f) => Chip(
                      label: Text(f),
                      backgroundColor: AppColors.primary.withOpacity(0.08),
                      side: BorderSide.none,
                    )).toList(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Flexible(child: Text(value, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.end)),
      ]),
    );
  }
}
