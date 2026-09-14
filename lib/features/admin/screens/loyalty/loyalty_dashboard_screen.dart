import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/user_model.dart';

class LoyaltyDashboardScreen extends ConsumerWidget {
  const LoyaltyDashboardScreen({super.key});

  /// UserModel da loyaltyPoints maydoni yo'q — Demo uchun preferences yoki id asosida.
  static int pointsOf(UserModel g) {
    final fromPrefs = g.preferences?['loyaltyPoints'];
    if (fromPrefs is int) return fromPrefs;
    if (fromPrefs is num) return fromPrefs.toInt();
    // Barqaror demo qiymat (har safar bir xil)
    return (g.id.hashCode.abs() % 8000);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guests = DummyData.guests;
    final totalPoints = guests.fold<int>(0, (s, g) => s + pointsOf(g));
    final members = guests.where((g) => pointsOf(g) > 0).length;
    final gold = guests.where((g) => pointsOf(g) >= 5000).length;
    final silver = guests.where((g) => pointsOf(g) >= 2000 && pointsOf(g) < 5000).length;

    final topMembers = guests.where((g) => pointsOf(g) > 0).toList()
      ..sort((a, b) => pointsOf(b).compareTo(pointsOf(a)));
    final top10 = topMembers.take(10).toList();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Loyalty Program')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Total Points Issued',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                Text(
                  '$totalPoints',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  '$members active members',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Card('Gold', '$gold', AppColors.secondary),
              const SizedBox(width: 8),
              _Card('Silver', '$silver', AppColors.mediumGrey),
              const SizedBox(width: 8),
              _Card('Members', '$members', AppColors.primary),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Top Members',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...top10.map(
            (g) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      g.initials,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.fullName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          g.email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${pointsOf(g)} pts',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _Card(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(title, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
