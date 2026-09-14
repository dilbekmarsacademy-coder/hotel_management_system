import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class RoomAnalyticsScreen extends ConsumerWidget {
  const RoomAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = DummyData.rooms;
    final avgPrice = rooms.isEmpty ? 0.0 : rooms.fold<double>(0, (s, r) => s + r.pricePerNight) / rooms.length;
    final avgRating = rooms.isEmpty ? 0.0 : rooms.fold<double>(0, (s, r) => s + r.rating) / rooms.length;
    final featured = rooms.where((r) => r.isFeatured).length;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Room Analytics')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          _Card('Total Rooms', '${rooms.length}', AppColors.primary),
          const SizedBox(width: 8),
          _Card('Avg Price', '\$${avgPrice.toStringAsFixed(0)}', AppColors.secondary),
          const SizedBox(width: 8),
          _Card('Avg Rating', avgRating.toStringAsFixed(1), AppColors.success),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _Card('Featured', '$featured', AppColors.info),
          const SizedBox(width: 8),
          _Card('Types', '${RoomType.values.length}', AppColors.warning),
          const SizedBox(width: 8),
          const Expanded(child: SizedBox()),
        ]),
        const SizedBox(height: 24),
        Text('By Type', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...RoomType.values.map((t) {
          final list = rooms.where((r) => r.type == t).toList();
          if (list.isEmpty) return const SizedBox.shrink();
          final avg = list.fold<double>(0, (s, r) => s + r.pricePerNight) / list.length;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
            child: Row(children: [
              Expanded(child: Text(t.displayName, style: Theme.of(context).textTheme.titleSmall)),
              Text('${list.length} rooms', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 12),
              Text('avg \$${avg.toStringAsFixed(0)}', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.secondary)),
            ]),
          );
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
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(title, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
      ]),
    ));
  }
}
