import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';

class GuestReportScreen extends ConsumerWidget {
  const GuestReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guests = DummyData.guests;
    final bookings = DummyData.bookings;
    final reviews = DummyData.reviews;
    final countries = <String, int>{};
    for (final g in guests) {
      final c = g.country ?? 'Unknown';
      countries[c] = (countries[c] ?? 0) + 1;
    }
    final withBookings = guests.where((g) => bookings.any((b) => b.guestId == g.id)).length;
    final withReviews = guests.where((g) => reviews.any((r) => r.guestId == g.id)).length;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Guest Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            _Card('Total Guests', '${guests.length}', AppColors.primary),
            const SizedBox(width: 8),
            _Card('With Bookings', '$withBookings', AppColors.success),
            const SizedBox(width: 8),
            _Card('Reviewers', '$withReviews', AppColors.secondary),
          ]),
          const SizedBox(height: 24),
          Text('Guests by Country', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...countries.entries.map((e) {
            final pct = e.value / guests.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                SizedBox(width: 100, child: Text(e.key, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Expanded(child: LinearProgressIndicator(value: pct, backgroundColor: AppColors.lightGrey, color: AppColors.secondary, minHeight: 8, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 8),
                Text('${e.value}', style: Theme.of(context).textTheme.labelMedium),
              ]),
            );
          }),
          const SizedBox(height: 24),
          Text('Recent Guests', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...guests.take(10).map((g) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
            child: Row(children: [
              CircleAvatar(radius: 18, backgroundColor: AppColors.primary, child: Text(g.initials, style: const TextStyle(color: Colors.white, fontSize: 12))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(g.fullName, style: Theme.of(context).textTheme.titleSmall),
                Text('${g.email} • ${g.country ?? ''}', style: Theme.of(context).textTheme.bodySmall),
              ])),
            ]),
          )),
        ],
      ),
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
        Text(title, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
      ]),
    ));
  }
}
