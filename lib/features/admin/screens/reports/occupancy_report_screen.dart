import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class OccupancyReportScreen extends ConsumerWidget {
  const OccupancyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = DummyData.rooms;
    final available = rooms.where((r) => r.status == RoomStatus.available).length;
    final occupied = rooms.where((r) => r.status == RoomStatus.occupied).length;
    final reserved = rooms.where((r) => r.status == RoomStatus.reserved).length;
    final cleaning = rooms.where((r) => r.status == RoomStatus.cleaning).length;
    final maintenance = rooms.where((r) => r.status == RoomStatus.maintenance).length;
    final occupancyRate = rooms.isEmpty ? 0.0 : (occupied / rooms.length) * 100;

    // By floor
    final floors = rooms.map((r) => r.floor).toSet().toList()..sort();
    // By type
    final byType = <RoomType, int>{};
    for (final r in rooms) {
      if (r.status == RoomStatus.occupied) {
        byType[r.type] = (byType[r.type] ?? 0) + 1;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Occupancy Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Main occupancy
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('Current Occupancy', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  '${occupancyRate.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('$occupied of ${rooms.length} rooms occupied', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Status breakdown
          Row(
            children: [
              _StatusCard('Available', available, AppColors.available),
              const SizedBox(width: 8),
              _StatusCard('Occupied', occupied, AppColors.occupied),
              const SizedBox(width: 8),
              _StatusCard('Reserved', reserved, AppColors.reserved),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatusCard('Cleaning', cleaning, AppColors.cleaning),
              const SizedBox(width: 8),
              _StatusCard('Maintenance', maintenance, AppColors.maintenance),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 24),

          Text('Occupancy by Floor', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...floors.map((floor) {
            final floorRooms = rooms.where((r) => r.floor == floor).toList();
            final floorOccupied = floorRooms.where((r) => r.status == RoomStatus.occupied).length;
            final rate = floorRooms.isEmpty ? 0.0 : floorOccupied / floorRooms.length;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Row(
                children: [
                  SizedBox(width: 70, child: Text('Floor $floor', style: Theme.of(context).textTheme.titleSmall)),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: rate,
                      backgroundColor: AppColors.lightGrey,
                      color: AppColors.secondary,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('$floorOccupied/${floorRooms.length}', style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          Text('Occupied by Room Type', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...RoomType.values.map((type) {
            final count = byType[type] ?? 0;
            final totalOfType = rooms.where((r) => r.type == type).length;
            if (totalOfType == 0) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(type.displayName, style: Theme.of(context).textTheme.titleSmall)),
                  Text('$count / $totalOfType occupied', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatusCard(this.label, this.value, this.color);

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
            Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
