import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';

class GuestAnalyticsScreen extends ConsumerWidget {
  const GuestAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guests = DummyData.guests;
    final bookings = DummyData.bookings;
    final reviews = DummyData.reviews;
    final countries = <String, int>{};
    for (final g in guests) {
      countries[g.country ?? 'Unknown'] = (countries[g.country ?? 'Unknown'] ?? 0) + 1;
    }
    final avgBookings = guests.isEmpty ? 0.0 : bookings.length / guests.length;
    final avgRating = reviews.isEmpty ? 0.0 : reviews.fold<double>(0, (s, r) => s + r.rating) / reviews.length;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Guest Analytics')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          _Card('Guests', '${guests.length}', AppColors.primary),
          const SizedBox(width: 8),
          _Card('Avg Bookings', avgBookings.toStringAsFixed(1), AppColors.info),
          const SizedBox(width: 8),
          _Card('Avg Rating', avgRating.toStringAsFixed(1), AppColors.secondary),
        ]),
        const SizedBox(height: 24),
        Text('By Country', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...countries.entries.map((e) {
          final pct = e.value / guests.length;
          return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
            SizedBox(width: 100, child: Text(e.key, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
            Expanded(child: LinearProgressIndicator(value: pct, backgroundColor: AppColors.lightGrey, color: AppColors.secondary, minHeight: 8, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 8),
            Text('${e.value}', style: Theme.of(context).textTheme.labelMedium),
          ]));
        }),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final String title, value;
  final Color color;
  const _Card(this.title, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        Text(title, style: Theme.of(context).textTheme.labelSmall),
      ]),
    ));
  }
}
