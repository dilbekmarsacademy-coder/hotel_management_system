import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/enums.dart';
import '../../../../providers/room_providers.dart';

class RoomStatusBoardScreen extends ConsumerWidget {
  const RoomStatusBoardScreen({super.key});

  Color _color(RoomStatus s) {
    switch (s) {
      case RoomStatus.available: return AppColors.available;
      case RoomStatus.occupied: return AppColors.occupied;
      case RoomStatus.reserved: return AppColors.reserved;
      case RoomStatus.cleaning: return AppColors.cleaning;
      case RoomStatus.maintenance: return AppColors.maintenance;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(allRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Room Status Board')),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load')),
        data: (rooms) {
          final floors = rooms.map((r) => r.floor).toSet().toList()..sort();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Legend
              Wrap(spacing: 12, children: RoomStatus.values.map((s) {
                return Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: _color(s), shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(s.displayName, style: Theme.of(context).textTheme.labelSmall),
                ]);
              }).toList()),
              const SizedBox(height: 16),
              ...floors.map((floor) {
                final floorRooms = rooms.where((r) => r.floor == floor).toList()
                  ..sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Floor $floor', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: floorRooms.map((r) {
                      return Container(
                        width: 70,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _color(r.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _color(r.status)),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(r.roomNumber, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _color(r.status))),
                          Text(r.status.displayName, style: TextStyle(fontSize: 9, color: _color(r.status))),
                        ]),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ]);
              }),
            ],
          );
        },
      ),
    );
  }
}
