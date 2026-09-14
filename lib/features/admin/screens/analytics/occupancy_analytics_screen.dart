import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class OccupancyAnalyticsScreen extends ConsumerWidget {
  const OccupancyAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = DummyData.rooms;
    final occupied = rooms.where((r) => r.status == RoomStatus.occupied).length;
    final rate = rooms.isEmpty ? 0.0 : occupied / rooms.length * 100;
    final floors = rooms.map((r) => r.floor).toSet().toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Occupancy Analytics')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text('Current Occupancy Rate', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            Text('${rate.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
            Text('$occupied / ${rooms.length} rooms', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 20),
        Text('By Floor', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...floors.map((f) {
          final fr = rooms.where((r) => r.floor == f).toList();
          final fo = fr.where((r) => r.status == RoomStatus.occupied).length;
          final pct = fr.isEmpty ? 0.0 : fo / fr.length;
          return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
            SizedBox(width: 60, child: Text('Fl $f', style: Theme.of(context).textTheme.bodySmall)),
            Expanded(child: LinearProgressIndicator(value: pct, backgroundColor: AppColors.lightGrey, color: AppColors.secondary, minHeight: 10, borderRadius: BorderRadius.circular(5))),
            const SizedBox(width: 8),
            Text('$fo/${fr.length}', style: Theme.of(context).textTheme.labelMedium),
          ]));
        }),
        const SizedBox(height: 20),
        Text('By Room Type', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...RoomType.values.map((t) {
          final tr = rooms.where((r) => r.type == t).toList();
          if (tr.isEmpty) return const SizedBox.shrink();
          final to = tr.where((r) => r.status == RoomStatus.occupied).length;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
            child: Row(children: [
              Expanded(child: Text(t.displayName, style: Theme.of(context).textTheme.titleSmall)),
              Text('$to / ${tr.length}', style: Theme.of(context).textTheme.bodySmall),
            ]),
          );
        }),
      ]),
    );
  }
}
